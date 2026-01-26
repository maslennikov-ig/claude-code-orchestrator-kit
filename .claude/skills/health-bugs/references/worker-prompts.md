# Worker Prompts for Bug Health Check

## Bug Hunter - Detection

````
subagent_type: "bug-hunter"
description: "Detect all bugs"
prompt: |
  Execute comprehensive bug detection scan.

  ## Scan Categories
  1. **Static Analysis**: Run `pnpm type-check` and `pnpm build`
  2. **Security**: SQL injection, XSS, hardcoded credentials
  3. **Performance**: O(n²) loops, memory leaks, missing pagination
  4. **Debug Code**: console.log, TODO/FIXME, temp variables
  5. **Dead Code**: commented blocks, unused imports, unreachable code

  ## Output
  Generate `bug-hunting-report.md` with structure:

  ```markdown
  # Bug Hunting Report

  **Generated**: {timestamp}
  **Status**: {PASSED/FAILED}

  ## Summary
  - Critical: {count}
  - High: {count}
  - Medium: {count}
  - Low: {count}

  ## Critical Issues
  ### BUG-001: {title}
  - **File**: `path/to/file.ts:123`
  - **Category**: Security/Crash/Data Loss
  - **Description**: {description}
  - **Fix**: {suggestion}

  ## High Priority Issues
  [same format]

  ## Medium Priority Issues
  [same format]

  ## Low Priority Issues
  [same format]

  ## Validation Results
  - Type Check: {PASSED/FAILED}
  - Build: {PASSED/FAILED}
````

Return summary: "Found X bugs (Y critical, Z high, ...)"

```

---

## Bug Hunter - Verification

```

subagent_type: "bug-hunter"
description: "Verification scan"
prompt: |
Re-scan codebase after bug fixes.

## Tasks

1. Run full detection scan (same as initial)
2. Compare with previous `bug-hunting-report.md`
3. Identify:
   - Bugs that were fixed
   - Bugs that remain
   - New bugs introduced by fixes

## Output

Overwrite `bug-hunting-report.md` with new scan results.

Return summary:

- "Verification complete: X bugs fixed, Y remaining, Z new"
- Include recommendation: ITERATE or COMPLETE

```

---

## Bug Fixer - By Priority

```

subagent_type: "bug-fixer"
description: "Fix {priority} bugs"
prompt: |
Fix all {priority} priority bugs from bug-hunting-report.md.

## Protocol

For EACH bug:

1. **Read** bug details from report
2. **Backup** file before editing:
   ```bash
   cp {file} .tmp/current/backups/{sanitized-path}.backup
   ```
3. **Log** change to `.tmp/current/changes/bug-changes.json`:
   ```json
   {
     "files_modified": [
       {
         "path": "path/to/file.ts",
         "backup": ".tmp/current/backups/path-to-file.ts.backup",
         "bug_id": "BUG-001",
         "reason": "Fix description"
       }
     ]
   }
   ```
4. **Fix** the bug using Edit tool
5. **Validate** after each fix: `pnpm type-check`

## Output

Update `bug-fixes-implemented.md`:

```markdown
# Bug Fixes Report

**Priority**: {priority}
**Timestamp**: {timestamp}

## Fixed

- [x] BUG-001: {description} → Fixed in `file.ts:123`
- [x] BUG-002: {description} → Fixed in `other.ts:45`

## Failed

- [ ] BUG-003: {description} → Reason: {why failed}

## Summary

- Fixed: X/{total}
- Failed: Y/{total}

## Rollback

Changes log: `.tmp/current/changes/bug-changes.json`
```

Return: "Fixed X/{total} {priority} bugs"

````

---

## Inline Quality Gate

Execute directly (no Task tool):

```bash
# Type check
pnpm type-check
# Exit code 0 = PASS, non-zero = FAIL

# Build
pnpm build
# Exit code 0 = PASS, non-zero = FAIL
````

**Decision Logic**:

- Both PASS → continue workflow
- Any FAIL → stop, report error, suggest rollback

---

## Rollback Protocol

If validation fails after fixes:

```bash
# Read changes log
cat .tmp/current/changes/bug-changes.json

# For each modified file, restore from backup
cp .tmp/current/backups/{file}.backup {original-path}

# For each created file, delete
rm {created-file-path}
```

Or use skill:

```
Use rollback-changes Skill with changes_log_path=.tmp/current/changes/bug-changes.json
```
