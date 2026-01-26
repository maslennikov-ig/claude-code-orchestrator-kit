---
name: deps-health-inline
description: Inline orchestration workflow for dependency audit and updates with Beads integration. Provides step-by-step phases for dependency-auditor detection, priority-based updates with dependency-updater, and verification cycles.
version: 3.0.0
---

# Dependency Health Check (Inline Orchestration)

You ARE the orchestrator. Execute this workflow directly without spawning a separate orchestrator agent.

## Workflow Overview

```
Beads Init → Audit → Create Issues → Update by Priority → Close Issues → Verify → Beads Complete
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
   - Check lockfile exists (pnpm-lock.yaml, package-lock.json, yarn.lock)

3. **Create Beads wisp**:
   ```bash
   bd mol wisp exploration --vars "question=Dependency audit and update"
   ```

   **IMPORTANT**: Save the wisp ID (e.g., `mc2-xxx`) for later use.

4. **Initialize TodoWrite**:
   ```json
   [
     {"content": "Dependency audit", "status": "in_progress", "activeForm": "Auditing dependencies"},
     {"content": "Create Beads issues", "status": "pending", "activeForm": "Creating issues"},
     {"content": "Fix critical dependency issues", "status": "pending", "activeForm": "Fixing critical deps"},
     {"content": "Fix high priority dependency issues", "status": "pending", "activeForm": "Fixing high deps"},
     {"content": "Fix medium priority dependency issues", "status": "pending", "activeForm": "Fixing medium deps"},
     {"content": "Fix low priority dependency issues", "status": "pending", "activeForm": "Fixing low deps"},
     {"content": "Verification audit", "status": "pending", "activeForm": "Verifying updates"},
     {"content": "Complete Beads wisp", "status": "pending", "activeForm": "Completing wisp"}
   ]
   ```

---

## Phase 2: Detection

**Invoke dependency-auditor** via Task tool:

```
subagent_type: "dependency-auditor"
description: "Audit all dependencies"
prompt: |
  Audit the entire codebase for dependency issues:
  - Security vulnerabilities (npm audit / pnpm audit)
  - Outdated packages (major/minor/patch)
  - Unused dependencies (via Knip)
  - Deprecated packages
  - License compliance issues
  - Categorize by priority (critical/high/medium/low)

  Generate: dependency-scan-report.md

  Return summary with issue counts per priority.
```

**After dependency-auditor returns**:
1. Read `dependency-scan-report.md`
2. Parse issue counts by priority
3. If zero issues → skip to Phase 7 (Final Summary)
4. Update TodoWrite: mark audit complete

---

## Phase 3: Create Beads Issues

**For each dependency issue found**, create a Beads issue:

```bash
# Critical security vulnerabilities (P0)
bd create "DEP-SEC: {package}@{version} - {vulnerability}" -t bug -p 0 -d "{description}" \
  --deps discovered-from:{wisp_id}

# High - outdated major versions with breaking changes (P1)
bd create "DEP: {package} major update {old} → {new}" -t chore -p 1 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Medium - minor updates, deprecated packages (P2)
bd create "DEP: {package} update {old} → {new}" -t chore -p 2 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Low - patch updates, unused deps (P3)
bd create "DEP: {package} - {issue}" -t chore -p 3 -d "{description}" \
  --deps discovered-from:{wisp_id}
```

**Track issue IDs** in a mapping for later closure.

Update TodoWrite: mark "Create Beads issues" complete.

---

## Phase 4: Quality Gate (Pre-update)

Run inline validation:

```bash
pnpm type-check
pnpm build
```

- If both pass → proceed to updates
- If fail → report to user, exit

---

## Phase 5: Update Loop

**For each priority** (critical → high → medium → low):

1. **Check if issues exist** for this priority
   - If zero → skip to next priority

2. **Update TodoWrite**: mark current priority in_progress

3. **Claim issues in Beads**:
   ```bash
   bd update {issue_id} --status in_progress
   ```

4. **Invoke dependency-updater** via Task tool:
   ```
   subagent_type: "dependency-updater"
   description: "Update {priority} dependencies"
   prompt: |
     Read dependency-scan-report.md and fix all {priority} priority issues.

     For each issue:
     1. Backup package.json and lockfile
     2. Update ONE dependency at a time
     3. Run type-check and build after each update
     4. If fails, rollback and skip
     5. Log change to .tmp/current/changes/deps-changes.json

     Generate/update: dependency-updates-implemented.md

     Return: count of updated deps, count of failed updates, list of updated dep IDs.
   ```

5. **Quality Gate** (inline):
   ```bash
   pnpm type-check
   pnpm build
   ```

   - If FAIL → report error, suggest rollback, exit
   - If PASS → continue

6. **Close updated issues in Beads**:
   ```bash
   bd close {issue_id_1} {issue_id_2} ... --reason "Dependency updated"
   ```

7. **Update TodoWrite**: mark priority complete

8. **Repeat** for next priority

---

## Phase 6: Verification

After all priorities updated:

1. **Update TodoWrite**: mark verification in_progress

2. **Invoke dependency-auditor** (verification mode):
   ```
   subagent_type: "dependency-auditor"
   description: "Verification audit"
   prompt: |
     Re-audit dependencies after updates.
     Compare with previous dependency-scan-report.md.

     Report:
     - Issues fixed (count)
     - Issues remaining (count)
     - New issues introduced (count)
   ```

3. **Decision**:
   - If issues_remaining == 0 → Phase 7
   - If iteration < 3 AND issues_remaining > 0 → Go to Phase 2
   - If iteration >= 3 → Phase 7 with remaining issues

---

## Phase 7: Final Summary & Beads Complete

1. **Complete Beads wisp**:
   ```bash
   # If all updated
   bd mol squash {wisp_id}

   # If nothing found
   bd mol burn {wisp_id}
   ```

2. **Create issues for remaining items** (if any):
   ```bash
   bd create "DEP REMAINING: {package} - {issue}" -t chore -p {priority} \
     -d "Not updated in audit. May require manual intervention. See dependency-scan-report.md"
   ```

3. **Generate summary for user**:

```markdown
## Dependency Health Check Complete

**Wisp ID**: {wisp_id}
**Iterations**: {count}/3
**Status**: {SUCCESS/PARTIAL}

### Results
- Found: {total} dependency issues
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
- Remaining: {count}

### Validation
- Type Check: {status}
- Build: {status}

### Artifacts
- Audit: `dependency-scan-report.md`
- Updates: `dependency-updates-implemented.md`
```

4. **Update TodoWrite**: mark wisp complete

5. **SESSION CLOSE PROTOCOL**:
   ```bash
   git status
   git add .
   bd sync
   git commit -m "chore(deps): {fixed} dependencies updated ({wisp_id})"
   bd sync
   git push
   ```

---

## Error Handling

**If quality gate fails**:
```
Rollback available: .tmp/current/changes/deps-changes.json

To rollback:
1. Read changes log
2. Restore package.json and lockfile from .tmp/current/backups/
3. Run pnpm install
4. Re-run workflow
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
| 3. After audit | `bd create` for each issue |
| 5. Before update | `bd update --status in_progress` |
| 5. After update | `bd close --reason "Updated"` |
| 7. Complete | `bd mol squash/burn` |
| 7. Remaining | `bd create` for failed updates |
