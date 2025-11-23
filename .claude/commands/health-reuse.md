---
description: Code reuse detection and consolidation workflow with full cycle management
---

# Code Reuse Health Check

> **PATTERN**: Agent-based orchestration (see `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md` for details)

Complete code duplication detection and consolidation workflow with orchestrator-worker coordination.

**What it does:**
- Full duplication detection (types, schemas, constants, utilities)
- Staged consolidation (HIGH → MEDIUM → LOW priority)
- Quality gates after each stage
- Verification scan
- Up to 3 iterations if issues remain
- Comprehensive final report

**No configuration needed** - runs comprehensive checks always.

---

## Your Task

### Step 1: Phase 0 - Invoke Orchestrator (Pre-flight)

Use Task tool to invoke reuse-orchestrator for pre-flight validation:

```
subagent_type: "reuse-orchestrator"
description: "Reuse orchestrator pre-flight"
prompt: "Execute Phase 0: Pre-flight Validation

Tasks:
1. Validate environment (package.json, scripts, git status)
2. Initialize progress tracking via TodoWrite
3. Initialize iteration tracking (iteration=1, max=3)
4. Create .tmp/current/plans/reuse-detection.json for rollback tracking
5. Report pre-flight status

IMPORTANT: After completing pre-flight, create .tmp/current/plans/reuse-detection.json and return control to main session.

Return the following information:
- Pre-flight status (✅/⛔)
- Environment validation results
- Plan file path created
- Ready for next phase: true/false
"
```

**Then**: Wait for orchestrator to return.

---

### Step 2: Phase 1 - Invoke reuse-hunter (Detection)

After orchestrator returns:

1. **Read plan file** to confirm it was created:
   ```
   Use Read tool: .tmp/current/plans/reuse-detection.json
   Verify nextAgent === "reuse-hunter"
   ```

2. **Invoke reuse-hunter** using Task tool:
   ```
   subagent_type: "reuse-hunter"
   description: "Code duplication detection phase"
   prompt: "Execute code duplication detection based on plan file: .tmp/current/plans/reuse-detection.json

Read the plan file and execute comprehensive duplication detection:
- Scan entire codebase for duplicated types, interfaces, Zod schemas
- Find duplicated constants and configuration objects
- Identify utility functions that are copied instead of imported
- Categorize by priority (HIGH → MEDIUM → LOW)
- Generate reuse-hunting-report.md

Return to main session when complete."
   ```

**Then**: Wait for reuse-hunter to return with report.

---

### Step 3: Quality Gate 1 - Resume Orchestrator (Validate Detection)

After reuse-hunter returns:

1. **Resume orchestrator** for validation using Task tool:
   ```
   subagent_type: "reuse-orchestrator"
   description: "Validate duplication detection"
   prompt: "Execute Quality Gate 1: Detection Validation

Phase: Validate reuse-hunter output

Tasks:
1. Verify reuse-hunting-report.md exists
2. Validate report structure (required sections)
3. Parse duplication counts by priority
4. Run type-check validation (non-blocking warning)
5. Report gate results

IMPORTANT: After validation, if duplications found:
- Create .tmp/current/plans/reuse-consolidation-{priority}.json for highest priority
- Return control to main session

If no duplications found or all gates fail:
- Skip to final summary
- Return control

Return the following:
- Gate status (✅ PASSED / ⛔ FAILED / ⚠️ WARNINGS)
- Duplication counts by priority
- Next phase: consolidation-high / consolidation-medium / final-summary
- Plan file created (if applicable)
"
   ```

**Then**: Wait for orchestrator validation results.

---

### Step 4: Phase 2-4 - Consolidation Stages (Iterative)

After orchestrator returns with consolidation plan:

**For each priority level** (HIGH → MEDIUM → LOW):

1. **Check if this priority has duplications**:
   - Read orchestrator response
   - If orchestrator says "skip to next priority" → continue loop
   - If orchestrator says "final summary" → go to Step 5

2. **Read consolidation plan**:
   ```
   Use Read tool: .tmp/current/plans/reuse-consolidation-{priority}.json
   Verify nextAgent === "reuse-fixer"
   Verify config.priority === "{current-priority}"
   ```

3. **Invoke reuse-fixer** using Task tool:
   ```
   subagent_type: "reuse-fixer"
   description: "Consolidate {priority} duplications"
   prompt: "Execute code consolidation based on plan file: .tmp/current/plans/reuse-consolidation-{priority}.json

Read the plan file and consolidate duplications for priority: {priority}
- Read reuse-hunting-report.md for duplication list
- For each duplication:
  - Determine canonical location (usually shared-types)
  - Create/update canonical file
  - Replace duplicates with re-exports
- Log changes to .reuse-changes.json
- Update reuse-consolidation-implemented.md (consolidated report)

Return to main session when complete."
   ```

4. **Resume orchestrator** for validation:
   ```
   subagent_type: "reuse-orchestrator"
   description: "Validate {priority} consolidation"
   prompt: "Execute Quality Gate 2: Consolidation Validation for priority={priority}

Tasks:
1. Verify reuse-consolidation-implemented.md exists
2. Run type-check (BLOCKING)
3. Run build (BLOCKING)
4. Parse consolidation success rate
5. Check if retry needed (if < 80% success)

If validation PASSES and more priorities remain:
- Create next .tmp/current/plans/reuse-consolidation-{priority}.json
- Return control

If validation FAILS:
- Provide rollback instructions
- Return control with error

If all priorities complete:
- Proceed to verification phase
- Return control

Return:
- Gate status
- Consolidation success rate
- Next phase: consolidation-{next-priority} / verification / final-summary
"
   ```

5. **Repeat** for next priority level.

---

### Step 5: Phase 5 - Verification

After all consolidation stages complete:

1. **Resume orchestrator** for verification:
   ```
   subagent_type: "reuse-orchestrator"
   description: "Create verification plan"
   prompt: "Execute Phase 5: Verification Preparation

Create .tmp/current/plans/reuse-verification.json for re-scanning codebase.

Return control with plan file path."
   ```

2. **Invoke reuse-hunter** for verification:
   ```
   subagent_type: "reuse-hunter"
   description: "Verification scan"
   prompt: "Execute verification scan based on: .tmp/current/plans/reuse-verification.json

Re-scan codebase to verify consolidations. Overwrites reuse-hunting-report.md.

Return when complete."
   ```

3. **Resume orchestrator** for verification validation:
   ```
   subagent_type: "reuse-orchestrator"
   description: "Validate verification"
   prompt: "Execute Quality Gate 3: Verification Validation

Compare original reuse-hunting-report.md (baseline) with new scan:
- Count duplications resolved
- Check if new duplications introduced
- Determine if iteration needed

Return:
- Verification status
- Duplications remaining
- Iteration decision: iterate / complete
"
   ```

---

### Step 6: Final Summary

After all phases complete:

1. **Resume orchestrator** for final summary:
   ```
   subagent_type: "reuse-orchestrator"
   description: "Generate final summary"
   prompt: "Execute Phase 7: Final Summary

Generate comprehensive reuse-orchestration-summary.md:
- All duplications detected
- All consolidations performed
- Success rates by priority
- Validation results
- Iteration summary
- Cleanup instructions

Return final summary."
   ```

2. **Display results** to user:
   ```
   Read reuse-orchestration-summary.md
   Display key metrics
   Show validation status
   List next steps
   ```

---

## Example Usage

```bash
# Run complete code reuse workflow
/health-reuse
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
2. Other packages: `export * from '@megacampus/shared-types/{module}'`
3. NEVER copy code between packages
