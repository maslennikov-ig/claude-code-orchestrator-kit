---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
scripts:
  sh: .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: .specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

> **ORCHESTRATION REMINDER**: You are the orchestrator, not the implementer. Delegate all complex tasks to subagents with complete context. Gather full context before delegation (read code, search patterns, review docs, check commits). Verify results thoroughly (read files, run type-check). Re-delegate with corrections if validation fails. Execute directly only for trivial tasks (1-2 line fixes, imports, single npm install).

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

0. **Session Check** (DeksdenFlow):
   - Invoke `resume-session` skill to check for existing session
   - If valid session found: ask user "Resume previous session or start fresh?"
   - If resume: load context.md and session-log.md, jump to saved phase
   - If fresh or no session: proceed to step 1
   - **Also**: Invoke `load-project-context` skill to load project structure map

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     - Completed items: Lines matching `- [X]` or `- [x]`
     - Incomplete items: Lines matching `- [ ]`
   - Create a status table:

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

   - Calculate overall status:
     - **PASS**: All checklists have 0 incomplete items
     - **FAIL**: One or more checklists have incomplete items

   - **If any checklist is incomplete**:
     - Display the table with incomplete item counts
     - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 3

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 3

3. Load and analyze the implementation context:
   - **REQUIRED**: Read `.specify/memory/constitution.md` for project principles, security requirements, and quality gates
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read research/ for complex research findings and decisions
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4. **PLANNING PHASE** (Execute Before Implementation):
   - Review all tasks and classify execution model (parallel vs sequential)
   - **Step 1: Task Analysis**:
     * Analyze all tasks and identify required agent capabilities
     * Determine which tasks need MAIN (trivial only), existing agents, or new agents
     * Create list of missing agent types with specifications
   - **Step 2: Agent Creation** (if needed):
     * Launch N meta-agent-v3 calls in single message (1 call per missing agent)
     * After agent creation: ask user to restart claude-code
     * After restart: verify new agents exist before proceeding
   - **Step 3: Executor Assignment**:
     * [EXECUTOR: MAIN] - ONLY for trivial tasks (1-2 line fixes, simple imports, single dependency install)
     * [EXECUTOR: existing-agent] - ONLY if 100% capability match after thorough examination
     * [EXECUTOR: specific-agent-name] - For all other tasks using existing or newly created agents
     * Annotate all tasks with `[EXECUTOR: name]` and `[SEQUENTIAL]`/`[PARALLEL-GROUP-X]`
   - **Step 4: Research Resolution**:
     * Simple research: solve with agent tools (Grep, Read, WebSearch, Context7, Supabase docs)
     * Complex research: create research prompt in research/, wait for user deepresearch, incorporate results
   - Output: Updated tasks.md with executor annotations
   - **Atomicity Rule (CRITICAL)**: 1 Task = 1 Agent Invocation
     * Never give multiple tasks to one agent in single run
     * **Parallel execution**: Launch N agent calls in single message (not sequentially)
     * Example: 3 parallel tasks for meta-agent → 3 meta-agent calls in single message
     * Example: 5 parallel tasks for fullstack → 5 fullstack calls in single message
     * Sequential tasks: 1 agent run, wait for completion, then next agent run

5. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc*or eslint.config.* exists → create/verify .eslintignore
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

6. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

7. Execute implementation following the task plan:
   - **Task Discovery**: Find FIRST incomplete task (respect phase order)
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

8. Atomic Task Execution (Per Task):
   1. UPDATE TODO: Mark task `in_progress` in TodoWrite
   2. CHECK EXECUTOR:
      - [EXECUTOR: MAIN]? → Execute directly if trivial, else delegate
      - [EXECUTOR: subagent-name]? → Delegate to specified subagent
   3. GATHER CONTEXT: Read existing code, search patterns, review docs, check commits
   3.5. LIBRARY SEARCH: Before writing >20 lines of new code, search for existing npm/pypi packages
      - Use WebSearch + Context7 to find and evaluate libraries
      - If suitable library found: install and configure instead of implementing from scratch
      - Check: weekly downloads >1000, recent commits, TypeScript support, no critical vulnerabilities
   3.6. FETCH LIBRARY DOCS (MANDATORY): Before writing code that uses ANY library:
      - Call `mcp__context7__resolve-library-id` to get library ID
      - Call `mcp__context7__get-library-docs` with relevant topic (e.g., "hooks", "routing", "auth")
      - Use fetched docs to ensure correct API usage and avoid deprecated patterns
      - This applies to React, Next.js, Supabase, Zod, tRPC, and ALL other libraries
   4. EXECUTE:
      - Direct: Use Edit/Write tools for trivial tasks only
      - Delegated: Launch Task tool with complete context (code snippets, file paths, patterns, validation criteria)
   5. VERIFY: Read ALL modified files, run type-check, check for regressions
   6. ACCEPT/REJECT:
      - Accept? → Continue to step 7
      - Reject? → Re-delegate with corrections and error messages, go to step 4
   7. UPDATE TODO: Mark task `completed` in TodoWrite
   8. UPDATE tasks.md: Mark task `[X]`, add artifacts: `→ Artifacts: [file1](path), [file2](path)`
   9. COMMIT: Run `/push patch`
   10. NEXT TASK: Move to next incomplete task, go to step 1

9. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

10. Progress tracking and error handling:
   - Report progress after each completed task
   - **Commit after each task**: Run `/push patch` before moving to next
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file
   - **Session Context** (DeksdenFlow):
     * After completing each PHASE (not task): invoke `save-session-context` skill
     * On error or pause: save context before stopping
     * Log significant decisions to session-log.md (architecture choices, issue resolutions)
   - **Critical Rules**:
     * NEVER skip verification
     * NEVER proceed if task failed
     * NEVER batch commits (1 task = 1 commit)
     * ONE task in_progress at a time (atomic execution)

11. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/speckit.tasks` first to regenerate the task list.
