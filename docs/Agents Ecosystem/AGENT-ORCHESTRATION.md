# Agent-Based Orchestration Pattern

> **CONTEXT**: This pattern is used in ~5% of cases for automated health workflows.
> For manual development (95% of cases), see CLAUDE.md.

## When to Use

This pattern applies ONLY to automated health workflows:
- `/health-bugs` - Bug detection and fixing
- `/health-security` - Security vulnerability scanning
- `/health-cleanup` - Dead code removal
- `/health-deps` - Dependency management

## Why Different from Main Pattern?

| Aspect | Main Session (95%) | Agent-Based (5%) |
|--------|-------------------|------------------|
| Orchestrator | Main session itself | Slash command + suborchestrator agents |
| Communication | Direct Task tool delegation | Plan files |
| Context | Full conversation history | Isolated agent context |
| Tool access | Main session uses Task tool freely | Orchestrator agents cannot use Task tool |
| Pattern | You delegate and verify | Command coordinates multi-phase workflow |

## Architecture

```
User runs /health-bugs
  ↓
Slash Command (main orchestrator)
  ↓
Task tool → bug-orchestrator (suborchestrator)
  ↓
Creates plan file: .tmp/current/plans/bug-detection.json
Returns control
  ↓
Command reads plan file
  ↓
Task tool → bug-hunter (worker)
  ↓
Worker executes, generates report, returns control
  ↓
Command → Task tool → bug-orchestrator (validation)
  ↓
Orchestrator validates at quality gate
Creates next plan file
Returns control
  ↓
...cycle continues
```

## Key Components

### 1. Slash Commands (Main Orchestrators)

**Location**: `.claude/commands/health-*.md`

**Role**:
- Coordinate full workflow cycle
- Invoke suborchestrators via Task tool
- Read plan files between phases
- Invoke workers via Task tool
- Display results to user

**Responsibilities**:
- Phase coordination
- Read plan files to determine next steps
- Invoke agents explicitly with Task tool
- Handle user interaction

### 2. Agent Orchestrators (Suborchestrators)

**Location**: `.claude/agents/health/orchestrators/`

**Examples**: bug-orchestrator, security-orchestrator, dead-code-orchestrator

**Role**:
- Create plan files for each phase
- Validate worker outputs at quality gates
- Return control to main session after each phase

**Critical Rules**:
- NO Task tool usage (use plan files instead)
- NO implementation work (only coordination)
- NO skip quality gate validations
- MUST create plan files before returning control
- MUST validate worker outputs
- MUST return control after each phase

**Why no Task tool?**
Orchestrator agents run in isolated context without access to Task tool. They coordinate through file-based communication (plan files).

### 3. Workers

**Location**: `.claude/agents/health/workers/`

**Examples**: bug-hunter, bug-fixer, security-scanner, vulnerability-fixer

**Role**:
- Read plan file first
- Execute domain-specific work (detection, fixing, scanning)
- Validate work internally
- Generate structured report
- Return to main session

**Critical Rules**:
- MUST read plan file first
- NO invoke other agents
- NO skip report generation
- MUST log changes for rollback capability
- MUST self-validate before reporting success

## Plan Files

**Location**: `.tmp/current/plans/{workflow}-{phase}.json`

**Purpose**: File-based communication between orchestrators and workers

**Format**:
```json
{
  "workflow": "bug-management",
  "phase": "detection",
  "config": {
    "priority": "all",
    "severity": "critical"
  },
  "validation": {
    "required": ["report-exists", "type-check", "build"],
    "optional": ["tests-pass"]
  },
  "nextAgent": "bug-hunter"
}
```

**Examples**:
- `.bug-detection-plan.json`
- `.bug-fixing-critical-plan.json`
- `.security-scan-plan.json`
- `.dependency-audit-plan.json`

**Lifecycle**:
1. Orchestrator creates plan file
2. Orchestrator returns control to main session
3. Main session (command) reads plan file
4. Main session invokes worker specified in `nextAgent`
5. Worker reads plan file, executes work
6. Worker returns control
7. Main session invokes orchestrator for validation

## Report Files

**Location**:
- Temporary: `.tmp/current/reports/{report-name}.md`
- Permanent: `docs/reports/{domain}/{YYYY-MM}/{date}-{report-name}.md`

**Required Sections**:
1. Header: Report type, timestamp, status
2. Executive Summary: Key metrics, validation status
3. Detailed Findings: Changes, issues, actions
4. Validation Results: PASS/FAIL for each gate
5. Next Steps: Recommendations

**Format**: Follow `docs/Agents Ecosystem/REPORT-TEMPLATE-STANDARD.md`

## Quality Gates

**Blocking Gates** (must pass):
- Report file exists and well-formed
- Validation status is PASSED
- Type-check passes
- Build passes
- No critical errors

**Non-Blocking Gates** (warnings only):
- Tests pass (recommended)
- Lint passes
- Performance benchmarks
- Documentation complete

**On Blocking Failure**:
1. STOP workflow
2. Report failures to user
3. Provide corrective actions
4. Ask user: "Fix issues or skip validation? (fix/skip)"

**Validation Tools**:
- Use `run-quality-gate` Skill for standardized validation
- Use `validate-plan-file` Skill for plan file validation
- Use `validate-report-file` Skill for report validation

## Planning Phase (Speckit Workflow)

**Context**: This applies to speckit-based feature development, NOT health workflows.

**Position**: Always the first phase before implementation in `/speckit.implement`

**Responsibilities**:
1. **Task Analysis**:
   - Review all tasks from tasks.md
   - Classify each as PARALLEL or SEQUENTIAL execution
   - Identify dependencies between tasks

2. **Subagent Assignment**:
   - Map each task to appropriate subagent from existing base
   - Document executor in task annotation: `[EXECUTOR: subagent-name]` or `[EXECUTOR: MAIN]`
   - Main agent handles only trivial tasks (1-2 line fixes, simple imports, single dependency install)

3. **Missing Subagents**:
   - If no suitable subagent exists for a task, create meta-agent task
   - Add to planning phase: `Create [subagent-name] using meta-agent-v3`
   - Execute meta-agent tasks in parallel during planning

4. **Atomicity Rule** (CRITICAL):
   - **1 Task = 1 Agent Invocation**
   - Never give multiple tasks to one agent in single run
   - Example: 3 parallel tasks for meta-agent → 3 separate meta-agent runs (simultaneously)
   - Example: 5 parallel implementation tasks → 5 separate subagent runs (simultaneously)
   - Sequential tasks: 1 agent run, wait for completion, then next agent run

**Output**: Updated tasks.md with:
- `[EXECUTOR: name]` annotations
- `[SEQUENTIAL]` or `[PARALLEL-GROUP-X]` markers
- Meta-agent creation tasks if needed

---

## Research Task Workflow (Speckit Workflow)

**Context**: This applies to speckit planning phase, NOT health workflows.

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

## Workflow Patterns

### Pattern 1: Iterative Cycle (Bugs, Security, Dead Code)

```
Phase 1: Detection
- Orchestrator creates detection plan
- Hunter/Scanner executes, generates categorized report
- Orchestrator validates report

Phase 2: Fixing (Staged by Priority)
- Orchestrator creates fixing plan (priority=critical)
- Fixer executes critical fixes
- Orchestrator validates (quality gate: type-check, build)
- If validation passes, move to next priority
- Repeat for high, medium, low priorities

Phase 3: Verification
- Orchestrator creates verification plan
- Hunter/Scanner re-scans to verify fixes
- Orchestrator validates verification

Phase 4: Iteration Decision
- If new issues found: back to Phase 2
- If max iterations reached (typically 3): stop
- If no issues: final summary

Phase 5: Final Summary
- Orchestrator generates comprehensive report
```

### Pattern 2: Sequential Update (Dependencies)

```
Phase 1: Audit
- Orchestrator creates audit plan
- Auditor scans and categorizes dependencies
- Orchestrator validates report

Phase 2: Update (One-at-a-Time)
- Orchestrator creates update plan (category=security, severity=critical)
- Updater updates ONE dependency
- Orchestrator validates (quality gate: lockfile-valid, build, tests)
- If validation passes: update next dependency
- If validation fails: rollback, mark problematic, continue

Phase 3: Verification
- Orchestrator creates verification plan
- Auditor re-scans
- Orchestrator generates final report
```

## Temporary Files Structure

**Location**: `.tmp/current/`

```
.tmp/
├── current/              # Active orchestration run
│   ├── plans/           # Plan files for workers
│   │   ├── .bug-detection-plan.json
│   │   ├── .bug-fixing-critical-plan.json
│   │   └── .security-scan-plan.json
│   ├── reports/         # Temporary reports from workers
│   │   ├── bug-hunting-report.md
│   │   └── security-audit.md
│   ├── changes/         # Changes logs for rollback
│   │   ├── .bug-changes.json
│   │   └── .security-changes.json
│   ├── backups/         # File backups before modification
│   └── locks/           # Lock files for conflict prevention
└── archive/             # Historical runs (auto-cleanup > 7 days)
    └── YYYY-MM-DD-HHMMSS/
        ├── plans/
        ├── changes/
        └── reports/
```

**Lifecycle**:
1. Command creates `.tmp/current/` directories at workflow start
2. Workers read/write to `.tmp/current/` during execution
3. After workflow completion, command archives `.tmp/current/` to `.tmp/archive/{timestamp}/`
4. Auto-cleanup removes archives older than 7 days

## Changes Logging and Rollback

**Changes Log Location**: `.tmp/current/changes/.{domain}-changes.json`

**Format**:
```json
{
  "phase": "bug-fixing",
  "timestamp": "2025-01-10T14:30:00Z",
  "files_modified": [
    {
      "path": "src/components/Button.tsx",
      "backup": ".tmp/current/backups/Button.tsx.backup"
    }
  ],
  "files_created": ["src/utils/newHelper.ts"],
  "commands_executed": ["npm install lodash"]
}
```

**Rollback Procedure**:
Use `rollback-changes` Skill:
```
Input: .tmp/current/changes/.bug-changes.json

Actions:
1. Restore modified files from backups
2. Delete created files
3. Revert commands (git checkout, npm install)
4. Remove artifacts (plan files, lock files)
5. Generate rollback report
```

## Return Control Pattern

**Why needed?**
Claude Code does NOT support automatic agent invocation. Main session must explicitly invoke all agents using Task tool.

**Pattern**:
1. Orchestrator creates plan file with `nextAgent` field
2. Orchestrator reports readiness and exits
3. Main session (command) reads plan file
4. Main session invokes worker using Task tool with `subagent_type` from plan
5. Worker executes, returns control
6. Main session invokes orchestrator for validation
7. Repeat cycle

**Signal Readiness Protocol**:
Orchestrators must output:
```
Phase preparation complete.

Plan: .tmp/current/plans/.bug-detection-plan.json
Next Agent: bug-hunter

Returning control to main session.
```

## Best Practices

**For Main Session Orchestration (Speckit)**:
- Apply atomicity rule: 1 task = 1 agent invocation
- Gather full context before delegation (code, docs, patterns, history, research)
- Delegate to subagents with complete context (code snippets, file paths, validation criteria)
- Verify results thoroughly (read files, run type-check, check regressions)
- Accept/reject loop: re-delegate with corrections if validation fails
- Commit after each task: `/push patch`
- Track progress with TodoWrite (in_progress → completed immediately)

**For Agent Orchestrators (Health Workflows)**:
- Always validate plan files after creation using `validate-plan-file` Skill
- Track progress with TodoWrite (mark phases in_progress → completed immediately)
- Enforce quality gates, never skip validations
- Limit iterations (max 3 cycles) to prevent infinite loops
- Generate comprehensive reports with all phases summarized
- Handle errors gracefully with rollback instructions

**For Workers**:
- Always read plan file first, never assume config
- Log all changes to changes log for rollback capability
- Self-validate before reporting success
- Generate structured reports following standard format
- Use MCP servers when specified in policy
- Return control after completing work

**For Commands**:
- Read plan files to determine next steps
- Explicitly invoke agents using Task tool
- Handle orchestrator validation results
- Display progress and results to user
- Manage workflow lifecycle (start → phases → completion)

## Atomicity Examples (Speckit)

**Example 1: Meta-Agent Creation**

❌ **WRONG** (batching multiple tasks):
```
Task tool → meta-agent-v3
Prompt: "Create 3 subagents: user-service-specialist, payment-specialist, notification-specialist"
```

✅ **CORRECT** (1 task = 1 agent run):
```
Task tool → meta-agent-v3
Prompt: "Create user-service-specialist subagent"

Task tool → meta-agent-v3
Prompt: "Create payment-specialist subagent"

Task tool → meta-agent-v3
Prompt: "Create notification-specialist subagent"
```

**Example 2: Parallel Implementation**

❌ **WRONG** (batching parallel tasks):
```
Task tool → fullstack-nextjs-specialist
Prompt: "Implement these 5 parallel tasks: T001, T002, T003, T004, T005"
```

✅ **CORRECT** (1 task = 1 agent run, all in parallel):
```
# Launch all 5 simultaneously in single message with 5 Task tool calls
Task tool → fullstack-nextjs-specialist
Prompt: "Implement T001: Create User model in src/models/user.ts"

Task tool → fullstack-nextjs-specialist
Prompt: "Implement T002: Create Payment model in src/models/payment.ts"

Task tool → fullstack-nextjs-specialist
Prompt: "Implement T003: Create Notification model in src/models/notification.ts"

Task tool → fullstack-nextjs-specialist
Prompt: "Implement T004: Create Auth service in src/services/auth.ts"

Task tool → fullstack-nextjs-specialist
Prompt: "Implement T005: Create Email service in src/services/email.ts"
```

**Example 3: Sequential Tasks**

✅ **CORRECT** (1 task = 1 agent run, wait for completion):
```
1. Task tool → database-architect
   Prompt: "Implement T001: Create database schema"
   Wait for completion, verify results

2. Task tool → fullstack-nextjs-specialist
   Prompt: "Implement T002: Create User model (depends on T001)"
   Wait for completion, verify results

3. Task tool → fullstack-nextjs-specialist
   Prompt: "Implement T003: Create UserService (depends on T002)"
   Wait for completion, verify results
```

---

## Common Pitfalls

**Batching multiple tasks to one agent (Speckit)**:
- Problem: Main session gives multiple tasks to one agent in single run
- Solution: Apply atomicity rule - 1 task = 1 agent invocation
- Parallel tasks: Launch N agents simultaneously (single message, N Task calls)
- Sequential tasks: Launch 1 agent, wait, verify, then next

**Orchestrator using Task tool (Health Workflows)**:
- Problem: Orchestrator tries to invoke subagents directly
- Solution: Remove Task tool usage, create plan files, return control

**Skipping plan validation**:
- Problem: Invalid plan causes worker failure
- Solution: Always use `validate-plan-file` Skill after creating plan

**Missing changes logging**:
- Problem: Cannot rollback on validation failure
- Solution: Workers must log all file modifications to changes log

**Infinite iteration loops**:
- Problem: Orchestrator keeps retrying without termination
- Solution: Set max iterations (typically 3) and track progress

**Blocking without user prompt**:
- Problem: Orchestrator blocks on failure without user interaction
- Solution: Report failure, provide options (fix/skip), wait for user decision

## MCP Server Usage

**Worker Requirements**:

**bug-hunter**:
- MUST use Context7 to validate patterns before flagging bugs
- Use `gh` CLI via Bash for GitHub issues

**security-scanner**:
- MUST use Context7 for security best practices
- Use Supabase MCP for database security checks (when available)

**dependency-auditor**:
- Use npm audit (standard tool)
- Use `gh` CLI via Bash for package health

**database-architect, infrastructure-specialist, integration-tester**:
- Use Supabase MCP for all database operations
- Project ref: `diqooqbuchsliypgwksu` (MegaCampusAI)
- Migrations: `packages/course-gen-platform/supabase/migrations/`

**Fallback Strategy**:
If MCP unavailable:
1. Log warning in report
2. Continue with reduced functionality
3. Mark findings as "requires MCP verification"

## Reference

- Architecture overview: `docs/Agents Ecosystem/ARCHITECTURE.md`
- Quality gates specification: `docs/Agents Ecosystem/QUALITY-GATES-SPECIFICATION.md`
- Report template standard: `docs/Agents Ecosystem/REPORT-TEMPLATE-STANDARD.md`
- Main orchestration pattern: `CLAUDE.md`
