---
description: Comprehensive dependency management with iterative update cycles workflow with full cycle management
---

# Dependency Health Check

> **PATTERN**: Agent-based orchestration (see `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md` for details)

Complete dependency audit and update workflow with orchestrator-worker coordination.

**What it does:**
- Full dependency audit (outdated packages, security dependency issues, unused dependencies)
- Staged updates (critical → high → medium → low)
- Quality gates after each stage
- Verification scan
- Up to 3 iterations if issues remain
- Comprehensive final report

**No configuration needed** - runs comprehensive dependency audit always.

---

## Your Task

### Step 1: Phase 0 - Invoke Orchestrator (Pre-flight)

Use Task tool to invoke dependency-orchestrator for pre-flight validation:

```
subagent_type: "dependency-orchestrator"
description: "Dependency orchestrator pre-flight"
prompt: "Execute Phase 0: Pre-flight Validation

Tasks:
1. Validate environment (package.json, scripts, git status)
2. Initialize progress tracking via TodoWrite
3. Initialize iteration tracking (iteration=1, max=3)
4. Create .tmp/current/plans/dependency-detection.json for rollback tracking
5. Report pre-flight status

IMPORTANT: After completing pre-flight, create .tmp/current/plans/dependency-detection.json and return control to main session.

Return the following information:
- Pre-flight status (✅/⛔)
- Environment validation results
- Plan file path created
- Ready for next phase: true/false
"
```

**Then**: Wait for orchestrator to return.

---

### Step 2: Phase 1 - Invoke dependency-auditor (Detection)

After orchestrator returns:

1. **Read plan file** to confirm it was created:
   ```
   Use Read tool: .tmp/current/plans/dependency-detection.json
   Verify nextAgent === "dependency-auditor"
   ```

2. **Invoke dependency-auditor** using Task tool:
   ```
   subagent_type: "dependency-auditor"
   description: "Dependency audit phase"
   prompt: "Execute dependency audit based on plan file: .tmp/current/plans/dependency-detection.json

Read the plan file and execute comprehensive dependency audit:
- Scan entire codebase
- Categorize by priority (critical → high → medium → low)
- Generate dependency-scan-report.md

Return to main session when complete."
   ```

**Then**: Wait for dependency-auditor to return with report.

---

### Step 3: Quality Gate 1 - Resume Orchestrator (Validate Detection)

After dependency-auditor returns:

1. **Resume orchestrator** for validation using Task tool:
   ```
   subagent_type: "dependency-orchestrator"
   description: "Validate dependency audit"
   prompt: "Execute Quality Gate 1: Detection Validation

Phase: Validate dependency-auditor output

Tasks:
1. Verify dependency-scan-report.md exists
2. Validate report structure (required sections)
3. Parse dependency issue counts by priority
4. Run type-check validation (non-blocking warning)
5. Report gate results

IMPORTANT: After validation, if dependency issues found:
- Create .tmp/current/plans/dependency-update-{priority}.json for critical priority (or highest available)
- Return control to main session

If no dependency issues found or all gates fail:
- Skip to final summary
- Return control

Return the following:
- Gate status (✅ PASSED / ⛔ FAILED / ⚠️ WARNINGS)
- Security counts by priority
- Next phase: update-critical / update-high / final-summary
- Plan file created (if applicable)
"
   ```

**Then**: Wait for orchestrator validation results.

---

### Step 4: Phase 2-5 - Update Stages (Iterative)

After orchestrator returns with update plan:

**For each priority level** (critical → high → medium → low):

1. **Check if this priority has dependency issues**:
   - Read orchestrator response
   - If orchestrator says "skip to next priority" → continue loop
   - If orchestrator says "final summary" → go to Step 5

2. **Read update plan**:
   ```
   Use Read tool: .tmp/current/plans/dependency-update-{priority}.json
   Verify nextAgent === "dependency issue-fixer"
   Verify config.priority === "{current-priority}"
   ```

3. **Invoke dependency issue-fixer** using Task tool:
   ```
   subagent_type: "dependency issue-fixer"
   description: "Update {priority} dependencies"
   prompt: "Execute dependency issue update based on plan file: .tmp/current/plans/dependency-update-{priority}.json

Read the plan file and fix dependency issues for priority: {priority}
- Read dependency-scan-report.md for dependency issue list
- Fix dependency issues one by one
- Log changes to .dependency issue-changes.json
- Update dependency-updates-implemented.md (consolidated report)

Return to main session when complete."
   ```

4. **Resume orchestrator** for validation:
   ```
   subagent_type: "dependency-orchestrator"
   description: "Validate {priority} updates"
   prompt: "Execute Quality Gate 2: Updates Validation for priority={priority}

Tasks:
1. Verify dependency-updates-implemented.md exists
2. Run type-check (BLOCKING)
3. Run build (BLOCKING)
4. Parse fix success rate
5. Check if retry needed (if < 80% success)

If validation PASSES and more priorities remain:
- Create next .tmp/current/plans/dependency-update-{priority}.json
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
- Next phase: update-{next-priority} / verification / final-summary
"
   ```

5. **Repeat** for next priority level.

---

### Step 5: Phase 6 - Verification

After all update stages complete:

1. **Resume orchestrator** for verification:
   ```
   subagent_type: "dependency-orchestrator"
   description: "Create verification plan"
   prompt: "Execute Phase 6: Verification Preparation

Create .tmp/current/plans/dependency-verification.json for re-scanning codebase.

Return control with plan file path."
   ```

2. **Invoke dependency-auditor** for verification:
   ```
   subagent_type: "dependency-auditor"
   description: "Verification scan"
   prompt: "Execute verification scan based on: .tmp/current/plans/dependency-verification.json

Re-scan codebase to verify updates. Overwrites dependency-scan-report.md.

Return when complete."
   ```

3. **Resume orchestrator** for verification validation:
   ```
   subagent_type: "dependency-orchestrator"
   description: "Validate verification"
   prompt: "Execute Quality Gate 3: Verification Validation

Compare original dependency-scan-report.md (baseline) with new scan:
- Count dependency issues fixed
- Check if new dependency issues introduced
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
   subagent_type: "dependency-orchestrator"
   description: "Generate final summary"
   prompt: "Execute Phase 8: Final Summary

Generate comprehensive dependency-orchestration-summary.md:
- All dependency issues detected
- All dependency issues fixed
- Success rates by priority
- Validation results
- Iteration summary
- Cleanup instructions

Return final summary."
   ```

2. **Display results** to user:
   ```
   Read dependency-orchestration-summary.md
   Display key metrics
   Show validation status
   List next steps
   ```

---

## Example Usage

```bash
# Run complete dependency issue workflow
/health-dependency issues
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
