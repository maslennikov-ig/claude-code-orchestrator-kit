---
description: Security vulnerability detection and remediation workflow with full cycle management
---

# Security Health Check

> **PATTERN**: Agent-based orchestration (see `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md` for details)

Complete security scanning and vulnerability fixing workflow with orchestrator-worker coordination.

**What it does:**
- Full security scan (SQL injection, XSS, auth issues, RLS policies, secrets)
- Staged fixing (critical → high → medium → low)
- Quality gates after each stage
- Verification scan
- Up to 3 iterations if issues remain
- Comprehensive final report

**No configuration needed** - runs comprehensive security audit always.

---

## Your Task

### Step 1: Phase 0 - Invoke Orchestrator (Pre-flight)

Use Task tool to invoke security-orchestrator for pre-flight validation:

```
subagent_type: "security-orchestrator"
description: "Security orchestrator pre-flight"
prompt: "Execute Phase 0: Pre-flight Validation

Tasks:
1. Validate environment (package.json, scripts, git status)
2. Initialize progress tracking via TodoWrite
3. Initialize iteration tracking (iteration=1, max=3)
4. Create .tmp/current/plans/security-detection.json for rollback tracking
5. Report pre-flight status

IMPORTANT: After completing pre-flight, create .tmp/current/plans/security-detection.json and return control to main session.

Return the following information:
- Pre-flight status (✅/⛔)
- Environment validation results
- Plan file path created
- Ready for next phase: true/false
"
```

**Then**: Wait for orchestrator to return.

---

### Step 2: Phase 1 - Invoke security-scanner (Detection)

After orchestrator returns:

1. **Read plan file** to confirm it was created:
   ```
   Use Read tool: .tmp/current/plans/security-detection.json
   Verify nextAgent === "security-scanner"
   ```

2. **Invoke security-scanner** using Task tool:
   ```
   subagent_type: "security-scanner"
   description: "Security detection phase"
   prompt: "Execute vulnerability detection based on plan file: .tmp/current/plans/security-detection.json

Read the plan file and execute comprehensive vulnerability detection:
- Scan entire codebase
- Categorize by priority (critical → high → medium → low)
- Generate security-scan-report.md

Return to main session when complete."
   ```

**Then**: Wait for security-scanner to return with report.

---

### Step 3: Quality Gate 1 - Resume Orchestrator (Validate Detection)

After security-scanner returns:

1. **Resume orchestrator** for validation using Task tool:
   ```
   subagent_type: "security-orchestrator"
   description: "Validate vulnerability detection"
   prompt: "Execute Quality Gate 1: Detection Validation

Phase: Validate security-scanner output

Tasks:
1. Verify security-scan-report.md exists
2. Validate report structure (required sections)
3. Parse vulnerability counts by priority
4. Run type-check validation (non-blocking warning)
5. Report gate results

IMPORTANT: After validation, if vulnerabilitys found:
- Create .tmp/current/plans/security-fixing-{priority}.json for critical priority (or highest available)
- Return control to main session

If no vulnerabilitys found or all gates fail:
- Skip to final summary
- Return control

Return the following:
- Gate status (✅ PASSED / ⛔ FAILED / ⚠️ WARNINGS)
- Security counts by priority
- Next phase: fixing-critical / fixing-high / final-summary
- Plan file created (if applicable)
"
   ```

**Then**: Wait for orchestrator validation results.

---

### Step 4: Phase 2-5 - Fixing Stages (Iterative)

After orchestrator returns with fixing plan:

**For each priority level** (critical → high → medium → low):

1. **Check if this priority has vulnerabilitys**:
   - Read orchestrator response
   - If orchestrator says "skip to next priority" → continue loop
   - If orchestrator says "final summary" → go to Step 5

2. **Read fixing plan**:
   ```
   Use Read tool: .tmp/current/plans/security-fixing-{priority}.json
   Verify nextAgent === "vulnerability-fixer"
   Verify config.priority === "{current-priority}"
   ```

3. **Invoke vulnerability-fixer** using Task tool:
   ```
   subagent_type: "vulnerability-fixer"
   description: "Fix {priority} vulnerabilitys"
   prompt: "Execute vulnerability fixing based on plan file: .tmp/current/plans/security-fixing-{priority}.json

Read the plan file and fix vulnerabilitys for priority: {priority}
- Read security-scan-report.md for vulnerability list
- Fix vulnerabilitys one by one
- Log changes to .vulnerability-changes.json
- Update security-fixes-implemented.md (consolidated report)

Return to main session when complete."
   ```

4. **Resume orchestrator** for validation:
   ```
   subagent_type: "security-orchestrator"
   description: "Validate {priority} fixes"
   prompt: "Execute Quality Gate 2: Fixes Validation for priority={priority}

Tasks:
1. Verify security-fixes-implemented.md exists
2. Run type-check (BLOCKING)
3. Run build (BLOCKING)
4. Parse fix success rate
5. Check if retry needed (if < 80% success)

If validation PASSES and more priorities remain:
- Create next .tmp/current/plans/security-fixing-{priority}.json
- Return control

If validation FAILS:
- Provide rollback instructions
- Return control with error

If all priorities complete:
- Proceed to verification phase
- Return control

Return:
- Gate status
- Fix success rate
- Next phase: fixing-{next-priority} / verification / final-summary
"
   ```

5. **Repeat** for next priority level.

---

### Step 5: Phase 6 - Verification

After all fixing stages complete:

1. **Resume orchestrator** for verification:
   ```
   subagent_type: "security-orchestrator"
   description: "Create verification plan"
   prompt: "Execute Phase 6: Verification Preparation

Create .tmp/current/plans/security-verification.json for re-scanning codebase.

Return control with plan file path."
   ```

2. **Invoke security-scanner** for verification:
   ```
   subagent_type: "security-scanner"
   description: "Verification scan"
   prompt: "Execute verification scan based on: .tmp/current/plans/security-verification.json

Re-scan codebase to verify fixes. Overwrites security-scan-report.md.

Return when complete."
   ```

3. **Resume orchestrator** for verification validation:
   ```
   subagent_type: "security-orchestrator"
   description: "Validate verification"
   prompt: "Execute Quality Gate 3: Verification Validation

Compare original security-scan-report.md (baseline) with new scan:
- Count vulnerabilitys fixed
- Check if new vulnerabilitys introduced
- Determine if iteration needed

Return:
- Verification status
- Securitys remaining
- Iteration decision: iterate / complete
"
   ```

---

### Step 6: Final Summary

After all phases complete:

1. **Resume orchestrator** for final summary:
   ```
   subagent_type: "security-orchestrator"
   description: "Generate final summary"
   prompt: "Execute Phase 8: Final Summary

Generate comprehensive security-orchestration-summary.md:
- All vulnerabilitys detected
- All vulnerabilitys fixed
- Success rates by priority
- Validation results
- Iteration summary
- Cleanup instructions

Return final summary."
   ```

2. **Display results** to user:
   ```
   Read security-orchestration-summary.md
   Display key metrics
   Show validation status
   List next steps
   ```

---

## Example Usage

```bash
# Run complete vulnerability workflow
/health-vulnerabilitys
```

---

## Architecture Notes

**Orchestrator Role**:
- Creates plan files
- Validates worker outputs
- Returns control to main session
- NO direct worker invocation

**Main Session Role** (this command):
- Reads plan files
- Invokes workers via Task tool
- Resumes orchestrator for validation
- Manages full cycle

**Worker Role**:
- Reads plan file
- Executes work
- Generates report
- Returns to main session

This pattern follows Claude Code's actual capabilities (no auto-invoke).
