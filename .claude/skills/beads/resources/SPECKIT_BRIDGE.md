# Spec-kit to Beads Bridge

## Overview

Spec-kit handles **planning** (spec → plan → tasks), Beads handles **execution** (tracking, dependencies, multi-session).

```
Spec-kit (Planning)          Beads (Execution)
─────────────────           ─────────────────
spec.md                 ─┐
plan.md                  ├─→  /speckit.tobeads ─→ Epic + Tasks
tasks.md                ─┘
```

## When to Use Bridge

| Feature Size | Approach |
|--------------|----------|
| >1 day | Spec-kit → Beads |
| <1 day | Beads only |
| Bug fix | Beads only |
| Research | Beads only |

## Bridge Workflow

### Step 1: Spec-kit Planning

```bash
# 1. Create requirements
/speckit.specify

# 2. Clarify ambiguities
/speckit.clarify

# 3. Technical design
/speckit.plan

# 4. Task breakdown
/speckit.tasks
```

### Step 2: Import to Beads

```bash
# Convert tasks.md to Beads issues
/speckit.tobeads
```

This creates:
- Epic issue for the feature
- Phase issues as parents
- Task issues as children
- Proper dependency graph

### Step 3: Execute with Beads

```bash
# Find available work
bd ready

# Work on task
bd update PREFIX-xxx --status in_progress
# ... implement ...
bd close PREFIX-xxx --reason "Completed"
/push patch

# Repeat until epic done
```

## Task Format Support

tasks.md format:

```markdown
## Phase 1: Setup
- [ ] T001 Create database schema
- [ ] T002 [P] Setup API routes (parallel)
- [ ] T003 [US1] Implement user model

## Phase 2: Implementation
- [ ] T004 [US1] Add validation
```

Markers:
- `[P]` - Task can run in parallel (no sequential deps)
- `[USn]` - User story label

## After Import

The tasks.md file is **frozen** after import. All new work goes through Beads:

```bash
# Found new task during implementation?
bd create "Also need to add caching" -t feature --deps discovered-from:PREFIX-xxx

# DON'T edit tasks.md - use Beads instead
```

## Hybrid Approach

90% of work: Beads only (bugs, small features, chores)
10% of work: Spec-kit → Beads (large features)

This gives you:
- Fast workflow for small work
- Structured planning for complex work
- Single execution system (Beads)
