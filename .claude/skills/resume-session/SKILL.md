---
name: resume-session
description: Resume a previously saved session by loading context and recent log entries. Use at start of orchestrator workflows to check for existing sessions.
trigger: At the start of health workflows, or when user asks to continue previous work
---

# Resume Session

Checks for and loads a previously saved session context, enabling seamless workflow continuation.

## When to Use

- At the start of health orchestrator workflows (automatic)
- When user explicitly asks to continue previous work
- After session restart or context switch

## When NOT to Use

- For new workflows with no prior context
- When user explicitly wants to start fresh

## Algorithm

### Step 1: Check for Existing Session

Check if `.tmp/current/session/context.md` exists.

### Step 2: Validate Freshness

If file exists, check the "Updated" timestamp:
- If < 24 hours old: Session is valid
- If > 24 hours old: Session is stale, ask user

### Step 3: Load Context

Read `.tmp/current/session/context.md` and extract:
- Current workflow and phase
- Last action and next steps
- Git state
- Quality gate status

### Step 4: Load Recent Log Entries

Read last 10 entries from `.tmp/current/session/log.md`:
- Recent decisions
- Issues encountered
- Learnings

### Step 5: Present Resume Option

If valid session found, present to user:
```
Found previous session:
- Workflow: health-bugs
- Phase: 3/7 (Staged Fixing)
- Last action: Fixed auth validation
- Age: 2 hours ago

Options:
1. Resume from where you left off
2. Start fresh (archive current session)
```

### Step 6: On Resume

Return combined context for orchestrator to continue:
```markdown
## Resuming Session

### Current State
[Content from context.md]

### Recent Decisions
[Last 5 entries from log.md]

### Next Actions
[From context.md Next Steps section]
```

### Step 7: On Start Fresh

If user chooses fresh start:
1. Move current session files to `.tmp/archive/session-[timestamp]/`
2. Return empty context
3. Orchestrator starts Phase 1

## Implementation

```markdown
### Check session exists

Read `.tmp/current/session/context.md`

If not found:
  Return "No previous session found. Starting fresh."

### Validate timestamp

Extract "Updated: YYYY-MM-DDTHH:MM:SS" from file
Calculate age in hours

If age > 24:
  Ask user: "Session is [X] hours old. Resume or start fresh?"

### Load and return

Read context.md fully
Read last 500 lines of log.md (covers ~10 entries)
Return combined content
```

## Output Format

### When session found:
```
Previous session found:
- Workflow: health-bugs
- Phase: 3/7 (Staged Fixing)
- Age: 2h 15m
- Last: Fixed auth validation in src/auth.ts

Resume? [Y/n]
```

### When no session:
```
No previous session found. Starting fresh workflow.
```

### When stale:
```
Found stale session (26 hours old):
- Workflow: health-security
- Phase: 2/5

[R]esume anyway, [A]rchive and start fresh, or [C]ancel?
```

## Token Cost

- Context read: ~100-150 tokens
- Log read (last 10 entries): ~200-300 tokens
- Total: ~300-450 tokens (only when resuming)

## Related Skills

- `save-session-context` — Save current state for later
- `load-project-context` — Load project structure

## Integration with Orchestrators

Health orchestrators should call this skill in Phase 0:

```markdown
## Phase 0: Session Check

1. Invoke `resume-session` skill
2. If valid session:
   - Ask user: Resume or fresh?
   - If resume: Jump to saved phase
3. If no session:
   - Proceed to Phase 1
4. Create new session context
```
