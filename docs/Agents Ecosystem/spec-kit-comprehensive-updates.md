# Spec-Kit Comprehensive Updates

> **Purpose**: This document defines all required updates to integrate orchestration improvements, planning phase, research tasks, and atomicity rules across the entire spec-kit workflow.

---

## Priority & Sources

1. **PRIMARY**: Orchestration rules from CLAUDE.md (context gathering, verification, delegation)
2. **SECONDARY**: New requirements from user specification (planning phase, research tasks, atomicity)
3. **TERTIARY**: Existing patterns (maintain compatibility where possible)

---

## Core Patterns to Implement

### A. PLANNING PHASE (New - First Step in Tasks)

**Position**: Always the first phase in tasks.md execution

**Responsibilities**:
1. **Task Analysis**:
   - Review all tasks from tasks.md
   - Classify each as PARALLEL or SEQUENTIAL execution
   - Identify dependencies between tasks

2. **Subagent Assignment**:
   - `[EXECUTOR: MAIN]` - ONLY for trivial tasks (1-2 line fixes, simple imports, single dependency install)
   - For complex tasks: thoroughly examine existing subagents, assign only if 100% match
   - If no 100% match: assign FUTURE agent name (to be created) - `[EXECUTOR: future-agent-name]`

3. **Missing Subagents**:
   - After all assignments: if FUTURE agents exist, launch N meta-agent-v3 calls in single message
   - Each FUTURE agent = 1 separate meta-agent-v3 call (atomicity rule)
   - After agent creation: ask user to restart claude-code

4. **Atomicity Rule** (CRITICAL):
   - **1 Task = 1 Agent Invocation**
   - Never give multiple tasks to one agent in single run
   - **Parallel execution**: Launch N agent calls in single message (not sequentially)
   - Example: 3 parallel tasks for meta-agent → 3 meta-agent calls in single message
   - Example: 5 parallel tasks for fullstack → 5 fullstack calls in single message
   - Sequential tasks: 1 agent run, wait for completion, then next agent run

**Output**: Updated tasks.md with:
- `[EXECUTOR: name]` annotations
- `[SEQUENTIAL]` or `[PARALLEL-GROUP-X]` markers
- Meta-agent creation tasks if needed

---

### B. RESEARCH TASK HANDLING (New - During Planning)

**When**: Planning phase, after subagent assignment

**Classification**:
- **Simple Research**: Questions with clear answer path, solvable with agent + existing tools
- **Complex Research**: Questions without obvious answers, require deep investigation

**Simple Research Workflow**:
1. Agent identifies question
2. Agent uses available tools (Grep, Read, WebSearch, Context7, Supabase docs)
3. Agent formulates answer
4. Agent documents findings in planning notes
5. Continue to next task

**Complex Research Workflow**:
1. Agent identifies complex question without clear answer
2. Agent creates detailed English prompt for deepresearch:
   - **File**: `{FEATURE_DIR}/research/{topic-slug}.md`
   - **Format**: Research question + context + constraints + expected output format
   - **Language**: English (for deepresearch compatibility)
3. Agent adds TODO: "Wait for deepresearch results on {topic}"
4. Agent STOPS and reports to user: "Complex research required: {file-path}"
5. **User action**: Run deepresearch with prompt, save results
6. Agent reads deepresearch results
7. Agent incorporates findings into planning
8. Continue to next task

**Output**:
- Research findings documented
- Complex research prompts in `{FEATURE_DIR}/research/` if needed
- Updated tasks.md with research-informed decisions

---

### C. ORCHESTRATION RULES (Enhanced)

**Main Agent Role**: Orchestrator ONLY
- Execute trivial tasks directly (1-2 line fixes, imports, single npm install)
- Delegate ALL complex tasks to subagents
- NEVER implement multi-file changes directly
- NEVER implement logic changes directly

**Before Delegation**:
1. **Gather Full Context** (MANDATORY):
   - Read existing code in target files
   - Search codebase for similar patterns (Grep, Glob)
   - Review relevant documentation (specs, ADRs, research)
   - Check recent commits in related areas (`git log -- path`)
   - Understand dependencies and integration points
2. **Prepare Complete Context** for subagent:
   - Code snippets from related files
   - File paths (absolute)
   - Expected output format
   - Validation criteria (type-check, tests, build)
   - Patterns to follow (examples from codebase)

**After Delegation**:
1. **Detailed Verification**:
   - Read ALL modified files
   - Run `pnpm type-check` (or relevant validation)
   - Run tests if applicable
   - Check for regressions in related code
2. **Accept/Reject Loop**:
   - **Accept**: If all validations pass → mark task completed
   - **Reject**: If validations fail → re-delegate with:
     - Error messages (full type-check output)
     - Specific corrections needed
     - Additional context if missing
   - Loop until accepted (no limit, quality over speed)

**Commit Strategy** (DECISION: Per-Task Commits):
- **When**: After EACH task marked completed
- **Command**: `/push patch`
- **Before commit**:
  1. Mark task `[X]` in tasks.md
  2. Add artifacts to task: `→ Artifacts: [file1](path), [file2](path)`
  3. Update TodoWrite to completed
  4. Then run `/push patch`
- **Rationale**:
  - Detailed git history (1 commit = 1 task)
  - Easy rollback to specific task
  - Better for review and debugging
  - Atomic changes in version control

---

### D. IMPLEMENT COMMAND EXECUTION MODEL (Enhanced)

**Task Discovery**:
- Find FIRST incomplete task in tasks.md (not last)
- Respect phase order: Setup → Tests → Core → Integration → Polish
- Within phase: respect dependencies and sequential markers

**Execution Loop** (Per Task):
```
1. UPDATE TODO: Mark task `in_progress` in TodoWrite
2. CHECK EXECUTOR:
   - [EXECUTOR: MAIN]? → Execute directly if trivial, else delegate
   - [EXECUTOR: subagent-name]? → Delegate to specified subagent
3. GATHER CONTEXT: (see Orchestration Rules section B)
4. EXECUTE:
   - Direct: Use Edit/Write tools
   - Delegated: Launch Task tool with complete context
5. VERIFY: (see Orchestration Rules section C)
6. ACCEPT/REJECT:
   - Accept? → Continue to step 7
   - Reject? → Re-delegate with corrections, go to step 4
7. UPDATE TODO: Mark task `completed` in TodoWrite
8. UPDATE tasks.md: Mark task `[X]`, add artifacts
9. COMMIT: Run `/push patch`
10. NEXT TASK: Move to next incomplete task, go to step 1
```

**Critical Rules**:
- NEVER skip verification
- NEVER proceed if task failed
- NEVER batch commits (1 task = 1 commit)
- ONE task in_progress at a time (atomic execution)

---

## Files to Update

### 1. Commands (.claude/commands/)

#### A. `speckit.implement.md`

**Changes**:
1. Add orchestration reminder blockquote (already done in generation-json)
2. Update step 3 (Load context) to include research/ directory:
   ```markdown
   - **IF EXISTS**: Read research/ for complex research findings and decisions
   ```
3. Replace step 4 with PLANNING PHASE:
   ```markdown
   4. **PLANNING PHASE** (Execute Before Implementation):
      - Review all tasks and classify execution model (parallel vs sequential)
      - **Subagent Assignment** (Phase 0):
        * [EXECUTOR: MAIN] - ONLY for trivial tasks (1-2 line fixes, simple imports, single dependency install)
        * For complex tasks: thoroughly examine existing subagents, assign only if 100% match
        * If no 100% match: assign FUTURE agent name (to be created) - `[EXECUTOR: future-agent-name]`
        * After all assignments: if FUTURE agents exist, launch N meta-agent-v3 calls in single message
        * After agent creation: ask user to restart claude-code
      - Annotate tasks with `[EXECUTOR: name]` and `[SEQUENTIAL]`/`[PARALLEL-GROUP-X]`
      - Handle research tasks:
        * Simple: solve with agent tools
        * Complex: create research prompt in research/, wait for user deepresearch
      - Output: Updated tasks.md with executor annotations
   ```
4. Update step 6 (Execution Strategy) to clarify task discovery:
   ```markdown
   **Task Discovery**: Find FIRST incomplete task (respect phase order)
   ```
5. Update step 7 (Atomic Task Execution) to include commit:
   ```markdown
   6. UPDATE tasks.md: Mark task [X] and add artifacts
   7. COMMIT: Run `/push patch`
   8. NEXT TASK: Move to next incomplete task
   ```
6. Update step 8 (Progress Tracking) with commit reminder:
   ```markdown
   - **Commit after each task**: Run `/push patch` before moving to next
   ```

#### B. `speckit.tasks.md`

**Changes**:
1. Add research task classification in outline:
   ```markdown
   - **Research Tasks**: Questions without obvious answers
     * Simple: Agent solves with available tools
     * Complex: Create research prompt → wait for deepresearch → incorporate
   ```
2. Add planning phase instructions:
   ```markdown
   - After generating tasks, add PLANNING PHASE as first phase
   - Planning phase includes: executor assignment, research resolution, meta-agent creation
   ```

#### C. `speckit.plan.md`

**Changes**:
1. Add research considerations to tech stack analysis:
   ```markdown
   - If tech decisions unclear, classify as research task
   - Document research questions in plan with classification (simple/complex)
   ```

#### D. `speckit.specify.md` & `speckit.clarify.md`

**Changes**:
1. Add note about research questions:
   ```markdown
   - If clarifications reveal complex unknowns, flag for research phase
   ```

---

### 2. Templates (.specify/templates/)

#### A. `tasks.md` Template

**Add Planning Phase Template**:
```markdown
## Phase 0: Planning

### P001: Task Analysis & Executor Assignment
**Description**: Analyze all tasks, assign executors (MAIN for trivial, existing if 100% match, FUTURE otherwise)
**Executor**: MAIN
**Dependencies**: None
**Output**:
- All tasks annotated with [EXECUTOR: name] or [EXECUTOR: future-agent-name]
- All tasks marked [SEQUENTIAL] or [PARALLEL-GROUP-X]
- List of FUTURE agents to create (if any)
**Artifacts**: Updated tasks.md

### P002: Research Task Resolution
**Description**: Identify and resolve research questions (simple: solve now, complex: create prompts)
**Executor**: MAIN
**Dependencies**: P001
**Output**:
- Simple research: documented findings
- Complex research: prompts in research/ directory
**Artifacts**: research/*.md (if complex research needed)

### P003: Meta-Agent Subagent Creation (if needed)
**Description**: Create FUTURE agents using meta-agent-v3, then ask user to restart claude-code
**Executor**: meta-agent-v3
**Dependencies**: P001
**Execution**: Launch N meta-agent-v3 calls in single message (1 FUTURE agent = 1 call)
**Tasks**: [List FUTURE agents from P001]
**Post-Creation**: Ask user to restart claude-code
**Artifacts**: .claude/agents/{domain}/{type}/{name}.md

---
```

---

### 3. Scripts (.specify/scripts/bash/)

#### A. `check-prerequisites.sh`

**Changes**:
1. Add research directory check:
   ```bash
   # Check for research directory
   if [ -d "$FEATURE_DIR/research" ]; then
       RESEARCH_DIR="$FEATURE_DIR/research"
       RESEARCH_FILES=$(find "$RESEARCH_DIR" -name "*.md" 2>/dev/null)
   fi
   ```
2. Include research files in JSON output:
   ```json
   "research": ["$FEATURE_DIR/research/file1.md", ...]
   ```

---

### 4. Documentation

#### A. `CLAUDE.md`

**Changes**:
1. Update "Main Pattern: You Are The Orchestrator" section, step 6 (Execution Pattern):
   ```markdown
   FOR EACH TASK:
   1. Read task description
   2. GATHER FULL CONTEXT (code + docs + patterns + history + research)
   3. Delegate to subagent OR execute directly (trivial only)
   4. Verify implementation (read files + run type-check)
   5. Accept/reject loop (re-delegate if needed)
   6. Update TodoWrite to completed
   7. Mark task [X] in tasks.md + add artifacts
   8. Run /push patch
   9. Move to next task
   ```

2. Add new section after "Main Pattern":
   ```markdown
   ### Planning Phase (ALWAYS First)

   Before implementing any tasks:
   - Analyze task execution model (parallel/sequential)
   - Assign executors: MAIN for trivial only, existing subagents if 100% match, FUTURE agents otherwise
   - Create FUTURE agents: launch N meta-agent-v3 calls in single message, then ask restart
   - Resolve research questions (simple: solve now, complex: deepresearch prompt)
   - Apply atomicity rule: 1 task = 1 agent invocation
   - Parallel tasks: launch N agent calls in single message (not sequentially)

   See speckit.implement.md for detailed workflow.
   ```

3. Update "COMMIT STRATEGY" section:
   ```markdown
   **5. COMMIT STRATEGY**

   Run `/push patch` after EACH completed task (not batched):
   - Mark task [X] in tasks.md
   - Add artifacts to task description
   - Update TodoWrite to completed
   - Then `/push patch`

   Rationale: Atomic commits, detailed history, easy rollback, better review.
   ```

#### B. `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md`

**Changes**:
1. Add "Planning Phase" section before "Orchestration Patterns"
2. Add "Research Task Workflow" section
3. Update orchestration patterns with atomicity rule
4. Add examples of 1-task-1-agent-run pattern

---

## Implementation Steps (How to Apply)

### Step 1: Update speckit.implement.md
1. Open `.claude/commands/speckit.implement.md`
2. Add orchestration blockquote after frontmatter (if not present)
3. Add research/ to step 3 context loading
4. Replace step 4 with PLANNING PHASE section
5. Update step 6 task discovery
6. Update step 7 with commit step
7. Update step 8 with commit reminder
8. Save file

### Step 2: Update CLAUDE.md
1. Open `CLAUDE.md`
2. Update step 6 in "Execution Pattern"
3. Add "Planning Phase" section (with FUTURE agents logic)
4. Update "COMMIT STRATEGY"
5. Save file

### Step 3: Update tasks.md Template
1. Open `.specify/templates/tasks.md`
2. Add "Phase 0: Planning" section at top
3. Add P001 (with FUTURE agents logic), P002, P003 (with restart prompt) tasks
4. Save file

### Step 4: Update Other Commands
1. Update `speckit.tasks.md` - add research classification
2. Update `speckit.plan.md` - add research considerations
3. Update `speckit.specify.md` and `speckit.clarify.md` - add research notes
4. Save all files

### Step 5: Update Scripts
1. Open `.specify/scripts/bash/check-prerequisites.sh`
2. Add research directory check
3. Add research files to JSON output
4. Save file

### Step 6: Update Documentation
1. Update `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md`
2. Add planning phase, research workflow, atomicity examples
3. Save file

### Step 7: Test Workflow
1. Create test feature in specs/
2. Run `/speckit.specify` - verify research question handling
3. Run `/speckit.tasks` - verify planning phase in tasks.md
4. Run `/speckit.implement` - verify planning execution, atomicity, per-task commits
5. Validate: each task = 1 commit, all annotations present, research handled

---

## Validation Checklist

After applying all updates:

- [ ] `speckit.implement.md` has orchestration blockquote
- [ ] `speckit.implement.md` has planning phase with FUTURE agents logic (step 4)
- [ ] `speckit.implement.md` has atomicity rule with "single message" for parallel tasks
- [ ] `speckit.implement.md` commits after each task (step 7)
- [ ] `CLAUDE.md` has updated execution pattern
- [ ] `CLAUDE.md` has planning phase section with FUTURE agents and parallel tasks rule
- [ ] `CLAUDE.md` has per-task commit strategy
- [ ] `tasks.md` template has Phase 0: Planning with P001 (FUTURE agents) and P003 (single message)
- [ ] `speckit.tasks.md` mentions FUTURE agents and single message in Planning Phase
- [ ] Other commands reference research handling
- [ ] `check-prerequisites.sh` includes research directory
- [ ] Documentation updated with new patterns
- [ ] Test run completes with atomicity and commits

---

## Key Principles (Summary)

1. **Planning First**: Always execute planning phase before implementation
2. **Atomicity**: 1 task = 1 agent invocation; parallel tasks = N agent calls in single message
3. **Orchestration**: Main agent delegates complex, verifies thoroughly, re-delegates on failure
4. **Research**: Classify simple vs complex, use deepresearch for complex unknowns
5. **Commits**: 1 task = 1 commit (after validation, with artifacts, via /push patch)
6. **Context**: Gather full context before every delegation (code, docs, patterns, history, research)
7. **Verification**: Read files + type-check + tests before accepting task completion

---

## Recent Updates

**Change 1**: Enhanced subagent assignment with FUTURE agents logic
- Strict rules: MAIN for trivial, existing if 100% match, FUTURE otherwise
- FUTURE agents: launch N meta-agent-v3 calls in single message, ask restart
- Updated: speckit.implement.md, speckit.tasks.md, tasks-template.md, CLAUDE.md

**Change 2**: Clarified "single message" rule for ALL parallel tasks
- Parallel execution applies to all agents, not just meta-agent
- Updated atomicity rule: launch N agent calls in single message
- Updated: speckit.implement.md, tasks-template.md, CLAUDE.md, this document

**Change 3**: Optimized CLAUDE.md and all templates for token efficiency
- CLAUDE.md: Added CRITICAL verification rule, removed duplicates (net -18 lines, -12%)
- tasks-template.md: Removed emojis (5 instances)
- checklist-template.md: Condensed comments (40 → 27 lines, -33%)
- spec-template.md: Removed verbosity (115 → 81 lines, -30%)
- plan-template.md: Simplified instructions (105 → 95 lines, -10%)
- Total templates reduction: -57 lines

**Rationale**: Specialized agents for quality, single-message for performance, token efficiency for cost.

---

**End of Document**

This comprehensive specification ensures all orchestration improvements are applied consistently across the entire spec-kit workflow, maintaining interconnections and preventing pattern drift.
