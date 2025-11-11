# Quality Gates Specification

**Date Created**: 2025-10-16
**Phase**: 2 - Task 2.4
**Status**: Complete
**Context**: Master Agent Ecosystem Refactoring

---

## Executive Summary

This document defines **Quality Gates** for all orchestrated workflows in our Claude Code project. Quality Gates are validation checkpoints that ensure work meets quality standards before proceeding to the next phase.

**Key Principle**: Block progression on critical failures, warn on non-critical issues.

**Source**: Research from vanzan01/claude-code-sub-agent-collective

---

## Table of Contents

1. [What Are Quality Gates?](#what-are-quality-gates)
2. [Gate Types](#gate-types)
3. [Domain-Specific Gates](#domain-specific-gates)
4. [Implementation Pattern](#implementation-pattern)
5. [Thresholds and Metrics](#thresholds-and-metrics)
6. [Failure Handling](#failure-handling)
7. [Override Mechanisms](#override-mechanisms)

---

## What Are Quality Gates?

### Definition

A **Quality Gate** is a validation checkpoint between workflow phases that:
- Verifies phase completion
- Checks quality metrics against thresholds
- Blocks progression if critical criteria fail
- Warns if non-critical criteria fail
- Provides clear pass/fail status

### Purpose

Quality Gates ensure:
1. **Quality**: Work meets minimum standards before progressing
2. **Safety**: Critical failures are caught early
3. **Visibility**: Users see validation results explicitly
4. **Control**: Users can override with explicit confirmation

### Gate Structure

Every Quality Gate has:

```yaml
gate_name:
  phase: N
  description: "What this gate validates"

  blocking_criteria:
    - criterion: "Specific check"
      command: "Command to verify"
      threshold: "Pass threshold"
      failure_action: "What to do if fails"

  non_blocking_criteria:
    - criterion: "Best practice check"
      command: "Command to verify"
      warning: "Warning message if fails"

  on_failure:
    - "Step 1 for recovery"
    - "Step 2 for recovery"
    - "User override option"
```

---

## Gate Types

### Type 1: Blocking Gates

**Characteristics**:
- ⛔ STOPS workflow progression if criteria fail
- Used for critical quality standards
- Requires user intervention (fix or skip)
- Logged with high severity

**Examples**:
- Type check failures
- Build failures
- Critical test failures
- Critical security vulnerabilities
- RLS policies missing

**User Experience**:
```
⛔ Quality Gate BLOCKED: Phase 2 Validation

❌ Type Check: FAILED
   - 5 type errors in src/components/
   - See output above for details

❌ Build: FAILED
   - Compilation error in src/utils/version.ts

Action Required:
1. Fix the errors listed above
2. Re-run the orchestrator to retry

Or: Type "skip" to proceed anyway (not recommended)
```

### Type 2: Non-Blocking Gates

**Characteristics**:
- ⚠️ WARNS but allows progression
- Used for best practices and recommendations
- Logged in summary report
- User can address later

**Examples**:
- Performance benchmarks below target
- Code coverage below 80%
- Non-critical security issues
- Documentation incomplete
- Code style violations

**User Experience**:
```
⚠️ Quality Gate Warning: Phase 2 Validation

✅ Type Check: PASSED
✅ Build: PASSED
⚠️ Code Coverage: 72% (target: 80%)
⚠️ Performance: Response time 350ms (target: 200ms)

Workflow will continue, but please address warnings:
- Increase test coverage to 80%
- Optimize response time to meet target
```

---

## Domain-Specific Gates

### Bugs Domain

#### Gate 1: Detection Complete

**Phase**: After bug-hunter execution

**Blocking Criteria**:
```yaml
- criterion: "Report file exists"
  command: "test -f bug-hunting-report.md"
  threshold: "File exists"
  failure_action: "Report bug-hunter failure, ask to retry"

- criterion: "Report is well-formed"
  command: "grep -q '## Executive Summary' bug-hunting-report.md"
  threshold: "Contains required sections"
  failure_action: "Report format error, ask bug-hunter to regenerate"

- criterion: "Validation status is PASSED"
  command: "grep -q 'Validation.*PASSED' bug-hunting-report.md"
  threshold: "PASSED status present"
  failure_action: "Bug detection validation failed, review report"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "High-priority bugs documented"
  warning: "No high-priority bugs found - verify thoroughness"

- criterion: "Bug patterns identified"
  warning: "No patterns identified - consider deeper analysis"
```

**Pass Threshold**: All blocking criteria met

**On Failure**:
1. ⛔ STOP - Do not proceed to Phase 2 (Bug Fixing)
2. Report which criteria failed with details
3. Show error messages from commands
4. Ask user: "Fix issues and retry bug-hunter? (y/N)"
5. If "N": Exit workflow with error summary

---

#### Gate 2: Fixes Applied

**Phase**: After bug-fixer execution

**Blocking Criteria**:
```yaml
- criterion: "Type check passes"
  command: "pnpm type-check"
  threshold: "Exit code 0, no errors"
  failure_action: "Fixes introduced new type errors"

- criterion: "Build succeeds"
  command: "pnpm build"
  threshold: "Exit code 0, no errors"
  failure_action: "Fixes broke the build"

- criterion: "Fixes report exists"
  command: "test -f bug-fixing-report.md"
  threshold: "File exists"
  failure_action: "Bug-fixer didn't generate report"

- criterion: "Critical bugs fixed"
  command: "grep -q 'Critical.*Fixed' bug-fixing-report.md"
  threshold: "All critical bugs addressed"
  failure_action: "Critical bugs remain unfixed"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Tests pass"
  command: "pnpm test"
  warning: "Some tests failing - review test failures"

- criterion: "Linting passes"
  command: "pnpm lint"
  warning: "Linting issues remain"
```

**Pass Threshold**: All blocking criteria met

**On Failure**:
1. ⛔ STOP - Do not proceed to Phase 3 (Verification)
2. Report which criteria failed
3. Show command output
4. Ask user: "Rollback changes and retry? (y/N)"
5. If "N": Ask "Skip validation and continue? (not recommended)"

---

#### Gate 3: Verification

**Phase**: After bug-hunter verification scan

**Blocking Criteria**:
```yaml
- criterion: "Zero critical bugs remain"
  command: "grep -q 'Critical.*0' bug-hunting-report.md"
  threshold: "0 critical bugs"
  failure_action: "Critical bugs still present after fixes"

- criterion: "Type check still passes"
  command: "pnpm type-check"
  threshold: "Exit code 0"
  failure_action: "Type check regressed"

- criterion: "Build still succeeds"
  command: "pnpm build"
  threshold: "Exit code 0"
  failure_action: "Build regressed"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Zero high-priority bugs remain"
  warning: "High-priority bugs still present"

- criterion: "No new bugs introduced"
  warning: "New bugs detected by verification scan"
```

**Pass Threshold**: All blocking criteria met

---

### Security Domain

#### Gate 1: Audit Complete

**Phase**: After security-scanner execution

**Blocking Criteria**:
```yaml
- criterion: "Report file exists"
  command: "test -f security-audit-report.md"
  threshold: "File exists"
  failure_action: "Security scanner didn't complete"

- criterion: "Report is well-formed"
  command: "grep -q '## Executive Summary' security-audit-report.md"
  threshold: "Contains required sections"
  failure_action: "Report format error"

- criterion: "Vulnerabilities categorized"
  command: "grep -E '(Critical|High|Medium|Low)' security-audit-report.md"
  threshold: "Categories present"
  failure_action: "Vulnerabilities not properly categorized"

- criterion: "Validation status is PASSED"
  command: "grep -q 'Validation.*PASSED' security-audit-report.md"
  threshold: "PASSED status present"
  failure_action: "Security scan validation failed"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Zero critical vulnerabilities"
  warning: "Critical vulnerabilities found - immediate attention required"

- criterion: "RLS policies reviewed"
  warning: "RLS policy review incomplete"
```

**Pass Threshold**: All blocking criteria met

---

#### Gate 2: Critical Fixes Applied

**Phase**: After vulnerability-fixer execution (critical only)

**Blocking Criteria**:
```yaml
- criterion: "RLS policies added/fixed"
  command: "grep -q 'RLS.*Fixed' security-fixing-report.md"
  threshold: "RLS issues addressed"
  failure_action: "RLS policies not fixed"

- criterion: "Authentication fixed"
  command: "grep -q 'Authentication.*Fixed' security-fixing-report.md"
  threshold: "Auth issues addressed"
  failure_action: "Authentication vulnerabilities remain"

- criterion: "Credentials secured"
  command: "! grep -r 'password.*=.*[\"']' src/ --exclude-dir=node_modules"
  threshold: "No hardcoded credentials"
  failure_action: "Hardcoded credentials still present"

- criterion: "Type check passes"
  command: "pnpm type-check"
  threshold: "Exit code 0"
  failure_action: "Security fixes broke type check"

- criterion: "Build succeeds"
  command: "pnpm build"
  threshold: "Exit code 0"
  failure_action: "Security fixes broke build"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "npm audit clean"
  command: "npm audit --audit-level=critical"
  warning: "Critical npm vulnerabilities remain"

- criterion: "Input validation added"
  warning: "Input validation improvements incomplete"
```

**Pass Threshold**: All blocking criteria met

---

#### Gate 3: Verification

**Phase**: After security-scanner verification scan

**Blocking Criteria**:
```yaml
- criterion: "Zero critical vulnerabilities"
  command: "grep -q 'Critical.*0' security-audit-report.md"
  threshold: "0 critical vulnerabilities"
  failure_action: "Critical vulnerabilities still present"

- criterion: "No new vulnerabilities introduced"
  command: "Compare previous vs current vulnerability count"
  threshold: "Count not increased"
  failure_action: "Fixes introduced new vulnerabilities"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "High-priority vulnerabilities reduced"
  warning: "High-priority vulnerabilities still present"
```

**Pass Threshold**: All blocking criteria met

---

### Dead-Code Domain

#### Gate 1: Detection Complete

**Phase**: After dead-code-hunter execution

**Blocking Criteria**:
```yaml
- criterion: "Report file exists"
  command: "test -f dead-code-report.md"
  threshold: "File exists"
  failure_action: "Dead-code hunter didn't complete"

- criterion: "Report is well-formed"
  command: "grep -q '## Executive Summary' dead-code-report.md"
  threshold: "Contains required sections"
  failure_action: "Report format error"

- criterion: "Dead code categorized"
  command: "grep -E '(Unused|Unreachable|Commented)' dead-code-report.md"
  threshold: "Categories present"
  failure_action: "Dead code not properly categorized"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Dead code detected"
  warning: "No dead code found - verify scan was thorough"
```

**Pass Threshold**: All blocking criteria met

---

#### Gate 2: Cleanup Applied

**Phase**: After dead-code-remover execution

**Blocking Criteria**:
```yaml
- criterion: "Build succeeds"
  command: "pnpm build"
  threshold: "Exit code 0"
  failure_action: "Dead code removal broke build"

- criterion: "Type check passes"
  command: "pnpm type-check"
  threshold: "Exit code 0"
  failure_action: "Dead code removal broke type check"

- criterion: "Cleanup report exists"
  command: "test -f dead-code-cleanup-report.md"
  threshold: "File exists"
  failure_action: "Dead-code remover didn't generate report"

- criterion: "Files removed documented"
  command: "grep -q 'Files Removed' dead-code-cleanup-report.md"
  threshold: "Removal stats present"
  failure_action: "Cleanup stats missing"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Tests still pass"
  command: "pnpm test"
  warning: "Some tests failing after cleanup"

- criterion: "No new dead code"
  warning: "Cleanup introduced new dead code"
```

**Pass Threshold**: All blocking criteria met

---

#### Gate 3: Verification

**Phase**: After dead-code-hunter verification scan

**Blocking Criteria**:
```yaml
- criterion: "Build still succeeds"
  command: "pnpm build"
  threshold: "Exit code 0"
  failure_action: "Build regressed"

- criterion: "No new dead code detected"
  command: "Compare previous vs current dead code count"
  threshold: "Count not increased"
  failure_action: "Cleanup incomplete or introduced new dead code"
```

**Pass Threshold**: All blocking criteria met

---

### Dependencies Domain

#### Gate 1: Audit Complete

**Phase**: After dependency-auditor execution

**Blocking Criteria**:
```yaml
- criterion: "Report file exists"
  command: "test -f dependency-audit-report.md"
  threshold: "File exists"
  failure_action: "Dependency auditor didn't complete"

- criterion: "Report is well-formed"
  command: "grep -q '## Executive Summary' dependency-audit-report.md"
  threshold: "Contains required sections"
  failure_action: "Report format error"

- criterion: "Dependencies categorized"
  command: "grep -E '(Outdated|Vulnerable|Unused)' dependency-audit-report.md"
  threshold: "Categories present"
  failure_action: "Dependencies not properly categorized"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Zero critical CVEs"
  warning: "Critical CVEs found - immediate update required"

- criterion: "Dependencies reasonably current"
  warning: "Many outdated dependencies - consider updates"
```

**Pass Threshold**: All blocking criteria met

---

#### Gate 2: Updates Applied

**Phase**: After dependency-updater execution (critical only)

**Blocking Criteria**:
```yaml
- criterion: "Critical CVEs patched"
  command: "npm audit --audit-level=critical"
  threshold: "Exit code 0 or <5 critical"
  failure_action: "Critical CVEs still present"

- criterion: "package.json updated"
  command: "git diff --exit-code package.json"
  threshold: "File modified (exit code 1)"
  failure_action: "No updates applied to package.json"

- criterion: "Dependencies installed"
  command: "test -d node_modules"
  threshold: "Directory exists"
  failure_action: "npm install not run"

- criterion: "Build succeeds"
  command: "pnpm build"
  threshold: "Exit code 0"
  failure_action: "Updates broke build"

- criterion: "Type check passes"
  command: "pnpm type-check"
  threshold: "Exit code 0"
  failure_action: "Updates broke type check"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "Tests pass"
  command: "pnpm test"
  warning: "Some tests failing after updates"

- criterion: "No breaking changes"
  warning: "Major version updates may have breaking changes"
```

**Pass Threshold**: All blocking criteria met

---

#### Gate 3: Verification

**Phase**: After dependency-auditor verification scan

**Blocking Criteria**:
```yaml
- criterion: "npm audit clean (critical)"
  command: "npm audit --audit-level=critical"
  threshold: "<5 critical CVEs"
  failure_action: "Critical CVEs remain"

- criterion: "Build still succeeds"
  command: "pnpm build"
  threshold: "Exit code 0"
  failure_action: "Build regressed"
```

**Non-Blocking Criteria**:
```yaml
- criterion: "All CVEs addressed"
  command: "npm audit"
  warning: "Some non-critical CVEs remain"
```

**Pass Threshold**: All blocking criteria met

---

## Implementation Pattern

### Orchestrator Integration

Quality Gates are implemented in orchestrator prompts:

```markdown
## Phase 2: Quality Gate - {Phase Name}

### Blocking Validation

Run the following checks (exit if any fail):

1. **Check 1: {Criterion}**
   ```bash
   {command}
   ```
   Expected: {threshold}
   If fails: ⛔ STOP - {failure_action}

2. **Check 2: {Criterion}**
   ```bash
   {command}
   ```
   Expected: {threshold}
   If fails: ⛔ STOP - {failure_action}

### Non-Blocking Validation

Run the following checks (warn if any fail):

1. **Check 1: {Criterion}**
   ```bash
   {command}
   ```
   Expected: {threshold}
   If fails: ⚠️ WARNING - {warning}

### Gate Result

If ALL blocking criteria pass:
  ✅ Quality Gate PASSED - Proceeding to Phase {N+1}
  Update TodoWrite: Mark Phase {N} complete

If ANY blocking criterion fails:
  ⛔ Quality Gate BLOCKED - Workflow stopped
  Update TodoWrite: Mark Phase {N} failed
  Report to user:
    "Quality Gate blocked on Phase {N}.

    Failed criteria:
    - {criterion1}: {details}
    - {criterion2}: {details}

    Actions:
    1. Fix the issues listed above
    2. Re-run orchestrator to retry

    Or: Type 'skip' to bypass validation (not recommended)"

If non-blocking criteria fail:
  Add warnings to summary report
  Continue to next phase
```

---

## Thresholds and Metrics

### Numeric Thresholds

| Domain | Metric | Blocking Threshold | Non-Blocking Target |
|--------|--------|-------------------|---------------------|
| **Bugs** | Critical bugs | 0 | 0 |
| **Bugs** | High-priority bugs | N/A | 0 |
| **Bugs** | Type errors | 0 | 0 |
| **Security** | Critical CVEs | <5 | 0 |
| **Security** | High CVEs | N/A | <10 |
| **Security** | Missing RLS policies | 0 | 0 |
| **Dependencies** | Critical CVEs | <5 | 0 |
| **Dependencies** | Outdated (major) | N/A | <3 |
| **Code Quality** | Build success | 100% | 100% |
| **Code Quality** | Type check success | 100% | 100% |
| **Code Quality** | Test pass rate | N/A | >90% |
| **Code Quality** | Code coverage | N/A | >80% |

### Threshold Philosophy

**Blocking Thresholds**:
- Set at level where failure causes immediate problems
- Type errors, build failures → Always blocking
- Critical security issues → Always blocking
- Critical bugs → Always blocking

**Non-Blocking Targets**:
- Set at aspirational level
- Best practices, code quality → Non-blocking
- Performance, coverage → Non-blocking
- User can address over time

---

## Failure Handling

### Failure Response Flow

```
1. Quality Gate runs validation checks
   ↓
2. Check fails
   ↓
3. Capture failure details:
   - Which criterion failed
   - Command output
   - Expected vs actual
   ↓
4. Determine severity:
   - Blocking → STOP workflow
   - Non-blocking → Log warning, continue
   ↓
5. Report to user:
   - Show failure details
   - Provide corrective actions
   - Offer override option (blocking only)
   ↓
6. Wait for user decision:
   - Fix: Exit workflow, user fixes, reruns
   - Skip: Add warning to summary, continue
   - Abort: Exit workflow with error
```

### Error Message Template

**Blocking Failure**:
```
⛔ QUALITY GATE BLOCKED: Phase {N} - {Gate Name}

Failed Criteria:

❌ {Criterion 1}
   Command: {command}
   Expected: {threshold}
   Actual: {actual_output}
   Details: {error_message}

❌ {Criterion 2}
   Command: {command}
   Expected: {threshold}
   Actual: {actual_output}
   Details: {error_message}

Corrective Actions:
1. {Action 1}
2. {Action 2}
3. Re-run orchestrator after fixes

Override:
Type "skip" to bypass validation (NOT RECOMMENDED - may cause issues)
```

**Non-Blocking Warning**:
```
⚠️ QUALITY GATE WARNING: Phase {N} - {Gate Name}

Warning Criteria:

⚠️ {Criterion 1}
   Command: {command}
   Expected: {target}
   Actual: {actual_output}
   Recommendation: {recommendation}

⚠️ {Criterion 2}
   Command: {command}
   Expected: {target}
   Actual: {actual_output}
   Recommendation: {recommendation}

Workflow will continue. Please address warnings in future iterations.
```

---

## Override Mechanisms

### When to Allow Override

**Blocking Gates CAN be overridden when**:
- User explicitly requests "skip"
- User accepts responsibility for potential issues
- Situation is time-sensitive or urgent
- User has expert knowledge of why it's safe

**Blocking Gates CANNOT be overridden when**:
- Security critical (e.g., RLS policies, authentication)
- Data safety critical (e.g., destructive operations)
- System stability critical (e.g., build must succeed for deploy)

### Override Process

1. **User Requests Override**:
   ```
   User: "skip validation"
   ```

2. **Orchestrator Confirms**:
   ```
   ⚠️ WARNING: Skipping Quality Gate

   You are bypassing blocking validation:
   - {Criterion 1}: FAILED
   - {Criterion 2}: FAILED

   This may cause:
   - {Risk 1}
   - {Risk 2}

   Are you sure? Type "confirm skip" to proceed.
   ```

3. **User Confirms**:
   ```
   User: "confirm skip"
   ```

4. **Orchestrator Logs and Continues**:
   ```
   ⚠️ Quality Gate OVERRIDDEN by user

   Adding to summary report:
   - Phase {N} validation was SKIPPED
   - Risks: {risks}
   - User accepted responsibility

   Proceeding to Phase {N+1}...
   ```

### Override Logging

All overrides are logged in:
1. **TodoWrite**: Warning marker on phase
2. **Summary Report**: Dedicated "Overrides" section
3. **Console Output**: Clear warning banner

**Summary Report Section**:
```markdown
## ⚠️ Quality Gate Overrides

### Phase 2: Bug Fixing Validation (SKIPPED)

**Failed Criteria**:
- Type check: 3 errors
- Build: 1 error

**Risks Accepted**:
- May introduce runtime errors
- May break downstream code

**User Decision**: Accepted override on 2025-10-16 14:30:00
```

---

## Testing Quality Gates

### Unit Testing (Per Gate)

Test each gate criterion individually:

```bash
# Test blocking criterion
{command}
if [ $? -ne 0 ]; then
  echo "✅ Gate correctly blocks on failure"
else
  echo "❌ Gate should block but didn't"
fi

# Test non-blocking criterion
{command}
if [ $? -ne 0 ]; then
  echo "✅ Gate correctly warns on failure"
  # Verify workflow continues
else
  echo "✅ Gate passes"
fi
```

### Integration Testing (With Orchestrators)

Test gates within orchestrator workflows:

```bash
# Create failing condition
echo "Introduce type error in src/test.ts"

# Run orchestrator
/health bugs

# Expected: Gate blocks at Phase 2
# Expected: Error message shows type error details
# Expected: Offers fix/skip options

# Fix the error
"Fix type error"

# Re-run orchestrator
/health bugs

# Expected: Gate passes
# Expected: Workflow continues to Phase 3
```

### Validation Checklist

For each Quality Gate:
- [ ] Blocking criteria defined
- [ ] Non-blocking criteria defined
- [ ] Thresholds are testable
- [ ] Commands are correct
- [ ] Failure actions are clear
- [ ] Override mechanism works
- [ ] Logging captures details
- [ ] Integration tested with orchestrator

---

## Maintenance

### Updating Thresholds

**When to Update**:
- Project quality improves → Raise thresholds
- Thresholds too strict → Lower thresholds
- New tools available → Add criteria
- Old tools deprecated → Remove criteria

**Process**:
1. Propose threshold change in issue/PR
2. Document rationale
3. Update this specification
4. Update affected orchestrators
5. Test with realistic scenarios
6. Announce change to team

### Adding New Gates

**When to Add**:
- New domain orchestrators added
- New phases added to existing orchestrators
- New validation tools become available

**Process**:
1. Define gate following template
2. Identify blocking vs non-blocking criteria
3. Set thresholds based on team standards
4. Document in this specification
5. Implement in orchestrator
6. Test thoroughly

---

**Document Status**: Complete - Ready for Phase 4 Implementation
**Next Phase**: Phase 3 - Implementation Planning

---

## Custom Quality Gates

**Added**: 2025-10-18 (Phase 4 - Task 4.3)

Custom quality gates allow projects to add domain-specific validation beyond the standard gates (type-check, build, tests, lint).

### Using Custom Gates

Use the **run-quality-gate** Skill with `gate="custom"`:

```markdown
Use run-quality-gate Skill:
- gate: "custom"
- custom_command: "your-command-here"
- blocking: true|false
```

### Common Custom Gates

#### 1. Bundle Size Check

**Purpose**: Ensure production bundle stays within size limits

**Configuration**:
```json
{
  "gate": "custom",
  "custom_command": "npm run check-bundle-size",
  "blocking": false
}
```

**Example Script** (package.json):
```json
{
  "scripts": {
    "check-bundle-size": "bundlewatch --config .bundlewatch.json"
  }
}
```

**.bundlewatch.json**:
```json
{
  "files": [
    {
      "path": "dist/bundle.js",
      "maxSize": "500kb"
    }
  ]
}
```

**Interpretation**:
- ✅ Pass: Bundle size < 500KB
- ⛔ Fail (non-blocking): Bundle size > 500KB, warn user
- Action: Review bundle contents, remove unused imports

---

#### 2. Performance Benchmark (Lighthouse CI)

**Purpose**: Validate performance metrics for critical pages

**Configuration**:
```json
{
  "gate": "custom",
  "custom_command": "npm run lighthouse-ci",
  "blocking": false
}
```

**Example Script** (package.json):
```json
{
  "scripts": {
    "lighthouse-ci": "lhci autorun --config=lighthouserc.json"
  }
}
```

**lighthouserc.json**:
```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/"],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["warn", {"minScore": 0.9}]
      }
    }
  }
}
```

**Interpretation**:
- ✅ Pass: Performance score > 90, Accessibility > 90
- ⚠️ Warn: Accessibility < 90 (non-blocking)
- ⛔ Fail: Performance < 90 (non-blocking, but should investigate)

---

#### 3. Security Scan (npm audit)

**Purpose**: Check for high/critical vulnerabilities in dependencies

**Configuration**:
```json
{
  "gate": "custom",
  "custom_command": "npm audit --audit-level=high",
  "blocking": true
}
```

**Interpretation**:
- ✅ Pass: No high/critical vulnerabilities
- ⛔ Fail (blocking): High/critical vulnerabilities found, MUST fix before merging

---

#### 4. Code Coverage

**Purpose**: Ensure test coverage meets minimum threshold

**Configuration**:
```json
{
  "gate": "custom",
  "custom_command": "npm run test:coverage -- --coverage-threshold=80",
  "blocking": false
}
```

**Example Script** (package.json):
```json
{
  "scripts": {
    "test:coverage": "jest --coverage"
  }
}
```

**jest.config.js**:
```javascript
module.exports = {
  coverageThresholds: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
}
```

**Interpretation**:
- ✅ Pass: Coverage > 80% for all metrics
- ⚠️ Warn: Coverage < 80% (non-blocking, but should improve)

---

#### 5. API Contract Validation

**Purpose**: Ensure API responses match OpenAPI/GraphQL schema

**Configuration**:
```json
{
  "gate": "custom",
  "custom_command": "npm run validate-api-contracts",
  "blocking": true
}
```

**Example Script**:
```bash
#!/bin/bash
# validate-api-contracts.sh

# Start test server
npm run start:test &
SERVER_PID=$!

# Wait for server
sleep 5

# Run validation
npx @openapitools/openapi-generator-cli validate -i openapi.yaml

EXIT_CODE=$?

# Cleanup
kill $SERVER_PID

exit $EXIT_CODE
```

**Interpretation**:
- ✅ Pass: API responses match schema
- ⛔ Fail (blocking): Schema mismatch, fix before merging

---

#### 6. Accessibility Audit (axe-core)

**Purpose**: Check for accessibility violations

**Configuration**:
```json
{
  "gate": "custom",
  "custom_command": "npm run test:a11y",
  "blocking": false
}
```

**Example Script** (package.json):
```json
{
  "scripts": {
    "test:a11y": "jest --testMatch='**/*.a11y.test.ts'"
  }
}
```

**Example Test** (Home.a11y.test.ts):
```typescript
import { axe, toHaveNoViolations } from 'jest-axe'
import { render } from '@testing-library/react'
import Home from './Home'

expect.extend(toHaveNoViolations)

test('Home page should have no accessibility violations', async () => {
  const { container } = render(<Home />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

**Interpretation**:
- ✅ Pass: No accessibility violations
- ⚠️ Warn: Violations found (non-blocking, should fix)

---

### Creating Custom Gate Scripts

**Location**: `.claude/scripts/gates/{gate-name}.sh`

**Template**:
```bash
#!/bin/bash
# .claude/scripts/gates/{gate-name}.sh

set -e

echo "Running {gate-name} validation..."

# Your validation logic here
# Example: Check file exists
if [ ! -f "required-file.txt" ]; then
  echo "Error: required-file.txt not found"
  exit 1
fi

# Example: Run command and check output
OUTPUT=$(your-command 2>&1)
if echo "$OUTPUT" | grep -q "ERROR"; then
  echo "Validation failed: $OUTPUT"
  exit 1
fi

echo "✅ {gate-name} validation passed"
exit 0
```

**Usage in Orchestrator**:
```markdown
Use run-quality-gate Skill:
- gate: "custom"
- custom_command: "bash .claude/scripts/gates/my-gate.sh"
- blocking: true
```

---

### Custom Gate Best Practices

1. **Make Scripts Idempotent**: Scripts should produce same result when run multiple times
2. **Fast Execution**: Custom gates should complete in < 5 minutes
3. **Clear Output**: Print clear success/failure messages
4. **Exit Codes**: Use 0 for success, non-zero for failure
5. **Dependencies**: Document required tools in gate script comments
6. **Thresholds**: Make thresholds configurable via environment variables

**Example with Configurable Threshold**:
```bash
#!/bin/bash
BUNDLE_SIZE_LIMIT=${BUNDLE_SIZE_LIMIT:-500000}  # Default 500KB

ACTUAL_SIZE=$(wc -c < dist/bundle.js)

if [ "$ACTUAL_SIZE" -gt "$BUNDLE_SIZE_LIMIT" ]; then
  echo "Bundle size ($ACTUAL_SIZE bytes) exceeds limit ($BUNDLE_SIZE_LIMIT bytes)"
  exit 1
fi

echo "✅ Bundle size OK: $ACTUAL_SIZE bytes (limit: $BUNDLE_SIZE_LIMIT bytes)"
exit 0
```

---

### Integration with Orchestrators

Orchestrators can use custom gates in their quality gate phases:

**Example** (bug-orchestrator):
```markdown
## Phase 4: Quality Gate - Custom Validations

Use run-quality-gate Skill with these custom gates:

1. Bundle size check (non-blocking):
   - gate: "custom"
   - custom_command: "npm run check-bundle-size"
   - blocking: false

2. Security audit (blocking):
   - gate: "custom"
   - custom_command: "npm audit --audit-level=high"
   - blocking: true

If any blocking gate fails:
- STOP workflow
- Report failure to user
- Provide fix instructions
- Ask: "Fix issues or skip validation?"
```

---

**Custom Gates Status**: Documented and Ready for Use
**Next Steps**: Teams can add project-specific custom gates as needed
