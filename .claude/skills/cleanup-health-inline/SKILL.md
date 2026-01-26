---
name: cleanup-health-inline
description: Inline orchestration workflow for dead code detection and removal with Beads integration. Provides step-by-step phases for dead-code-hunter detection, priority-based cleanup with dead-code-remover, and verification cycles.
version: 3.0.0
---

# Cleanup Health Check (Inline Orchestration)

You ARE the orchestrator. Execute this workflow directly without spawning a separate orchestrator agent.

## Workflow Overview

```
Beads Init → Detection → Create Issues → Remove by Priority → Close Issues → Verify → Beads Complete
```

**Max iterations**: 3
**Priorities**: critical → high → medium → low
**Beads integration**: Automatic issue tracking

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
   bd mol wisp exploration --vars "question=Dead code cleanup scan"
   ```

   **IMPORTANT**: Save the wisp ID (e.g., `mc2-xxx`) for later use.

4. **Initialize TodoWrite**:
   ```json
   [
     {"content": "Dead code detection", "status": "in_progress", "activeForm": "Detecting dead code"},
     {"content": "Create Beads issues", "status": "pending", "activeForm": "Creating issues"},
     {"content": "Remove critical dead code", "status": "pending", "activeForm": "Removing critical dead code"},
     {"content": "Remove high priority dead code", "status": "pending", "activeForm": "Removing high dead code"},
     {"content": "Remove medium priority dead code", "status": "pending", "activeForm": "Removing medium dead code"},
     {"content": "Remove low priority dead code", "status": "pending", "activeForm": "Removing low dead code"},
     {"content": "Verification scan", "status": "pending", "activeForm": "Verifying cleanup"},
     {"content": "Complete Beads wisp", "status": "pending", "activeForm": "Completing wisp"}
   ]
   ```

---

## Phase 2: Detection

**Invoke dead-code-hunter** via Task tool:

```
subagent_type: "dead-code-hunter"
description: "Detect all dead code"
prompt: |
  Scan the entire codebase for dead code:
  - Unused imports and exports
  - Commented out code blocks
  - Unreachable code
  - Debug statements (console.log, debugger)
  - Unused variables and functions
  - Unused dependencies
  - Categorize by priority (critical/high/medium/low)

  Generate: dead-code-report.md

  Return summary with dead code counts per priority.
```

**After dead-code-hunter returns**:
1. Read `dead-code-report.md`
2. Parse dead code counts by priority
3. If zero dead code → skip to Phase 7 (Final Summary)
4. Update TodoWrite: mark detection complete

---

## Phase 3: Create Beads Issues

**For each dead code item found**, create a Beads issue:

```bash
# Critical (P1)
bd create "CLEANUP: {item_title}" -t chore -p 1 -d "{description}" \
  --deps discovered-from:{wisp_id}

# High (P2)
bd create "CLEANUP: {item_title}" -t chore -p 2 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Medium (P3)
bd create "CLEANUP: {item_title}" -t chore -p 3 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Low (P4)
bd create "CLEANUP: {item_title}" -t chore -p 4 -d "{description}" \
  --deps discovered-from:{wisp_id}
```

**Track issue IDs** in a mapping for later closure.

Update TodoWrite: mark "Create Beads issues" complete.

---

## Phase 4: Quality Gate (Pre-removal)

Run inline validation:

```bash
pnpm type-check
pnpm build
```

- If both pass → proceed to removal
- If fail → report to user, exit

---

## Phase 5: Removal Loop

**For each priority** (critical → high → medium → low):

1. **Check if dead code exists** for this priority
   - If zero → skip to next priority

2. **Update TodoWrite**: mark current priority in_progress

3. **Claim issues in Beads**:
   ```bash
   bd update {issue_id} --status in_progress
   ```

4. **Invoke dead-code-remover** via Task tool:
   ```
   subagent_type: "dead-code-remover"
   description: "Remove {priority} dead code"
   prompt: |
     Read dead-code-report.md and remove all {priority} priority dead code.

     For each item:
     1. Backup file before editing
     2. Remove dead code
     3. Log change to .tmp/current/changes/cleanup-changes.json

     Generate/update: dead-code-cleanup-summary.md

     Return: count of removed items, count of failed removals, list of removed item IDs.
   ```

5. **Quality Gate** (inline):
   ```bash
   pnpm type-check
   pnpm build
   ```

   - If FAIL → report error, suggest rollback, exit
   - If PASS → continue

6. **Close removed issues in Beads**:
   ```bash
   bd close {issue_id_1} {issue_id_2} ... --reason "Removed in cleanup"
   ```

7. **Update TodoWrite**: mark priority complete

8. **Repeat** for next priority

---

## Phase 6: Verification

After all priorities cleaned:

1. **Update TodoWrite**: mark verification in_progress

2. **Invoke dead-code-hunter** (verification mode):
   ```
   subagent_type: "dead-code-hunter"
   description: "Verification scan"
   prompt: |
     Re-scan codebase after cleanup.
     Compare with previous dead-code-report.md.

     Report:
     - Dead code removed (count)
     - Dead code remaining (count)
     - New dead code introduced (count)
   ```

3. **Decision**:
   - If dead_code_remaining == 0 → Phase 7
   - If iteration < 3 AND dead_code_remaining > 0 → Go to Phase 2
   - If iteration >= 3 → Phase 7 with remaining items

---

## Phase 7: Final Summary & Beads Complete

1. **Complete Beads wisp**:
   ```bash
   # If all cleaned
   bd mol squash {wisp_id}

   # If nothing found
   bd mol burn {wisp_id}
   ```

2. **Create issues for remaining items** (if any):
   ```bash
   bd create "REMAINING: {item_title}" -t chore -p {priority} \
     -d "Not removed in cleanup. See dead-code-report.md"
   ```

3. **Generate summary for user**:

```markdown
## Cleanup Health Check Complete

**Wisp ID**: {wisp_id}
**Iterations**: {count}/3
**Status**: {SUCCESS/PARTIAL}

### Results
- Found: {total} dead code items
- Removed: {removed} ({percentage}%)
- Remaining: {remaining}

### By Priority
- Critical: {removed}/{total}
- High: {removed}/{total}
- Medium: {removed}/{total}
- Low: {removed}/{total}

### Beads Issues
- Created: {count}
- Closed: {count}
- Remaining: {count}

### Validation
- Type Check: {status}
- Build: {status}

### Artifacts
- Detection: `dead-code-report.md`
- Cleanup: `dead-code-cleanup-summary.md`
```

4. **Update TodoWrite**: mark wisp complete

5. **SESSION CLOSE PROTOCOL**:
   ```bash
   git status
   git add .
   bd sync
   git commit -m "chore: cleanup - {removed} dead code items removed ({wisp_id})"
   bd sync
   git push
   ```

---

## Error Handling

**If quality gate fails**:
```
Rollback available: .tmp/current/changes/cleanup-changes.json

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

| Phase | Beads Action |
|-------|--------------|
| 1. Pre-flight | `bd mol wisp exploration` |
| 3. After detection | `bd create` for each item |
| 5. Before removal | `bd update --status in_progress` |
| 5. After removal | `bd close --reason "Removed"` |
| 7. Complete | `bd mol squash/burn` |
| 7. Remaining | `bd create` for unremoved items |
