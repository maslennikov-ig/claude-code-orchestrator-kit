# Standardized Report Template

**Date Created**: 2025-10-17
**Date Updated**: 2025-10-18
**Phase**: 4 - Task 4.2
**Status**: Standard Template for All Worker Reports (v2.0)
**Purpose**: Define consistent structure, metadata format, and validation sections for all agent-generated reports

---

## Table of Contents

1. [Overview](#overview)
2. [Standard Metrics](#standard-metrics)
3. [File Organization Rules](#file-organization-rules)
4. [Report Structure](#report-structure)
5. [Metadata Format](#metadata-format)
6. [Required Sections](#required-sections)
7. [Validation Section Format](#validation-section-format)
8. [Report Types](#report-types)
9. [Examples](#examples)

---

## Overview

### Purpose

All worker agents must generate reports following this standardized template to ensure:
- **Consistency**: Predictable structure across all report types
- **Parsability**: Machines can validate and extract data
- **Completeness**: All required information is present
- **Traceability**: Metadata enables tracking and auditing

### Usage

Workers should:
1. Use `generate-report-header` Skill for header generation
2. Follow required section structure
3. Include all validation results
4. Use consistent status indicators
5. Save reports with standard naming

---

## Standard Metrics

### All Reports Must Include

Every report, regardless of type, must include these standard metrics for consistency and traceability:

#### Core Metrics (Required)

| Metric | Format | Description | Example |
|--------|--------|-------------|---------|
| **Timestamp** | ISO-8601 | When report was generated | `2025-10-18T14:30:00Z` |
| **Duration** | Human-readable | Execution time | `3m 45s`, `1h 12m`, `45s` |
| **Workflow** | Domain name | Which domain workflow | `bugs`, `security`, `dead-code`, `dependencies` |
| **Phase** | Phase type | Workflow phase | `detection`, `fixing`, `verification` |
| **Validation Status** | Emoji + Text | Overall validation result | `✅ PASSED`, `⛔ FAILED`, `⚠️ PARTIAL` |

#### Optional Metrics

| Metric | Format | Description | Example |
|--------|--------|-------------|---------|
| **Priority/Severity** | Level | Issue priority/severity | `critical`, `high`, `medium`, `low` |
| **Files Processed** | Number | Files analyzed/modified | `42 files` |
| **Issues Found** | Number | Total issues discovered | `15 bugs`, `3 critical CVEs` |
| **Changes Made** | Boolean | Whether modifications occurred | `true`, `false` |
| **Changes Log** | File path | Path to changes log | `.bug-changes.json` |

### Domain-Specific Metrics

Each domain adds specific metrics beyond the standard set:

#### Bug Domain
- **Bugs by Priority**: Breakdown of bugs (critical: 2, high: 5, etc.)
- **Bugs Fixed**: Number of bugs resolved
- **Bugs Remaining**: Outstanding bugs after fixes

#### Security Domain
- **CVEs by Severity**: Breakdown of vulnerabilities
- **RLS Policies**: Count of policies analyzed/fixed
- **Auth Issues**: Authentication/authorization problems

#### Dead-Code Domain
- **Lines Removed**: Total lines of dead code removed
- **Files Modified**: Files cleaned up
- **Cleanup Categories**: Unused imports, debug code, etc.

#### Dependencies Domain
- **Packages Updated**: Number of dependencies updated
- **Security Fixes**: Vulnerabilities patched
- **Version Changes**: Major/minor/patch breakdown

---

## File Organization Rules

### File Location Strategy

Clear rules for where to save different types of files to prevent root directory clutter:

#### Temporary Files (Auto-cleanup)

**Location**: Project root
**Lifetime**: Auto-cleanup after 7 days or workflow completion
**Pattern**: `.{workflow}-*` or `{temp-name}-report.md`

| File Type | Pattern | Cleanup Trigger | Example |
|-----------|---------|-----------------|---------|
| Plan Files | `.{domain}-{phase}-plan.json` | After worker completion | `.bug-detection-plan.json` |
| Temp Reports | `{task}-report.md` | After 7 days | `bug-hunting-report.md` |
| Changes Logs | `.{domain}-changes.json` | After successful validation | `.bug-changes.json` |
| Lock Files | `.locks/*.lock` | After 30min or completion | `.locks/active-fixer.lock` |
| Backup Directory | `.rollback/` | After successful validation | `.rollback/src-file.ts.backup` |

**Cleanup Policy**:
```bash
# Workers should cleanup temp files after success
rm -f .{domain}-changes.json
rm -rf .rollback/

# Orchestrators should cleanup plan files
rm -f .{domain}-{phase}-plan.json

# Lock files auto-expire after 30 minutes
```

#### Permanent Files

**Location**: `docs/reports/{domain}/{date}/`
**Lifetime**: Permanent (manual archive)
**Pattern**: `{date}-{domain}-{type}.md`

| Report Type | Location | Naming | Example |
|-------------|----------|--------|---------|
| Bug Reports | `docs/reports/bugs/{YYYY-MM}/` | `{date}-bug-hunting-report.md` | `docs/reports/bugs/2025-10/2025-10-18-bug-hunting-report.md` |
| Security Audits | `docs/reports/security/{YYYY-MM}/` | `{date}-security-audit.md` | `docs/reports/security/2025-10/2025-10-18-security-audit.md` |
| Dead Code | `docs/reports/cleanup/{YYYY-MM}/` | `{date}-dead-code-report.md` | `docs/reports/cleanup/2025-10/2025-10-18-dead-code-report.md` |
| Dependencies | `docs/reports/deps/{YYYY-MM}/` | `{date}-dependency-audit.md` | `docs/reports/deps/2025-10/2025-10-18-dependency-audit.md` |
| Summaries | `docs/reports/summaries/` | `{date}-health-summary.md` | `docs/reports/summaries/2025-10-18-health-summary.md` |

**Archive Policy**:
```bash
# Archive reports older than 90 days
mv docs/reports/{domain}/{old-month}/ docs/reports/archive/{domain}/{year}/
```

#### Special Directories

| Directory | Purpose | Cleanup | Example Files |
|-----------|---------|---------|---------------|
| `.locks/` | Active workflow locks | Auto (30min) | `active-fixer.lock` |
| `.rollback/` | Backup files for rollback | After success | `src-file.ts.backup` |
| `.claude/schemas/` | JSON schemas (permanent) | Manual | `bug-plan.schema.json` |
| `.claude/skills/` | Skills (permanent) | Manual | `rollback-changes/SKILL.md` |
| `docs/reports/archive/` | Old reports | Manual | `archive/bugs/2025/` |

### Implementation in Workers

Workers must follow these rules:

**Before generating report**:
```markdown
1. Determine report type (temporary vs permanent)
2. If temporary: Save to root with cleanup note
3. If permanent: Create dated directory structure
4. Add cleanup instructions in "Next Steps" section
```

**After successful execution**:
```markdown
1. Cleanup temporary files (.{domain}-changes.json, .rollback/)
2. Remove plan files (.{domain}-{phase}-plan.json)
3. Move temp report to permanent location (if archival needed)
```

**In report "Next Steps" section**:
```markdown
### Cleanup
- [ ] Review report and confirm results
- [ ] Run: `rm -f .bug-changes.json .bug-detection-plan.json`
- [ ] Run: `rm -rf .rollback/`
- [ ] Archive report: `mv bug-hunting-report.md docs/reports/bugs/2025-10/2025-10-18-bug-hunting-report.md`
```

---

## Report Structure

### High-Level Structure

```markdown
# {ReportType} Report: {Version/Identifier}

---
[Metadata in YAML frontmatter]
---

[Header with Generated timestamp, Status, Version]

---

## Executive Summary

[Key findings and metrics]

---

## Detailed Findings

[Domain-specific findings]

---

## Validation Results

[Validation status and details]

---

## Next Steps

[Actionable recommendations]

---

[Optional: Appendices, raw data, logs]
```

---

## Metadata Format

### YAML Frontmatter

Place at the **very beginning** of the report, before the title.

```yaml
---
report_type: bug-hunting | security-audit | dead-code | dependency-audit | version-update | code-health | verification
generated: ISO-8601 timestamp (YYYY-MM-DDTHH:mm:ssZ)
version: semantic version or date identifier
status: success | partial | failed | in_progress
agent: worker-agent-name
duration: execution time (e.g., "3m 45s", "1h 12m")
files_processed: number (optional)
issues_found: number (optional)
---
```

### Metadata Fields

#### Required Fields

- **report_type**: One of the valid report types (see Report Types section)
- **generated**: ISO-8601 timestamp
- **version**: Version identifier or date (YYYY-MM-DD format)
- **status**: Overall report status

#### Optional Fields

- **agent**: Worker agent that generated report
- **duration**: How long the operation took
- **files_processed**: Number of files analyzed
- **issues_found**: Total issues discovered
- **custom_field**: Domain-specific fields as needed

### Status Values

| Status | Emoji | Description |
|--------|-------|-------------|
| `success` | ✅ | Operation completed successfully |
| `partial` | ⚠️ | Completed with warnings or partial failures |
| `failed` | ❌ | Operation failed critically |
| `in_progress` | 🔄 | Operation is currently running |

---

## Required Sections

### 1. Title and Header

**Format**:
```markdown
# {ReportType} Report: {Version}

**Generated**: {Timestamp}
**Status**: {Emoji} {Status}
**Version**: {Version}
**Agent**: {AgentName} (optional)
**Duration**: {Duration} (optional)
**Files Processed**: {Count} (optional)

---
```

**Rules**:
- Title must be H1 (single #)
- Use standardized report type names
- Include status emoji
- Use `generate-report-header` Skill

### 2. Executive Summary

**Format**:
```markdown
## Executive Summary

[Brief overview of the operation and key findings]

### Key Metrics

- **Metric 1**: Value
- **Metric 2**: Value
- **Metric 3**: Value

### Highlights

- ✅ Major success/completion
- ⚠️ Warning or concern
- ❌ Critical issue (if any)
```

**Requirements**:
- Start with H2 heading
- Include 3-5 key metrics
- Highlight most important findings
- Use emojis for visual clarity

### 3. Detailed Findings

**Format**: Varies by report type (see Report Types section)

**General Requirements**:
- Start with H2 heading
- Organize by severity/priority/category
- Include actionable descriptions
- Use lists for multiple items
- Include code snippets if relevant

### 4. Validation Results

**Format**:
```markdown
## Validation Results

### Build Validation

- **Type Check**: ✅ PASSED / ❌ FAILED
  ```bash
  pnpm type-check
  # Exit code: 0
  # Output: No errors found
  ```

- **Build**: ✅ PASSED / ❌ FAILED
  ```bash
  pnpm build
  # Exit code: 0
  # Output: Build successful
  ```

### Test Validation (Optional)

- **Tests**: ✅ PASSED / ⚠️ PARTIAL / ❌ FAILED
  ```bash
  pnpm test
  # Exit code: 0
  # Output: 42/42 tests passed
  ```

### Overall Status

**Validation**: ✅ PASSED / ⚠️ PARTIAL / ❌ FAILED

[Explanation if not fully passed]
```

**Requirements**:
- Include type-check and build results
- Show actual commands run
- Include exit codes
- Show relevant output excerpts
- Overall status at the end

### 5. Next Steps

**Format**:
```markdown
## Next Steps

### Immediate Actions (Required)

1. [Action item with specific steps]
2. [Action item with specific steps]

### Recommended Actions (Optional)

- [Recommendation 1]
- [Recommendation 2]

### Follow-Up

- [Long-term action or monitoring]
```

**Requirements**:
- Start with H2 heading
- Separate required vs optional actions
- Be specific and actionable
- Include responsible parties if known

---

## Validation Section Format

### Standard Validation Checks

All reports must validate:

#### 1. Type Check

```markdown
### Type Check

**Command**: `pnpm type-check`

**Status**: ✅ PASSED

**Output**:
\```
tsc --noEmit
No errors found.
\```

**Exit Code**: 0
```

#### 2. Build

```markdown
### Build

**Command**: `pnpm build`

**Status**: ✅ PASSED

**Output**:
\```
vite build
✓ built in 3.45s
dist/index.js  125.3 kB
\```

**Exit Code**: 0
```

#### 3. Tests (Optional)

```markdown
### Tests

**Command**: `pnpm test`

**Status**: ✅ PASSED (42/42)

**Output**:
\```
jest
PASS  src/utils.test.ts
PASS  src/types.test.ts
...
Tests: 42 passed, 42 total
\```

**Exit Code**: 0
```

### Overall Validation Status

```markdown
### Overall Status

**Validation**: ✅ PASSED

All validation checks completed successfully. No blocking issues detected.
```

---

## Report Types

### 1. Bug Hunting Report

**report_type**: `bug-hunting`

**Required Metadata**:
- files_processed
- issues_found
- critical_count, high_count, medium_count, low_count

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### Critical (3)

1. **[File:Line] Issue Title**
   - **Severity**: Critical
   - **Description**: [What's wrong]
   - **Impact**: [What happens]
   - **Location**: `path/to/file.ts:123`
   - **Fix**: [How to fix]

### High (8)

[Same structure]

### Medium (12)

[Same structure]

### Low (5)

[Same structure]
```

**Example**: See Examples section

---

### 2. Security Audit Report

**report_type**: `security-audit`

**Required Metadata**:
- vulnerabilities_found
- critical_vulns, high_vulns, medium_vulns, low_vulns
- rls_policies_checked (if Supabase)

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### OWASP Top 10 Scan

#### A01:2021 - Broken Access Control

- ✅ No issues found
- Checked: Authentication middleware, authorization logic

#### A02:2021 - Cryptographic Failures

- ⚠️ 1 issue found
  - **Issue**: Hardcoded secret in configuration
  - **Location**: `config/secrets.ts:15`
  - **Severity**: High
  - **Remediation**: Move to environment variables

### SQL Injection Scan

[Results]

### Cross-Site Scripting (XSS)

[Results]

### RLS Policy Validation (if Supabase)

[Results]
```

**Example**: See Examples section

---

### 3. Dead Code Report

**report_type**: `dead-code`

**Required Metadata**:
- files_scanned
- dead_code_items
- commented_code_lines
- debug_artifacts

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### Critical Dead Code (5)

1. **Unused Export: `oldFunction`**
   - **File**: `src/utils.ts:45-67`
   - **Type**: Exported function never imported
   - **Lines**: 23 lines
   - **Safe to Remove**: ✅ Yes

### Commented Code (12)

1. **Large Comment Block**
   - **File**: `src/legacy.ts:100-250`
   - **Lines**: 151 lines commented
   - **Safe to Remove**: ⚠️ Review recommended

### Debug Artifacts (8)

1. **Console.log statements**
   - **File**: `src/api.ts:34, 67, 89`
   - **Count**: 3 occurrences
   - **Safe to Remove**: ✅ Yes
```

**Example**: See Examples section

---

### 4. Dependency Audit Report

**report_type**: `dependency-audit`

**Required Metadata**:
- dependencies_checked
- outdated_count
- vulnerable_count
- unused_count

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### Security Vulnerabilities (5)

#### Critical CVEs (2)

1. **lodash@4.17.20**
   - **CVE**: CVE-2021-23337
   - **Severity**: Critical (CVSS 9.1)
   - **Fix**: Update to lodash@4.17.21
   - **Command**: `npm install lodash@4.17.21`

### Outdated Packages (23)

#### Major Updates Available (5)

1. **react: 17.0.2 → 18.2.0**
   - **Type**: Major (Breaking)
   - **Release Date**: 2022-03-29
   - **Migration**: [Link to migration guide]

### Unused Dependencies (3)

1. **moment**
   - **Reason**: Not imported anywhere
   - **Action**: Remove from package.json
   - **Savings**: 2.3 MB
```

**Example**: See Examples section

---

### 5. Version Update Report

**report_type**: `version-update`

**Required Metadata**:
- old_version
- new_version
- files_updated
- references_updated

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### Version Changes

- **Old Version**: 0.7.0
- **New Version**: 0.8.0
- **Change Type**: Minor

### Files Updated (15)

#### Package Files (2)

1. **package.json**
   - **Line 3**: `"version": "0.7.0"` → `"version": "0.8.0"`

2. **packages/client/package.json**
   - **Line 3**: `"version": "0.7.0"` → `"version": "0.8.0"`

#### Documentation Files (8)

1. **README.md**
   - **Line 10**: Version badge updated
   - **Line 45**: Installation version updated

### Historical References Preserved (12)

- CHANGELOG.md entries for 0.7.0 preserved
- Release notes for previous versions unchanged
```

**Example**: See Examples section

---

### 6. Code Health Report

**report_type**: `code-health`

**Required Metadata**:
- overall_score
- bugs_found
- security_issues
- dead_code_items
- dependency_issues

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### Overall Health Score: 72/100 (Good)

### Domain Results

#### Bugs (Bug Orchestrator)

- **Status**: ✅ Completed
- **Issues Found**: 23
- **Critical**: 3
- **Report**: `bug-hunting-report.md`

#### Security (Security Orchestrator)

- **Status**: ⚠️ Partial
- **Vulnerabilities**: 7
- **Critical**: 2 unfixed
- **Report**: `security-audit-report.md`

#### Dead Code (Dead Code Orchestrator)

- **Status**: ✅ Completed
- **Items Removed**: 45
- **Lines Deleted**: 1,234
- **Report**: `dead-code-report.md`

#### Dependencies (Dependency Orchestrator)

- **Status**: ✅ Completed
- **Outdated**: 0 critical
- **Vulnerable**: 1 low
- **Report**: `dependency-audit-report.md`
```

**Example**: See Examples section

---

### 7. Verification Report

**report_type**: `verification`

**Required Metadata**:
- original_report
- verification_type (final|retry|followup)
- comparison_performed

**Detailed Findings Structure**:
```markdown
## Detailed Findings

### Verification Type: Final Scan

### Original Report Comparison

- **Original Issues**: 23
- **Current Issues**: 2
- **Resolved**: 21
- **New Issues**: 0
- **Regression**: ❌ None

### Remaining Issues (2)

1. **Medium Priority: Type inference issue**
   - **Status**: Known limitation
   - **Documented**: Yes
   - **Blocking**: No

### Validation

- Type Check: ✅ PASSED
- Build: ✅ PASSED
- Tests: ✅ PASSED (42/42)
```

**Example**: See Examples section

---

## Examples

### Example 1: Bug Hunting Report

```markdown
---
report_type: bug-hunting
generated: 2025-10-17T14:30:00Z
version: 2025-10-17
status: success
agent: bug-hunter
duration: 3m 45s
files_processed: 147
issues_found: 23
critical_count: 3
high_count: 8
medium_count: 12
low_count: 0
---

# Bug Hunting Report: 2025-10-17

**Generated**: 2025-10-17 14:30:00 UTC
**Status**: ✅ success
**Version**: 2025-10-17
**Agent**: bug-hunter
**Duration**: 3m 45s
**Files Processed**: 147

---

## Executive Summary

Comprehensive bug scan completed successfully. Found 23 bugs across 147 TypeScript files.

### Key Metrics

- **Critical Bugs**: 3 (require immediate attention)
- **High-Priority Bugs**: 8 (fix this sprint)
- **Medium-Priority Bugs**: 12 (schedule next sprint)
- **Files Scanned**: 147
- **Scan Duration**: 3m 45s

### Highlights

- ✅ Scan completed without errors
- ❌ 3 critical bugs require immediate attention
- ⚠️ Memory leak detected in connection pool (Critical)
- ✅ No security vulnerabilities in bug patterns

---

## Detailed Findings

### Critical (3)

1. **[src/api/database.ts:45] Memory Leak in Connection Pool**
   - **Severity**: Critical
   - **Priority**: P0
   - **Description**: Connection pool not releasing connections after timeout
   - **Impact**: Memory exhaustion after ~2 hours of operation
   - **Location**: `src/api/database.ts:45-67`
   - **Fix**: Implement automatic connection cleanup and recycling
   - **Estimated Time**: 2 hours

2. **[src/auth/session.ts:123] Race Condition in Session Management**
   - **Severity**: Critical
   - **Priority**: P0
   - **Description**: Concurrent requests can create duplicate sessions
   - **Impact**: Data inconsistency, potential security issue
   - **Location**: `src/auth/session.ts:123-145`
   - **Fix**: Add mutex lock or atomic transaction
   - **Estimated Time**: 1.5 hours

3. **[src/utils/parser.ts:89] Unhandled Promise Rejection**
   - **Severity**: Critical
   - **Priority**: P0
   - **Description**: Promise rejection in parser crashes the process
   - **Impact**: Service crashes on malformed input
   - **Location**: `src/utils/parser.ts:89-102`
   - **Fix**: Add try-catch around async parser calls
   - **Estimated Time**: 30 minutes

### High (8)

1. **[src/components/Form.tsx:234] Type Error in Props**
   - **Severity**: High
   - **Priority**: P1
   - **Description**: Missing required prop `onSubmit` not caught by types
   - **Impact**: Runtime errors when form is submitted
   - **Location**: `src/components/Form.tsx:234`
   - **Fix**: Add proper TypeScript interface for props
   - **Estimated Time**: 20 minutes

[... additional high-priority bugs ...]

### Medium (12)

1. **[src/hooks/useData.ts:56] Inefficient Re-rendering**
   - **Severity**: Medium
   - **Priority**: P2
   - **Description**: Hook causes unnecessary re-renders on every state change
   - **Impact**: Performance degradation with large lists
   - **Location**: `src/hooks/useData.ts:56-78`
   - **Fix**: Add useMemo to expensive calculations
   - **Estimated Time**: 15 minutes

[... additional medium-priority bugs ...]

---

## Validation Results

### Type Check

**Command**: `pnpm type-check`

**Status**: ✅ PASSED

**Output**:
\```
tsc --noEmit
No type errors found.
Checked 147 files in 2.34s
\```

**Exit Code**: 0

### Build

**Command**: `pnpm build`

**Status**: ✅ PASSED

**Output**:
\```
vite build
✓ 147 modules transformed
✓ built in 3.45s
dist/index.js  125.3 kB
dist/styles.css  45.2 kB
\```

**Exit Code**: 0

### Tests (Optional)

**Command**: `pnpm test`

**Status**: ✅ PASSED (42/42)

**Output**:
\```
jest
PASS  src/api/database.test.ts
PASS  src/auth/session.test.ts
PASS  src/utils/parser.test.ts
...
Tests: 42 passed, 42 total
Time:  4.567s
\```

**Exit Code**: 0

### Overall Status

**Validation**: ✅ PASSED

All validation checks completed successfully. Codebase is stable and buildable despite bugs found.

---

## Next Steps

### Immediate Actions (Required)

1. **Fix Critical Bugs** (P0)
   - Start with memory leak in connection pool (highest impact)
   - Then race condition in session management
   - Finally unhandled promise rejection

2. **Run Regression Tests**
   - After each critical fix, run full test suite
   - Verify no new issues introduced

3. **Deploy Fixes**
   - Critical fixes should be deployed immediately
   - Consider hotfix release

### Recommended Actions (Optional)

- Schedule high-priority bugs for current sprint
- Create tickets for medium-priority bugs
- Consider adding integration tests for race conditions

### Follow-Up

- Re-run bug scan after fixes to verify resolution
- Monitor production for memory usage after connection pool fix
- Update documentation with lessons learned

---

## Appendix A: Files Scanned

Total: 147 files

- TypeScript files: 125
- React components: 45
- Test files: 42
- Configuration: 5

---

## Appendix B: Scan Configuration

- **Mode**: Thorough
- **Patterns**: TypeScript, React
- **Excluded**: node_modules, dist, .git
- **Timeout**: None
- **Max Depth**: Unlimited
```

---

### Example 2: Security Audit Report

```markdown
---
report_type: security-audit
generated: 2025-10-17T15:45:00Z
version: final
status: partial
agent: security-scanner
duration: 5m 12s
vulnerabilities_found: 7
critical_vulns: 2
high_vulns: 3
medium_vulns: 2
low_vulns: 0
rls_policies_checked: 15
---

# Security Audit Report: final

**Generated**: 2025-10-17 15:45:00 UTC
**Status**: ⚠️ partial
**Version**: final
**Agent**: security-scanner
**Duration**: 5m 12s
**Vulnerabilities Found**: 7

---

## Executive Summary

Security audit completed with **2 critical vulnerabilities** requiring immediate attention.

### Key Metrics

- **Security Score**: 65/100 (Needs Improvement)
- **Critical Vulnerabilities**: 2 (URGENT)
- **High Vulnerabilities**: 3 (This Sprint)
- **RLS Policies Checked**: 15 (3 missing)
- **OWASP Top 10 Coverage**: 80%

### Highlights

- ❌ 2 critical vulnerabilities require immediate patching
- ❌ Hardcoded credentials found in configuration files
- ⚠️ 3 missing RLS policies on Supabase tables
- ✅ No SQL injection vulnerabilities detected
- ✅ Authentication middleware properly configured

---

## Detailed Findings

### OWASP Top 10 Scan

#### A01:2021 - Broken Access Control

- ⚠️ **3 issues found**

1. **Missing RLS Policy on `users` table**
   - **Severity**: Critical
   - **Location**: Supabase `users` table
   - **Issue**: No Row-Level Security policy defined
   - **Impact**: All authenticated users can read all user data
   - **Remediation**: Add RLS policy:
     \```sql
     ALTER TABLE users ENABLE ROW LEVEL SECURITY;

     CREATE POLICY "Users can only see own data"
     ON users FOR SELECT
     USING (auth.uid() = id);
     \```

2. **Missing Authorization Check in Admin Endpoint**
   - **Severity**: High
   - **Location**: `src/api/admin.ts:45`
   - **Issue**: Admin endpoint doesn't verify admin role
   - **Impact**: Any authenticated user can access admin functions
   - **Remediation**: Add role check middleware

#### A02:2021 - Cryptographic Failures

- ❌ **1 critical issue found**

1. **Hardcoded Secret in Configuration**
   - **Severity**: Critical
   - **Location**: `config/secrets.ts:15`
   - **Issue**: JWT secret hardcoded in source
   - **Impact**: Anyone with access to code can forge tokens
   - **Remediation**:
     1. Rotate the exposed secret immediately
     2. Move to environment variable
     3. Add to .gitignore

#### A03:2021 - Injection

- ✅ **No issues found**
  - All database queries use parameterized statements
  - No raw SQL concatenation detected

#### A04:2021 - Insecure Design

- ⚠️ **1 issue found**

1. **Password Reset Token Not Expiring**
   - **Severity**: Medium
   - **Location**: `src/auth/reset.ts:67`
   - **Issue**: Reset tokens never expire
   - **Impact**: Old reset links remain valid indefinitely
   - **Remediation**: Add 1-hour expiration to tokens

[... additional OWASP categories ...]

---

## Validation Results

### Type Check

**Command**: `pnpm type-check`

**Status**: ✅ PASSED

### Build

**Command**: `pnpm build`

**Status**: ✅ PASSED

### Security Tests

**Command**: `pnpm test:security`

**Status**: ⚠️ PARTIAL (2/5 failed)

**Output**:
\```
FAIL  src/api/admin.test.ts
  ● Admin API › should require admin role
    Expected 403, received 200

FAIL  src/auth/reset.test.ts
  ● Password Reset › tokens should expire
    Token still valid after 2 hours
\```

### Overall Status

**Validation**: ⚠️ PARTIAL

Critical vulnerabilities found. System is functional but security posture needs improvement.

---

## Next Steps

### Immediate Actions (URGENT)

1. **Rotate Exposed JWT Secret**
   - Generate new secret
   - Update environment variables
   - Invalidate all existing tokens
   - Deploy immediately

2. **Add Missing RLS Policies**
   - `users` table (Critical)
   - `posts` table (High)
   - `comments` table (High)

3. **Fix Admin Authorization**
   - Add role check to admin endpoints
   - Test with non-admin users
   - Deploy with secret rotation

### Recommended Actions (This Sprint)

- Add token expiration to password resets
- Implement rate limiting on auth endpoints
- Review and update security documentation

### Follow-Up

- Schedule monthly security audits
- Set up automated vulnerability scanning
- Train team on secure coding practices

---

## Appendix: RLS Policy Templates

\```sql
-- Users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see own data"
ON users FOR SELECT
USING (auth.uid() = id);

-- Posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public posts readable"
ON posts FOR SELECT
USING (is_public = true OR auth.uid() = user_id);
\```
```

---

## Validation Checklist

Use this checklist when reviewing reports:

### Report Structure
- [ ] YAML frontmatter present and valid
- [ ] Title follows format: `# {Type} Report: {Version}`
- [ ] Header includes all required metadata
- [ ] All 5 required sections present

### Content Quality
- [ ] Executive Summary is concise and clear
- [ ] Key metrics are quantified
- [ ] Detailed findings are specific and actionable
- [ ] Validation results show actual commands run
- [ ] Next steps are concrete and prioritized

### Status Consistency
- [ ] Header status matches YAML frontmatter
- [ ] Status emoji matches status text
- [ ] Validation status matches overall status
- [ ] If failed, explanation is provided

### Format Compliance
- [ ] Markdown formatting is correct
- [ ] Code blocks use proper syntax highlighting
- [ ] Lists are properly formatted
- [ ] Headers use correct levels (H1, H2, H3)

---

## Usage by Workers

### Step 1: Create Report File

```markdown
Use the generate-report-header Skill to create the header.
```

### Step 2: Add YAML Frontmatter

```markdown
Add YAML frontmatter at the very beginning with all required metadata.
```

### Step 3: Fill Executive Summary

```markdown
Summarize key findings with 3-5 metrics.
```

### Step 4: Add Detailed Findings

```markdown
Follow report-type-specific structure for detailed findings.
```

### Step 5: Run Validations

```markdown
Run type-check, build, and optional tests. Document results.
```

### Step 6: Add Next Steps

```markdown
Provide specific, actionable next steps separated by priority.
```

### Step 7: Self-Validate

```markdown
Use validate-report-file Skill to check report completeness.
```

### Step 8: Save Report

```markdown
Save with standard naming: {report-type}-report-{version}.md
```

---

**Template Version**: 1.0
**Last Updated**: 2025-10-17
**Status**: ✅ COMPLETE - Standard Template for All Reports
**Next Task**: Task 3.4 - Create Verification Agent Spec (optional)
