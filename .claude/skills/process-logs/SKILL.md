---
name: process-logs
description: Process error logs from database - fetch new errors, analyze, fix, and mark resolved. Automates bug fixing workflow.
version: 1.0.0
---

# Process Error Logs

Automated workflow for processing error logs from your database. Fetches new errors, analyzes root cause, delegates fixes to specialized agents, and marks as resolved.

## Prerequisites

Before using this skill, you need:

1. **Error logging table** in your database (see `prompts/setup-error-logging.md`)
2. **Database access** via MCP server (Supabase, Postgres, etc.)
3. **Quality gate commands** (`pnpm type-check`, `pnpm build`, or similar)

## Usage

Invoke via: `/process-logs` or "process error logs"

## Workflow Overview

```
Fetch New Errors → Analyze Each → Fix (delegate or direct) → Verify → Mark Resolved
```

---

## Phase 1: Fetch New Errors

Query your error_logs table for unresolved errors:

```sql
-- Adjust table/column names for your project
SELECT id, severity, error_message, stack_trace, metadata, created_at
FROM error_logs
WHERE status IS NULL OR status NOT IN ('resolved', 'ignored', 'auto_muted')
ORDER BY
  CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'ERROR' THEN 2 ELSE 3 END,
  created_at DESC
LIMIT 20;
```

**If no errors found:** Report "No new errors to process" and exit.

---

## Phase 2: For Each Error

### Step 2.1: Analyze Error Type

Determine the category and appropriate handler:

| Error Pattern | Category | Handler | Priority |
|---------------|----------|---------|----------|
| `violates.*constraint` | DB constraint | `database-architect` | 1 |
| `tRPC error`, API failure | API bug | `fullstack-nextjs-specialist` | 2 |
| `Type.*error`, TypeScript | Type error | `typescript-types-specialist` | 2 |
| `Error querying`, DB error | Query bug | `database-architect` | 2 |
| Single-line fix, typo | Simple fix | **Execute directly** | 3 |
| Config missing | Config issue | **Ask user** | 3 |
| External service error | External | Mark `to_verify` | 3 |

### Step 2.2: Search Similar Resolved Errors

Before fixing, check if similar issue was resolved before:

```sql
SELECT id, error_message, notes, created_at
FROM error_logs
WHERE status = 'resolved'
  AND error_message ILIKE '%<keyword>%'
ORDER BY created_at DESC
LIMIT 5;
```

**If found:** Apply same solution pattern, reference in notes.

### Step 2.3: Fix the Error

**For SIMPLE fixes** (single-line, typo, import):
- Execute directly using Edit tool
- Verify with quality gates

**For MEDIUM/COMPLEX fixes** (multi-file, migration, architecture):
- Delegate to appropriate subagent via Task tool:

```
Task(
  subagent_type="<selected-agent>",
  prompt="Fix error in production logs.

  Error: <full_error_message>
  Stack: <stack_trace>
  Context: <relevant_context>

  Requirements:
  1. Find and fix the ROOT CAUSE
  2. Ensure type-check and build pass
  3. Document what was changed"
)
```

### Step 2.4: Verify Fix

**MANDATORY before marking resolved:**

```bash
pnpm type-check
pnpm build
```

- If PASS → proceed to mark resolved
- If FAIL → re-analyze, re-fix, or ask user

### Step 2.5: Mark as Resolved

Update the error status in database:

```sql
UPDATE error_logs
SET status = 'resolved',
    notes = '<root_cause>. <action_taken>.',
    resolved_at = NOW()
WHERE id = '<error_id>';
```

**Notes format:** `<root_cause>. <action_taken>.` — Max 100 chars.

**Examples:**
- `ESM import conflict. Renamed generator.ts to generator-node.ts.`
- `Missing DB constraint. Added 'approved' to enum via migration.`
- `Null pointer in API. Added optional chaining to response handler.`

---

## Phase 3: Summary Report

After processing all errors, generate summary:

```markdown
## Error Processing Summary

| Severity | Fixed | Pending | To Verify |
|----------|-------|---------|-----------|
| CRITICAL | X     | Y       | Z         |
| ERROR    | X     | Y       | Z         |
| WARNING  | X     | Y       | Z         |

### Fixed:
- <error_id>: <brief_description> → resolved

### Pending (need user input):
- <error_id>: <reason>

### To Verify (external/monitoring):
- <error_id>: <what_to_check>
```

---

## Subagent Delegation Examples

### Database Error

```
Task(
  subagent_type="database-architect",
  prompt="Fix DB constraint violation.
  Error: violates check constraint 'status_check'
  Table: lessons
  Attempted value: 'approved'
  Create migration to add the missing value to enum."
)
```

### API Error

```
Task(
  subagent_type="fullstack-nextjs-specialist",
  prompt="Fix tRPC error in lesson.approve endpoint.
  Error: Cannot read properties of undefined
  Input: { lessonId: '...' }
  Stack: at LessonRouter.approve (lesson.ts:142)
  Fix the null handling in the API endpoint."
)
```

### Type Error

```
Task(
  subagent_type="typescript-types-specialist",
  prompt="Fix TypeScript type mismatch.
  Error: Type 'string' is not assignable to type 'Status'
  File: src/types/lesson.ts
  Ensure type compatibility across the codebase."
)
```

---

## Bug Fixing Principles

### Fix Root Cause, Not Symptoms

- Find WHY the error happened, not just WHERE
- If error in function X but cause is in function Y → fix Y
- Ask "Why?" until you reach the actual cause

### Never Ignore Errors

- Every error indicates a real problem
- "Works most of the time" is NOT acceptable
- External service errors → add retry logic or graceful degradation

### Quality Over Speed

- Take time to understand full context
- Check for similar patterns elsewhere
- One good fix > multiple quick patches

### Document Everything

- Always write notes when resolving
- Future you will thank present you
- Notes help identify patterns over time

---

## Auto-Mute Rules (Optional)

Some "errors" are expected behavior. Consider auto-muting:

| Pattern | Reason | Why Not a Bug |
|---------|--------|---------------|
| `Redis connection ended` | graceful_shutdown | App restart |
| `/health 404` | monitoring_probe | Health checks |
| `Cloudflare 5XX` | external_service | Not your bug |
| `Job stalled` | job_lifecycle | Long operations |

**Implementation:** Add auto-classification logic to your error logger.

---

## Verification Checklist

Before marking ANY error as resolved:

- [ ] Root cause identified
- [ ] Fix implemented (not workaround)
- [ ] Modified files reviewed
- [ ] `type-check` passes
- [ ] `build` passes
- [ ] No new errors introduced
- [ ] Notes documented

---

## Customization

Adapt this skill to your project:

1. **Table names**: Change `error_logs` to your table
2. **Status values**: Adjust to your enum
3. **Quality gates**: Use your build commands
4. **Subagents**: Use agents available in your setup
