---
description: Import tasks from tasks.md into Beads issue tracker, creating an epic with child tasks and proper dependencies.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Prerequisites

Verify Beads is installed and initialized:
```bash
bd version
bd info
```

If not installed, instruct user to run `/beads-init` first.

## Outline

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

   If script doesn't exist, search for tasks.md in:
   - `.specify/features/*/tasks.md`
   - Current directory

2. From the executed script or search, extract the path to **tasks.md**.

3. Read and parse tasks.md file. Expected format:
   - `## Phase N: Title` — Phase headers become parent tasks
   - `- [ ] TXXX Description` — Tasks become child issues
   - `[P]` marker — Task can run in parallel (no blocking deps)
   - `[USn]` marker — User story label

4. Get issue prefix from Beads config:
   ```bash
   bd info | grep prefix
   ```

5. Create Epic in Beads:
   ```bash
   bd create "Feature: <feature-name>" -t epic -p 2 -d "<spec-path>"
   ```
   Save the returned epic ID.

6. For each Phase, create a parent task:
   ```bash
   bd create "Phase N: <title>" -t task -p 2 --parent <epic-id>
   ```

7. For each task within a phase:
   ```bash
   bd create "<task-description>" -t task -p 2 --parent <phase-id>
   ```

   If task has `[USn]` marker, add label:
   ```bash
   bd label add <task-id> usN
   ```

8. Set up dependencies:
   - Tasks without `[P]` marker depend on previous task in same phase
   - First task of Phase N+1 depends on last task of Phase N

   ```bash
   bd dep add <child-id> <parent-id>
   ```

9. Sync to git:
   ```bash
   bd sync
   ```

## Output

Report the import results:

```
## Import Complete

**Epic:** PREFIX-<id> - <feature-name>
**Phases:** N
**Tasks:** M total

### Created Issues
- PREFIX-abc123: Phase 1: Setup
  - PREFIX-def456: Task 1.1 description
  - PREFIX-ghi789: Task 1.2 description [P]
- PREFIX-jkl012: Phase 2: Implementation
  ...

### Dependencies
- PREFIX-def456 → PREFIX-ghi789 (sequential)
- PREFIX-ghi789 → PREFIX-jkl012 (phase transition)

### Next Steps
Run `bd ready` to see available tasks.
```

## Error Handling

- If tasks.md not found: Report error and suggest running `/speckit.tasks` first
- If Beads not initialized: Run `/beads-init` first
- If task creation fails: Report which task failed and continue with remaining

## Example

Input tasks.md:
```markdown
## Phase 1: Setup
- [ ] T001 Create database schema
- [ ] T002 [P] Setup API routes

## Phase 2: Implementation
- [ ] T003 [US1] Implement user service
- [ ] T004 [US1] Add validation
```

Creates:
```
PREFIX-epic-001: Feature: user-management
├── PREFIX-ph1-001: Phase 1: Setup
│   ├── PREFIX-t001: Create database schema
│   └── PREFIX-t002: Setup API routes [parallel]
└── PREFIX-ph2-001: Phase 2: Implementation
    ├── PREFIX-t003: Implement user service (label: us1)
    └── PREFIX-t004: Add validation (label: us1)

Dependencies:
- PREFIX-t001 blocks PREFIX-t002 (unless [P])
- PREFIX-t002 blocks PREFIX-ph2-001
```
