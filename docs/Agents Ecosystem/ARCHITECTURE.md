# AI Agents Architecture - Canonical Reference

**Version**: 2.0
**Last Updated**: 2025-10-18
**Status**: Canonical Reference for AI Agents
**Language**: English (for AI agents)
**Audience**: Claude Code and custom agents

---

## Executive Summary

This document defines the **canonical 2-level architecture** for AI agents in MegaCampus2. After Phase 2 refactoring, we use a simplified hierarchy:

```
User → /health {domain} → Domain Orchestrator (L1)
  → Hunter/Scanner → detection report
  → Fixer/Updater (staged by priority) → fixes
  → Hunter/Scanner (verification) → verification report
  → (iterate if issues remain)
```

### Key Principles

1. **Orchestrators coordinate, don't invoke** - Use Return Control pattern
2. **2-level hierarchy** - Domain orchestrators are L1, workers are L2
3. **Hunter+Fixer separation** - Context window preservation via staged execution
4. **Iterative cycles** - Detection → Fixing → Verification → Repeat
5. **Quality gates** - Validation checkpoints between phases
6. **Plan files** - Structured communication (`.{domain}-{phase}-plan.json`)

---

## Core Concepts

### What is an Agent?

An **agent** is a specialized AI assistant with:
- **Isolated context window** (prevents context pollution)
- **Specific domain expertise** (bugs, security, dead code, dependencies)
- **Defined inputs/outputs** (plan files → work → reports)
- **Independent tool access** (Bash, Read, Write, Edit, etc.)

**Location**: `.claude/agents/{domain}/{orchestrators|workers}/`

### Agent Types

#### 1. Orchestrators (Level 1)

**Purpose**: Coordinate multi-phase workflows

**Responsibilities**:
- Create plan files for each phase
- Signal readiness to user (Return Control)
- Validate worker outputs at quality gates
- Track progress via TodoWrite
- Handle errors with rollback instructions
- Generate final summary reports

**CRITICAL RULES**:
- ❌ **NO Task tool** to invoke subagents
- ❌ **NO implementation work** (delegate to workers)
- ❌ **NO skip quality gate validations**
- ✅ **DO create plan files** before signaling
- ✅ **DO validate worker outputs** at quality gates
- ✅ **DO report status** to user

**Location**: `.claude/agents/health/orchestrators/`

**Examples**:
- `bug-orchestrator.md`
- `security-orchestrator.md`
- `dead-code-orchestrator.md`
- `dependency-orchestrator.md`

#### 2. Workers (Level 2)

**Purpose**: Execute domain-specific work

**Responsibilities**:
- Read plan file first
- Execute domain work (detection, fixing, verification)
- Validate work internally
- Generate structured report
- Return to main session

**CRITICAL RULES**:
- ❌ **NO invoke other agents**
- ❌ **NO skip report generation**
- ❌ **NO report success without validation**
- ✅ **DO read plan file** first
- ✅ **DO generate changes logs** (for rollback)
- ✅ **DO self-validate** work

**Location**: `.claude/agents/health/workers/`

**Examples**:
- `bug-hunter.md`, `bug-fixer.md`
- `security-scanner.md`, `vulnerability-fixer.md`
- `dead-code-hunter.md`, `dead-code-remover.md`
- `dependency-auditor.md`, `dependency-updater.md`

#### 3. Skills (Utilities)

**Purpose**: Reusable utility functions

**Characteristics**:
- Stateless (no context needed)
- <100 lines logic
- Single responsibility
- No agent invocation

**Location**: `.claude/skills/{skill-name}/SKILL.md`

**Examples**:
- `validate-plan-file`
- `run-quality-gate`
- `rollback-changes`
- `generate-report-header`

---

## Return Control Pattern

### How It Works

```mermaid
sequenceDiagram
    participant User
    participant Main as Main Claude Session
    participant Orch as Orchestrator
    participant Worker as Worker Agent

    User->>Main: /health bugs
    Main->>Orch: Invoke orchestrator via Task tool
    Orch->>Orch: Create .bug-detection-plan.json
    Orch->>Orch: Validate plan file
    Orch->>Orch: Update TodoWrite (in_progress)
    Orch->>User: Signal readiness, return control
    Orch-->>Main: Exit orchestrator
    Main->>Main: Read .bug-detection-plan.json
    Main->>Worker: Invoke bug-hunter via Task tool
    Worker->>Worker: Read plan file
    Worker->>Worker: Execute detection
    Worker->>Worker: Generate report
    Worker-->>Main: Return control
    Main->>Orch: Resume orchestrator via Task tool
    Orch->>Orch: Validate report (quality gate)
    Orch->>Orch: Create .bug-fixing-plan.json
    Orch->>User: Signal readiness, return control
    Orch-->>Main: Exit orchestrator
    Main->>Main: Read .bug-fixing-plan.json
    Main->>Worker: Invoke bug-fixer via Task tool
    Note: Cycle continues...
```

### Signal Readiness Protocol

Orchestrators must:

1. **Create plan file**:
   ```json
   {
     "workflow": "bug-management",
     "phase": "detection",
     "config": { "priority": "all" },
     "validation": {
       "required": ["report-exists", "type-check"]
     },
     "nextAgent": "bug-hunter"
   }
   ```

2. **Validate plan file** using `validate-plan-file` Skill

3. **Update TodoWrite**:
   ```json
   {
     "content": "Phase 1: Bug detection",
     "status": "in_progress",
     "activeForm": "Detecting bugs"
   }
   ```

4. **Signal to user and return control**:
   ```
   ✅ Phase preparation complete!

   Plan: .bug-detection-plan.json
   Next Agent: bug-hunter

   Returning control to main session.

   Main session should:
   1. Read .bug-detection-plan.json
   2. Invoke bug-hunter via Task tool
   3. Resume orchestrator after worker completes
   ```

5. **Exit orchestrator** - Return control to main session (do NOT invoke workers)

### Manual Worker Invocation Pattern

**IMPORTANT**: Claude Code does NOT have automatic agent invocation. The main session must explicitly invoke workers using the Task tool.

**Correct Pattern**:

1. **Orchestrator** creates plan file (e.g., `.bug-detection-plan.json`) with `nextAgent` field
2. **Orchestrator** reports readiness and exits, returning control to main session
3. **Main session** (slash command or user) reads the plan file
4. **Main session** explicitly invokes worker using Task tool:
   ```
   Use Task tool with:
   - subagent_type: "{worker-name}" (from plan.nextAgent)
   - prompt: "Execute work based on plan file: {plan-file-path}"
   ```
5. **Worker** reads plan file, executes work, generates report, returns control
6. **Main session** resumes orchestrator for validation

**Worker Description Pattern** (unchanged):
```markdown
description: Use proactively for {task}. Reads plan files with nextAgent='worker-name'.
```

**NOTE**: "Use proactively" helps Claude understand when to use the agent, but does NOT trigger automatic invocation.

---

## Workflow Patterns

### Pattern 1: Iterative Cycle (Bug, Security, Dead Code)

```
Phase 1: Detection
├─ Orchestrator creates detection plan
├─ Hunter/Scanner executes → generates categorized report
└─ Orchestrator validates report

Phase 2: Fixing (Staged by Priority)
├─ Orchestrator creates fixing plan (priority=critical)
├─ Fixer executes critical fixes
├─ Orchestrator validates (quality gate: type-check, build)
├─ If issues remain at this priority, repeat
└─ Move to next priority (high → medium → low)

Phase 3: Verification
├─ Orchestrator creates verification plan
├─ Hunter/Scanner re-scans to verify fixes
└─ Orchestrator validates verification

Phase 4: Iteration Decision
├─ If new issues found → back to Phase 2
├─ If max iterations reached → stop
└─ If no issues → final summary

Phase 5: Final Summary
└─ Orchestrator generates comprehensive report
```

### Pattern 2: Sequential Update (Dependencies)

```
Phase 1: Audit
├─ Orchestrator creates audit plan
├─ Auditor scans and categorizes
└─ Orchestrator validates report

Phase 2: Update (One-at-a-Time)
├─ Orchestrator creates update plan (category=security, severity=critical)
├─ Updater updates ONE dependency
├─ Orchestrator validates (quality gate: lockfile-valid, build, tests)
├─ If validation passes → update next dependency
└─ If validation fails → rollback, mark as problematic, continue

Phase 3: Verification
├─ Orchestrator creates verification plan
├─ Auditor re-scans
└─ Orchestrator generates final report
```

---

## Quality Gates

### Gate Execution

Use `run-quality-gate` Skill:

```markdown
## Quality Gate: Type Check

Use run-quality-gate Skill:
- gate: "type-check"
- blocking: true

If action="stop":
  ⛔ HALT workflow
  Report errors to user
  Suggest rollback or fix
  Ask user: "Fix issues or skip validation? (fix/skip)"

If action="warn":
  ⚠️ WARN user but continue
  Log warnings in report

If action="continue":
  ✅ PASSED - proceed to next phase
```

### Standard Gates

**Blocking** (must pass):
- `type-check`: pnpm type-check
- `build`: pnpm build
- `tests`: pnpm test (for critical changes)
- `lockfile-valid`: Ensure package-lock.json consistent
- `no-critical-vulns`: No critical security vulnerabilities

**Non-Blocking** (warnings only):
- `lint`: pnpm lint
- `bundle-size`: Check bundle size increase
- `performance`: Lighthouse CI scores

### Custom Gates

```markdown
Use run-quality-gate Skill:
- gate: "custom"
- blocking: false
- custom_command: "npm run lighthouse-ci"
```

---

## Plan Files

### Naming Convention

Pattern: `.{domain}-{phase}-plan.json`

**Examples**:
- `.bug-detection-plan.json`
- `.bug-fixing-plan.json`
- `.security-scan-plan.json`
- `.security-remediation-plan.json`
- `.dead-code-detection-plan.json`
- `.dependency-audit-plan.json`

### Schema Validation

All plan files must conform to JSON schemas in `.claude/schemas/`:

- `base-plan.schema.json` - Base schema (all plans)
- `bug-plan.schema.json` - Bug management
- `security-plan.schema.json` - Security audit
- `dead-code-plan.schema.json` - Dead code cleanup
- `dependency-plan.schema.json` - Dependency management

**Validation**: Use `validate-plan-file` Skill after creating plan

---

## Changes Logging & Rollback

### Changes Log Format

Location: `.{domain}-changes.json`

```json
{
  "phase": "bug-fixing",
  "timestamp": "2025-10-18T14:30:00Z",
  "files_modified": [
    {
      "path": "src/components/Button.tsx",
      "backup": ".rollback/src-components-Button.tsx.backup"
    }
  ],
  "files_created": ["src/utils/newHelper.ts"],
  "commands_executed": ["pnpm install"]
}
```

### Rollback Procedure

Use `rollback-changes` Skill:

```markdown
## On Validation Failure

Use rollback-changes Skill:
- changes_log_path: ".bug-changes.json"
- phase: "bug-fixing"
- confirmation_required: true

Actions:
1. Restore modified files from backups
2. Delete created files
3. Revert commands (git checkout, pnpm install)
4. Remove artifacts (.plan.json, .lock files)
5. Generate rollback report
```

---

## Report Files

### Standard Format

Follow `REPORT-TEMPLATE-STANDARD.md`:

**Sections**:
1. Header: Report type, timestamp, status
2. Executive Summary: Key metrics, validation status
3. Detailed Findings: Changes, issues, actions
4. Validation Results: ✅/⛔/⚠️ for each gate
5. Next Steps: Recommendations

### File Organization

#### Temporary Files

All orchestration state files stored in `.tmp/`:

**Why `.tmp/`?**
- ✅ Centralized location for all temporary files
- ✅ Easy to add to .gitignore
- ✅ Clear separation from source code
- ✅ Follows Unix conventions (tmp/ for temporary data)
- ✅ Easy cleanup: `rm -rf .tmp/*`

**Structure**:
```
.tmp/
├── current/              # Active run (read/write)
│   ├── plans/           # Plan files for workers
│   ├── changes/         # Changes logs for rollback
│   ├── backups/         # File backups (.rollback/)
│   └── locks/           # Lock files for conflict prevention
└── archive/             # Historical runs (read-only, auto-cleanup)
    └── YYYY-MM-DD-HHMMSS/
        ├── plans/
        ├── changes/
        └── reports/
```

**Lifecycle**:
1. Pre-flight creates `current/` directories
2. Workers read/write to `current/`
3. Final summary archives `current/` → `archive/{timestamp}/`
4. Auto-cleanup removes `archive/` entries > 7 days

#### Permanent Files

Reports archived to `docs/reports/{domain}/{YYYY-MM}/`:
- Timestamped for versioning
- Git committed for history
- Organized by domain and month

**Examples**:
- `docs/reports/bugs/2025-10/2025-10-19-bug-hunting-report.md`
- `docs/reports/security/2025-10/2025-10-19-security-audit.md`
- `docs/reports/summaries/2025-10-19-health-summary.md`

---

## Conflict Avoidance

### Sequential Phases Locking

**Strategy**: Hunter phases can run in parallel (read-only), fixer phases must run sequentially (write operations).

**Implementation**:

```markdown
## Before Starting Fixer Phase

1. Check for `.active-fixer.lock` file
2. If lock exists:
   - Read lock file
   - Check if expired (>30 minutes old)
   - If not expired: wait or fail
3. If no lock or expired:
   - Create lock file:
     {
       "domain": "bugs",
       "started": "2025-10-18T14:30:00Z",
       "pid": "bug-orchestrator-instance-abc123"
     }
4. Execute fixer phase
5. Remove lock file on completion or failure
```

**Lock Location**: `.tmp/current/locks/` (auto-cleanup on expiry)

---

## Best Practices

### For Orchestrators

1. **Always validate plan files** after creation
2. **Track progress** with TodoWrite (mark phases in_progress → completed immediately)
3. **Enforce quality gates** - don't skip validations
4. **Limit iterations** - max 3 cycles to prevent infinite loops
5. **Generate comprehensive reports** with all phases summarized
6. **Handle errors gracefully** with rollback instructions

### For Workers

1. **Always read plan file first** - don't assume config
2. **Log all changes** for rollback capability
3. **Self-validate** before reporting success
4. **Generate structured reports** following standard format
5. **Use MCP servers** when specified in policy
6. **Return control** after completing work

### For Skills

1. **Keep stateless** - no context dependencies
2. **Single responsibility** - one clear purpose
3. **Document thoroughly** - include examples
4. **Handle errors** - return structured error info
5. **Version schemas** - use JSON Schema for inputs/outputs

---

## Common Pitfalls

### ❌ Orchestrator Using Task Tool

**Problem**: Orchestrator tries to invoke subagents directly
**Solution**: Remove Task tool usage, use Return Control pattern

### ❌ Skipping Plan Validation

**Problem**: Invalid plan causes worker failure
**Solution**: Always use `validate-plan-file` Skill after creating plan

### ❌ Missing Changes Logging

**Problem**: Can't rollback on validation failure
**Solution**: Workers must log all file modifications to changes log

### ❌ Infinite Iteration Loops

**Problem**: Orchestrator keeps retrying without termination
**Solution**: Set max iterations (typically 3) and track progress

### ❌ Blocking Without User Prompt

**Problem**: Orchestrator blocks on failure without user interaction
**Solution**: Report failure, provide options (fix/skip), wait for user decision

---

## MCP Server Usage Policy

### Two-Tier Configuration

**Minimal (`.mcp.json`)**: context7, server-sequential-thinking
**Full (`.mcp.full.json`)**: Above + playwright, supabase, n8n-mcp, shadcn

**Token savings**: ~600-3000 tokens/conversation with minimal config

### Worker Requirements

**bug-hunter**:
- MUST use Context7 (validate patterns before flagging bugs)
- Use `gh` CLI via Bash (not MCP)

**security-scanner**:
- MUST use Context7 (security best practices)
- Supabase MCP: only if `.mcp.full.json` active

**dependency-auditor**:
- Use npm audit (standard tool)
- Use `gh` CLI via Bash

### Fallback Strategy

If MCP unavailable:
1. Log warning in report
2. Continue with reduced functionality
3. Mark findings as "requires MCP verification"

### Design Rationale

Architecture follows Anthropic multi-agent research patterns:
- Lead-subagent hierarchy → Orchestrator-Worker (L1-L2)
- Parallel execution → Hunters run concurrently
- Iterative refinement → Max 3 cycles with verification
- Structured communication → Plan files + Reports

**Key adaptation**: Return Control Pattern vs direct spawning (CLI constraints)

**Source**: https://www.anthropic.com/engineering/multi-agent-research-system

---

## References

- **Skills Guide**: `SKILLS-GUIDE.md`
- **Quality Gates**: `QUALITY-GATES-SPEC.md`
- **Report Template**: `REPORT-TEMPLATE-STANDARD.md`
- **CLAUDE.md**: Project-wide orchestration rules
