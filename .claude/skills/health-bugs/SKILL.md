---
name: health-bugs
description: Inline orchestration workflow for automated bug detection and fixing with Beads integration. Provides step-by-step phases for bug-hunter detection, history enrichment for priority bugs, priority-based fixing with bug-fixer, and verification cycles.
version: 3.1.0
---

# Bug Health Check (Inline Orchestration)

You ARE the orchestrator. Execute this workflow directly without spawning a separate orchestrator agent.

## Workflow Overview

```
Beads Init → Detection → History Check (HIGH+) → Create Issues → Fix by Priority → Close Issues → Verify → Beads Complete
```

**Max iterations**: 3
**Priorities**: critical → high → medium → low
**Beads integration**: Automatic issue tracking
**History enrichment**: For CRITICAL and HIGH bugs only

---

## Phase 1: Pre-flight & Beads Init

1. **Setup directories**:

   ```bash
   mkdir -p .tmp/current/{plans,changes,backups}
   ```

2. **Validate environment**:
   - Check `package.json` exists
   - Check `type-check` and `build` scripts exist

3. **Create Beads wisp**:

   ```bash
   bd mol wisp healthcheck
   ```

   **IMPORTANT**: Save the wisp ID (e.g., `mc2-xxx`) for later use.

4. **Initialize TodoWrite**:
   ```json
   [
     { "content": "Bug detection", "status": "in_progress", "activeForm": "Detecting bugs" },
     { "content": "Create Beads issues", "status": "pending", "activeForm": "Creating issues" },
     { "content": "Fix critical bugs", "status": "pending", "activeForm": "Fixing critical bugs" },
     { "content": "Fix high priority bugs", "status": "pending", "activeForm": "Fixing high bugs" },
     {
       "content": "Fix medium priority bugs",
       "status": "pending",
       "activeForm": "Fixing medium bugs"
     },
     { "content": "Fix low priority bugs", "status": "pending", "activeForm": "Fixing low bugs" },
     { "content": "Verification scan", "status": "pending", "activeForm": "Verifying fixes" },
     { "content": "Complete Beads wisp", "status": "pending", "activeForm": "Completing wisp" }
   ]
   ```

---

## Phase 2: Detection

**Invoke bug-hunter** via Task tool:

```
subagent_type: "bug-hunter"
description: "Detect all bugs"
prompt: |
  Scan the entire codebase for bugs:
  - Run type-check and build
  - Check for security vulnerabilities
  - Find dead code and debug statements
  - Categorize by priority (critical/high/medium/low)

  Generate: bug-hunting-report.md

  Return summary with bug counts per priority.
```

**After bug-hunter returns**:

1. Read `bug-hunting-report.md`
2. Parse bug counts by priority
3. If zero bugs → skip to Phase 7 (Final Summary)
4. Update TodoWrite: mark detection complete

---

## Phase 2.5: History Enrichment (CRITICAL/HIGH only)

**Purpose**: Find previously fixed similar bugs to detect regressions and provide historical context.

**When to run**: Only for CRITICAL and HIGH priority bugs (skip for MEDIUM/LOW).

### Steps

1. **Extract keywords** from each CRITICAL/HIGH bug title/description

2. **Search Beads history**:

   ```bash
   # For each bug, search by relevant keywords
   bd search "{keywords}" --status closed --limit 5

   # Also search by category
   bd search "security" --status closed --limit 5      # for security bugs
   bd search "dependency" --status closed --limit 5    # for dependency bugs
   bd search "{file_path}" --status closed --limit 3   # for file-specific bugs
   ```

3. **Evaluate results**:
   - **Match found**: Similar closed issue exists
     - Could be regression (same bug returned)
     - Could be related pattern (similar problem elsewhere)
   - **No match**: New type of bug

4. **Enrich bug data**:

   ```
   For each bug with history matches:
   - Add to bug metadata: related_issues: [mc2-xxx, mc2-yyy]
   - Note if potential regression: is_regression: true/false
   ```

5. **Store enrichment** for Phase 3 and Phase 5:
   ```json
   // .tmp/current/history-enrichment.json
   {
     "bug_1": {
       "related_closed": ["mc2-abc", "mc2-def"],
       "is_potential_regression": false,
       "context": "Similar security fix in mc2-abc"
     }
   }
   ```

### Output

- **If related issues found**: Include in bug description when creating Beads issue
- **If potential regression**: Flag for special attention in bug-fixer prompt
- **If no history**: Proceed normally (new bug type)

### Example

```bash
# Bug: "Vulnerable tar package"
bd search "tar" --status closed --limit 5
bd search "vulnerability" --status closed --limit 5
bd search "pnpm override" --status closed --limit 5

# Results: No matches → new bug, no enrichment needed
# Results: mc2-xyz found → add to related_issues
```

**Note**: History enrichment is informational, not blocking. Missing history doesn't prevent fixing.

---

## Phase 3: Create Beads Issues

**For each bug found**, create a Beads issue.

### For CRITICAL/HIGH bugs (with history enrichment):

```bash
# If related_issues found in Phase 2.5:
bd create "BUG: {bug_title}" -t bug -p {1|2} \
  -d "{description}

## History Context
Related closed issues: {related_issues}
Potential regression: {yes/no}
Previous fix context: {context from enrichment}" \
  --deps discovered-from:{wisp_id}

# If no history found:
bd create "BUG: {bug_title}" -t bug -p {1|2} -d "{description}" \
  --deps discovered-from:{wisp_id}
```

### For MEDIUM/LOW bugs (no history check):

```bash
# Medium bugs (P3)
bd create "BUG: {bug_title}" -t bug -p 3 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Low bugs (P4)
bd create "BUG: {bug_title}" -t bug -p 4 -d "{description}" \
  --deps discovered-from:{wisp_id}
```

**Track issue IDs** in a mapping:

```
bug_1 → mc2-aaa (related: mc2-xyz)
bug_2 → mc2-bbb
...
```

Update TodoWrite: mark "Create Beads issues" complete.

---

## Phase 4: Quality Gate (Pre-fix)

Run inline validation:

```bash
pnpm type-check
pnpm build
```

- If both pass → proceed to fixing
- If fail → report to user, exit

---

## Phase 5: Fixing Loop

**For each priority** (critical → high → medium → low):

1. **Check if bugs exist** for this priority
   - If zero → skip to next priority

2. **Update TodoWrite**: mark current priority in_progress

3. **Claim issues in Beads**:

   ```bash
   bd update {issue_id} --status in_progress
   ```

4. **Invoke bug-fixer** via Task tool:

   ```
   subagent_type: "bug-fixer"
   description: "Fix {priority} bugs"
   prompt: |
     Read bug-hunting-report.md and fix all {priority} priority bugs.

     ## History Context (for CRITICAL/HIGH only)
     Check .tmp/current/history-enrichment.json for related closed issues.
     If a bug has related_closed issues:
     - Review the previous fix approach (bd show {related_id})
     - Consider if this is a regression
     - Apply learnings from previous fix

     For each bug:
     1. Backup file before editing
     2. If history exists, review previous fix first
     3. Implement fix
     4. Log change to .tmp/current/changes/bug-changes.json

     Generate/update: bug-fixes-implemented.md

     Return: count of fixed bugs, count of failed fixes, list of fixed bug IDs.
   ```

5. **Quality Gate** (inline):

   ```bash
   pnpm type-check
   pnpm build
   ```

   - If FAIL → report error, suggest rollback, exit
   - If PASS → continue

6. **Close fixed issues in Beads**:

   ```bash
   bd close {issue_id_1} {issue_id_2} ... --reason "Fixed in health check"
   ```

7. **Update TodoWrite**: mark priority complete

8. **Repeat** for next priority

---

## Phase 6: Verification

After all priorities fixed:

1. **Update TodoWrite**: mark verification in_progress

2. **Invoke bug-hunter** (verification mode):

   ```
   subagent_type: "bug-hunter"
   description: "Verification scan"
   prompt: |
     Re-scan codebase after fixes.
     Compare with previous bug-hunting-report.md.

     Report:
     - Bugs fixed (count)
     - Bugs remaining (count)
     - New bugs introduced (count)
   ```

3. **Decision**:
   - If bugs_remaining == 0 → Phase 7
   - If iteration < 3 AND bugs_remaining > 0 → Go to Phase 2
   - If iteration >= 3 → Phase 7 with remaining bugs

---

## Phase 7: Final Summary & Beads Complete

1. **Complete Beads wisp**:

   ```bash
   # If all bugs fixed
   bd mol squash {wisp_id}

   # If no bugs found (nothing to do)
   bd mol burn {wisp_id}
   ```

2. **Create issues for remaining bugs** (if any):

   ```bash
   bd create "REMAINING: {bug_title}" -t bug -p {priority} \
     -d "Not fixed in health check. See bug-hunting-report.md"
   ```

3. **Generate summary for user**:

```markdown
## Bug Health Check Complete

**Wisp ID**: {wisp_id}
**Iterations**: {count}/3
**Status**: {SUCCESS/PARTIAL}

### Results

- Found: {total} bugs
- Fixed: {fixed} ({percentage}%)
- Remaining: {remaining}

### By Priority

- Critical: {fixed}/{total}
- High: {fixed}/{total}
- Medium: {fixed}/{total}
- Low: {fixed}/{total}

### Beads Issues

- Created: {count}
- Closed: {count}
- Remaining: {count} (issues created for follow-up)

### Validation

- Type Check: {status}
- Build: {status}

### Artifacts

- Detection: `bug-hunting-report.md`
- Fixes: `bug-fixes-implemented.md`
```

4. **Update TodoWrite**: mark wisp complete

5. **SESSION CLOSE PROTOCOL**:
   ```bash
   git status
   git add .
   bd sync
   git commit -m "fix: health check - {fixed} bugs fixed ({wisp_id})"
   bd sync
   git push
   ```

---

## Error Handling

**If quality gate fails**:

```
Rollback available: .tmp/current/changes/bug-changes.json

To rollback:
1. Read changes log
2. Restore files from .tmp/current/backups/
3. Re-run workflow
```

**If worker fails**:

- Report error to user
- Keep Beads wisp open for manual completion
- Suggest manual intervention
- Exit workflow

**If Beads command fails**:

- Log error but continue workflow
- Beads tracking is enhancement, not blocker

---

## Quick Reference

| Phase                | Beads Action                             |
| -------------------- | ---------------------------------------- |
| 1. Pre-flight        | `bd mol wisp healthcheck`                |
| 2.5. History (HIGH+) | `bd search "{keywords}" --status closed` |
| 3. After detection   | `bd create` for each bug (with history)  |
| 5. Before fix        | `bd update --status in_progress`         |
| 5. After fix         | `bd close --reason "Fixed"`              |
| 7. Complete          | `bd mol squash/burn`                     |
| 7. Remaining         | `bd create` for unfixed bugs             |

---

## Worker Prompts

See `references/worker-prompts.md` for detailed prompts.
