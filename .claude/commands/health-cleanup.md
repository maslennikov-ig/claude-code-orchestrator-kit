---
description: Cleanup dead-code detection and remediation workflow with full cycle management
---

# Cleanup Health Check

> **PATTERN**: Agent-based orchestration (see `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md` for details)

Complete dead code detection and removal workflow with orchestrator-worker coordination.

**What it does:**
- Full dead code scan (unused imports, commented code, unreachable code, debug artifacts, unused variables)
- Staged removal (critical → high → medium → low)
- Quality gates after each stage
- Verification scan
- Up to 3 iterations if issues remain
- Comprehensive final report

**No configuration needed** - runs comprehensive dead code detection always.

---

## Your Task

### Step 1: Phase 0 - Invoke Orchestrator (Pre-flight)

Use Task tool to invoke dead-code-orchestrator for pre-flight validation:

```
subagent_type: "dead-code-orchestrator"
description: "Cleanup orchestrator pre-flight"
prompt: "Execute Phase 0: Pre-flight Validation

Tasks:
1. Validate environment (package.json, scripts, git status)
2. Initialize progress tracking via TodoWrite
3. Initialize iteration tracking (iteration=1, max=3)
4. Create .tmp/current/plans/dead-code-detection.json for rollback tracking
5. Report pre-flight status

IMPORTANT: After completing pre-flight, create .tmp/current/plans/dead-code-detection.json and return control to main session.

Return the following information:
- Pre-flight status (✅/⛔)
- Environment validation results
- Plan file path created
- Ready for next phase: true/false
"
```

**Then**: Wait for orchestrator to return.

---

### Step 2: Phase 1 - Invoke dead-code-hunter (Detection)

After orchestrator returns:

1. **Read plan file** to confirm it was created:
   ```
   Use Read tool: .tmp/current/plans/dead-code-detection.json
   Verify nextAgent === "dead-code-hunter"
   ```

2. **Invoke dead-code-hunter** using Task tool:
   ```
   subagent_type: "dead-code-hunter"
   description: "Dead code detection phase"
   prompt: "Execute dead-code detection based on plan file: .tmp/current/plans/dead-code-detection.json

Read the plan file and execute comprehensive dead-code detection:
- Scan entire codebase
- Categorize by priority (critical → high → medium → low)
- Generate dead-code-report.md

Return to main session when complete."
   ```

**Then**: Wait for dead-code-hunter to return with report.

---

### Step 3: Quality Gate 1 - Resume Orchestrator (Validate Detection)

After dead-code-hunter returns:

1. **Resume orchestrator** for validation using Task tool:
   ```
   subagent_type: "dead-code-orchestrator"
   description: "Validate dead-code detection"
   prompt: "Execute Quality Gate 1: Detection Validation

Phase: Validate dead-code-hunter output

Tasks:
1. Verify dead-code-report.md exists
2. Validate report structure (required sections)
3. Parse dead-code counts by priority
4. Run type-check validation (non-blocking warning)
5. Report gate results

IMPORTANT: After validation, if dead code found:
- Create .tmp/current/plans/cleanup-removal-{priority}.json for critical priority (or highest available)
- Return control to main session

If no dead code found or all gates fail:
- Skip to final summary
- Return control

Return the following:
- Gate status (✅ PASSED / ⛔ FAILED / ⚠️ WARNINGS)
- Dead code counts by priority
- Next phase: removal-critical / removal-high / final-summary
- Plan file created (if applicable)
"
   ```

**Then**: Wait for orchestrator validation results.

---

### Step 4: Phase 2-5 - Removal Stages (Iterative)

After orchestrator returns with fixing plan:

**For each priority level** (critical → high → medium → low):

1. **Check if this priority has dead code**:
   - Read orchestrator response
   - If orchestrator says "skip to next priority" → continue loop
   - If orchestrator says "final summary" → go to Step 5

2. **Read fixing plan**:
   ```
   Use Read tool: .tmp/current/plans/cleanup-removal-{priority}.json
   Verify nextAgent === "dead-code-remover"
   Verify config.priority === "{current-priority}"
   ```

3. **Invoke dead-code-remover** using Task tool:
   ```
   subagent_type: "dead-code-remover"
   description: "Remove {priority} dead code"
   prompt: "Execute dead code removal based on plan file: .tmp/current/plans/cleanup-removal-{priority}.json

Read the plan file and remove dead code for priority: {priority}
- Read dead-code-report.md for dead-code list
- Remove dead code one by one
- Log changes to .dead-code-changes.json
- Update dead-code-cleanup-summary.md (consolidated report)

Return to main session when complete."
   ```

4. **Resume orchestrator** for validation:
   ```
   subagent_type: "dead-code-orchestrator"
   description: "Validate {priority} fixes"
   prompt: "Execute Quality Gate 2: Removal Validation for priority={priority}

Tasks:
1. Verify dead-code-cleanup-summary.md exists
2. Run type-check (BLOCKING)
3. Run build (BLOCKING)
4. Parse removal success rate
5. Check if retry needed (if < 80% success)

If validation PASSES and more priorities remain:
- Create next .tmp/current/plans/cleanup-removal-{priority}.json
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
- Next phase: removal-{next-priority} / verification / final-summary
"
   ```

5. **Repeat** for next priority level.

---

### Step 5: Phase 6 - Verification

After all fixing stages complete:

1. **Resume orchestrator** for verification:
   ```
   subagent_type: "dead-code-orchestrator"
   description: "Create verification plan"
   prompt: "Execute Phase 6: Verification Preparation

Create .tmp/current/plans/dead-code-verification.json for re-scanning codebase.

Return control with plan file path."
   ```

2. **Invoke dead-code-hunter** for verification:
   ```
   subagent_type: "dead-code-hunter"
   description: "Verification scan"
   prompt: "Execute verification scan based on: .tmp/current/plans/dead-code-verification.json

Re-scan codebase to verify removals. Overwrites dead-code-report.md.

Return when complete."
   ```

3. **Resume orchestrator** for verification validation:
   ```
   subagent_type: "dead-code-orchestrator"
   description: "Validate verification"
   prompt: "Execute Quality Gate 3: Verification Validation

Compare original dead-code-report.md (baseline) with new scan:
- Count dead code removed
- Check if new dead code introduced
- Determine if iteration needed

Return:
- Verification status
- Dead code remaining
- Iteration decision: iterate / complete
"
   ```

---

### Step 6: Final Summary

After all phases complete:

1. **Resume orchestrator** for final summary:
   ```
   subagent_type: "dead-code-orchestrator"
   description: "Generate final summary"
   prompt: "Execute Phase 8: Final Summary

Generate comprehensive dead-code-orchestration-summary.md:
- All dead code detected
- All dead code removed
- Success rates by priority
- Validation results
- Iteration summary
- Archive and cleanup instructions

Return final summary."
   ```

2. **Display results** to user:
   ```
   Read dead-code-orchestration-summary.md
   Display key metrics
   Show validation status
   List next steps
   ```

---

## Example Usage

```bash
# Run complete dead code cleanup workflow
/health-cleanup
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
