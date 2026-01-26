---
name: reuse-health-inline
description: Inline orchestration workflow for code duplication detection and consolidation with Beads integration. Provides step-by-step phases for reuse-hunter detection, priority-based consolidation with reuse-fixer, and verification cycles.
version: 3.0.0
---

# Code Reuse Health Check (Inline Orchestration)

You ARE the orchestrator. Execute this workflow directly without spawning a separate orchestrator agent.

## Workflow Overview

```
Beads Init → Detection → Create Issues → Consolidate by Priority → Close Issues → Verify → Beads Complete
```

**Max iterations**: 3
**Priorities**: high → medium → low
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
   bd mol wisp exploration --vars "question=Code duplication scan and consolidation"
   ```

   **IMPORTANT**: Save the wisp ID (e.g., `mc2-xxx`) for later use.

4. **Initialize TodoWrite**:
   ```json
   [
     {"content": "Duplication detection", "status": "in_progress", "activeForm": "Detecting duplications"},
     {"content": "Create Beads issues", "status": "pending", "activeForm": "Creating issues"},
     {"content": "Consolidate high priority duplications", "status": "pending", "activeForm": "Consolidating high priority"},
     {"content": "Consolidate medium priority duplications", "status": "pending", "activeForm": "Consolidating medium priority"},
     {"content": "Consolidate low priority duplications", "status": "pending", "activeForm": "Consolidating low priority"},
     {"content": "Verification scan", "status": "pending", "activeForm": "Verifying consolidation"},
     {"content": "Complete Beads wisp", "status": "pending", "activeForm": "Completing wisp"}
   ]
   ```

---

## Phase 2: Detection

**Invoke reuse-hunter** via Task tool:

```
subagent_type: "reuse-hunter"
description: "Detect all code duplications"
prompt: |
  Scan the entire codebase for code duplications:
  - Duplicated TypeScript interfaces/types
  - Duplicated Zod schemas
  - Duplicated constants and configuration objects
  - Copy-pasted utility functions
  - Similar code patterns that should be abstracted
  - Categorize by priority (high/medium/low)

  Generate: reuse-hunting-report.md

  Return summary with duplication counts per priority.
```

**After reuse-hunter returns**:
1. Read `reuse-hunting-report.md`
2. Parse duplication counts by priority
3. If zero duplications → skip to Phase 7 (Final Summary)
4. Update TodoWrite: mark detection complete

---

## Phase 3: Create Beads Issues

**For each duplication found**, create a Beads issue:

```bash
# High - types/schemas duplicated across packages (P2)
bd create "REUSE: {type_name} duplicated in {locations}" -t chore -p 2 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Medium - constants/configs duplicated (P3)
bd create "REUSE: {const_name} duplicated" -t chore -p 3 -d "{description}" \
  --deps discovered-from:{wisp_id}

# Low - utility functions, minor duplications (P4)
bd create "REUSE: {item_name} can be consolidated" -t chore -p 4 -d "{description}" \
  --deps discovered-from:{wisp_id}
```

**Track issue IDs** in a mapping for later closure.

Update TodoWrite: mark "Create Beads issues" complete.

---

## Phase 4: Quality Gate (Pre-consolidation)

Run inline validation:

```bash
pnpm type-check
pnpm build
```

- If both pass → proceed to consolidation
- If fail → report to user, exit

---

## Phase 5: Consolidation Loop

**For each priority** (high → medium → low):

1. **Check if duplications exist** for this priority
   - If zero → skip to next priority

2. **Update TodoWrite**: mark current priority in_progress

3. **Claim issues in Beads**:
   ```bash
   bd update {issue_id} --status in_progress
   ```

4. **Invoke reuse-fixer** via Task tool:
   ```
   subagent_type: "reuse-fixer"
   description: "Consolidate {priority} duplications"
   prompt: |
     Read reuse-hunting-report.md and consolidate all {priority} priority duplications.

     For each duplication:
     1. Backup files before editing
     2. Determine canonical location (usually shared-types or shared package)
     3. Create/update canonical file with the type/schema/constant
     4. Replace duplicates with imports/re-exports
     5. Log change to .tmp/current/changes/reuse-changes.json

     Generate/update: reuse-consolidation-implemented.md

     Return: count of consolidated items, count of failed consolidations, list of consolidated item IDs.
   ```

5. **Quality Gate** (inline):
   ```bash
   pnpm type-check
   pnpm build
   ```

   - If FAIL → report error, suggest rollback, exit
   - If PASS → continue

6. **Close consolidated issues in Beads**:
   ```bash
   bd close {issue_id_1} {issue_id_2} ... --reason "Consolidated to shared-types"
   ```

7. **Update TodoWrite**: mark priority complete

8. **Repeat** for next priority

---

## Phase 6: Verification

After all priorities consolidated:

1. **Update TodoWrite**: mark verification in_progress

2. **Invoke reuse-hunter** (verification mode):
   ```
   subagent_type: "reuse-hunter"
   description: "Verification scan"
   prompt: |
     Re-scan codebase after consolidation.
     Compare with previous reuse-hunting-report.md.

     Report:
     - Duplications resolved (count)
     - Duplications remaining (count)
     - New duplications introduced (count)
   ```

3. **Decision**:
   - If duplications_remaining == 0 → Phase 7
   - If iteration < 3 AND duplications_remaining > 0 → Go to Phase 2
   - If iteration >= 3 → Phase 7 with remaining items

---

## Phase 7: Final Summary & Beads Complete

1. **Complete Beads wisp**:
   ```bash
   # If all consolidated
   bd mol squash {wisp_id}

   # If nothing found
   bd mol burn {wisp_id}
   ```

2. **Create issues for remaining items** (if any):
   ```bash
   bd create "REUSE REMAINING: {item_name}" -t chore -p {priority} \
     -d "Not consolidated. May require architectural decision. See reuse-hunting-report.md"
   ```

3. **Generate summary for user**:

```markdown
## Code Reuse Health Check Complete

**Wisp ID**: {wisp_id}
**Iterations**: {count}/3
**Status**: {SUCCESS/PARTIAL}

### Results
- Found: {total} duplications
- Consolidated: {consolidated} ({percentage}%)
- Remaining: {remaining}

### By Priority
- High: {consolidated}/{total}
- Medium: {consolidated}/{total}
- Low: {consolidated}/{total}

### Beads Issues
- Created: {count}
- Closed: {count}
- Remaining: {count}

### Validation
- Type Check: {status}
- Build: {status}

### Artifacts
- Detection: `reuse-hunting-report.md`
- Consolidation: `reuse-consolidation-implemented.md`
```

4. **Update TodoWrite**: mark wisp complete

5. **SESSION CLOSE PROTOCOL**:
   ```bash
   git status
   git add .
   bd sync
   git commit -m "refactor: consolidate {consolidated} duplications ({wisp_id})"
   bd sync
   git push
   ```

---

## Error Handling

**If quality gate fails**:
```
Rollback available: .tmp/current/changes/reuse-changes.json

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

## Duplication Categories

**Types/Interfaces** (shared-types):
- Database types
- API types
- Zod schemas
- Common enums

**Constants** (shared-types):
- Configuration objects
- MIME types, file limits
- Feature flags

**Utilities** (shared package or re-export):
- Helper functions
- Validation utilities
- Formatters

**Single Source of Truth Pattern**:
1. Canonical location: `packages/shared-types/src/`
2. Other packages: `export * from '@package/shared-types/{module}'`
3. NEVER copy code between packages

---

## Quick Reference

| Phase | Beads Action |
|-------|--------------|
| 1. Pre-flight | `bd mol wisp exploration` |
| 3. After detection | `bd create` for each item |
| 5. Before consolidation | `bd update --status in_progress` |
| 5. After consolidation | `bd close --reason "Consolidated"` |
| 7. Complete | `bd mol squash/burn` |
| 7. Remaining | `bd create` for unconsolidated items |
