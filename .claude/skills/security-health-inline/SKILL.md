---
name: security-health-inline
description: Inline orchestration workflow for security vulnerability detection and remediation with Beads integration. Provides step-by-step phases for security-scanner detection, priority-based fixing with vulnerability-fixer, and verification cycles.
version: 3.0.0
---

# Security Health Check (Inline Orchestration)

You ARE the orchestrator. Execute this workflow directly without spawning a separate orchestrator agent.

## Workflow Overview

```
Beads Init → Detection → Create Issues → Fix by Priority → Close Issues → Verify → Beads Complete
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
   bd mol wisp exploration --vars "question=Security vulnerability scan"
   ```

   **IMPORTANT**: Save the wisp ID (e.g., `mc2-xxx`) for later use.

4. **Initialize TodoWrite**:
   ```json
   [
     {"content": "Security scan", "status": "in_progress", "activeForm": "Scanning for vulnerabilities"},
     {"content": "Create Beads issues", "status": "pending", "activeForm": "Creating issues"},
     {"content": "Fix critical vulnerabilities", "status": "pending", "activeForm": "Fixing critical vulnerabilities"},
     {"content": "Fix high priority vulnerabilities", "status": "pending", "activeForm": "Fixing high vulnerabilities"},
     {"content": "Fix medium priority vulnerabilities", "status": "pending", "activeForm": "Fixing medium vulnerabilities"},
     {"content": "Fix low priority vulnerabilities", "status": "pending", "activeForm": "Fixing low vulnerabilities"},
     {"content": "Verification scan", "status": "pending", "activeForm": "Verifying fixes"},
     {"content": "Complete Beads wisp", "status": "pending", "activeForm": "Completing wisp"}
   ]
   ```

---

## Phase 2: Detection

**Invoke security-scanner** via Task tool:

```
subagent_type: "security-scanner"
description: "Detect all vulnerabilities"
prompt: |
  Scan the entire codebase for security vulnerabilities:
  - SQL injection
  - XSS vulnerabilities
  - Authentication/authorization issues
  - RLS policy violations
  - Hardcoded secrets
  - Insecure dependencies
  - Categorize by priority (critical/high/medium/low)

  Generate: security-scan-report.md

  Return summary with vulnerability counts per priority.
```

**After security-scanner returns**:
1. Read `security-scan-report.md`
2. Parse vulnerability counts by priority
3. If zero vulnerabilities → skip to Phase 7 (Final Summary)
4. Update TodoWrite: mark detection complete

---

## Phase 3: Create Beads Issues

**For each vulnerability found**, create a Beads issue:

```bash
# Critical (P0) - Security critical gets highest priority
bd create "SECURITY: {vuln_title}" -t bug -p 0 -d "{description}" \
  --deps discovered-from:{wisp_id}

# High (P1)
bd create "SECURITY: {vuln_title}" -t bug -p 1 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Medium (P2)
bd create "SECURITY: {vuln_title}" -t bug -p 2 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Low (P3)
bd create "SECURITY: {vuln_title}" -t bug -p 3 -d "{description}" \
  --deps discovered-from:{wisp_id}
```

**Add security label**:
```bash
bd update {issue_id} --add-label security
```

**Track issue IDs** in a mapping for later closure.

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

1. **Check if vulnerabilities exist** for this priority
   - If zero → skip to next priority

2. **Update TodoWrite**: mark current priority in_progress

3. **Claim issues in Beads**:
   ```bash
   bd update {issue_id} --status in_progress
   ```

4. **Invoke vulnerability-fixer** via Task tool:
   ```
   subagent_type: "vulnerability-fixer"
   description: "Fix {priority} vulnerabilities"
   prompt: |
     Read security-scan-report.md and fix all {priority} priority vulnerabilities.

     For each vulnerability:
     1. Backup file before editing
     2. Implement fix
     3. Log change to .tmp/current/changes/security-changes.json

     Generate/update: security-fixes-implemented.md

     Return: count of fixed vulnerabilities, count of failed fixes, list of fixed vuln IDs.
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
   bd close {issue_id_1} {issue_id_2} ... --reason "Security fix applied"
   ```

7. **Update TodoWrite**: mark priority complete

8. **Repeat** for next priority

---

## Phase 6: Verification

After all priorities fixed:

1. **Update TodoWrite**: mark verification in_progress

2. **Invoke security-scanner** (verification mode):
   ```
   subagent_type: "security-scanner"
   description: "Verification scan"
   prompt: |
     Re-scan codebase after fixes.
     Compare with previous security-scan-report.md.

     Report:
     - Vulnerabilities fixed (count)
     - Vulnerabilities remaining (count)
     - New vulnerabilities introduced (count)
   ```

3. **Decision**:
   - If vulnerabilities_remaining == 0 → Phase 7
   - If iteration < 3 AND vulnerabilities_remaining > 0 → Go to Phase 2
   - If iteration >= 3 → Phase 7 with remaining vulnerabilities

---

## Phase 7: Final Summary & Beads Complete

1. **Complete Beads wisp**:
   ```bash
   # If all fixed
   bd mol squash {wisp_id}

   # If nothing found
   bd mol burn {wisp_id}
   ```

2. **Create issues for remaining vulnerabilities** (if any):
   ```bash
   bd create "SECURITY REMAINING: {vuln_title}" -t bug -p {priority} \
     -d "Not fixed in scan. REQUIRES MANUAL ATTENTION. See security-scan-report.md"
   bd update {new_issue_id} --add-label security
   ```

3. **Generate summary for user**:

```markdown
## Security Health Check Complete

**Wisp ID**: {wisp_id}
**Iterations**: {count}/3
**Status**: {SUCCESS/PARTIAL}

### Results
- Found: {total} vulnerabilities
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
- Remaining: {count} (SECURITY LABEL - requires attention)

### Validation
- Type Check: {status}
- Build: {status}

### Artifacts
- Detection: `security-scan-report.md`
- Fixes: `security-fixes-implemented.md`
```

4. **Update TodoWrite**: mark wisp complete

5. **SESSION CLOSE PROTOCOL**:
   ```bash
   git status
   git add .
   bd sync
   git commit -m "security: {fixed} vulnerabilities fixed ({wisp_id})"
   bd sync
   git push
   ```

---

## Error Handling

**If quality gate fails**:
```
Rollback available: .tmp/current/changes/security-changes.json

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
| 3. After detection | `bd create` + `--add-label security` |
| 5. Before fix | `bd update --status in_progress` |
| 5. After fix | `bd close --reason "Fixed"` |
| 7. Complete | `bd mol squash/burn` |
| 7. Remaining | `bd create` with security label |
