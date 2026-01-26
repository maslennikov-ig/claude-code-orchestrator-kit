---
name: process-logs
description: Process error logs from admin panel - fetch new errors, analyze, create tasks, fix, and mark resolved
version: 1.8.0
---

# Process Error Logs

Automated workflow for processing error logs from `/admin/logs`.

## CRITICAL REQUIREMENTS

> **YOU MUST FOLLOW THESE RULES. NO EXCEPTIONS.**

### 1. BEADS IS MANDATORY

**EVERY error MUST have a Beads task.** No direct fixes without tracking.

```bash
# ALWAYS run this FIRST for each error:
bd create --type=bug --priority=<1-3> --title="Fix: <error_message>" --files "<relevant_files>"
bd update <task_id> --status=in_progress
```

### 2. TASK COMPLEXITY ROUTING

**Route tasks by complexity:**

| Complexity  | Examples                              | Action                   |
| ----------- | ------------------------------------- | ------------------------ |
| **Simple**  | Typo fix, single import, config value | Execute directly         |
| **Medium**  | Multi-file fix, migration, API change | **Delegate to subagent** |
| **Complex** | Architecture change, new feature      | Ask user first           |

**Subagent selection for MEDIUM tasks:**

- DB/migration → `database-architect`
- API/tRPC → `fullstack-nextjs-specialist`
- Types → `typescript-types-specialist`
- UI → `nextjs-ui-designer`

**Execute directly for SIMPLE tasks:**

- Single-line fix (typo, wrong value)
- Import path correction
- Config constant change
- Comment fix

### 3. CONTEXT7 IS MANDATORY

**ALWAYS query documentation before implementing:**

```
mcp__context7__resolve-library-id → mcp__context7__query-docs
```

### 4. BUG FIXING PRINCIPLES

> **This is PRODUCTION. Every bug matters.**

**Fix fundamentally, not superficially:**

- Find and fix the ROOT CAUSE, not just symptoms
- If error happens in function X but cause is in function Y → fix Y
- Don't add workarounds/hacks that mask the problem
- Ask: "Why did this happen?" until you reach the actual cause

**Never ignore errors:**

- Every error indicates a real problem
- "Works most of the time" is NOT acceptable
- External service errors → add retry logic or graceful degradation
- Config warnings → fix config or make truly optional

**Propose improvements:**

- If you see code that could be better → create separate Beads task
- If fix reveals related issues → document them
- If pattern repeats → suggest refactoring to prevent future bugs
- Format: `bd create --type=chore --title="Improve: <description>"`

**Quality over speed:**

- Take time to understand the full context
- Test the fix mentally: "What else could break?"
- Check for similar patterns elsewhere in codebase
- One good fix > multiple quick patches

### 5. LOG NOTES (MANDATORY)

**Always write notes when updating log status.** Keep it brief, in English.

| Status        | What to write in notes                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------ |
| `resolved`    | Root cause + fix applied. Example: `Missing constraint. Added 'approved' to enum via migration.` |
| `auto_muted`  | **System-assigned.** Don't change. Skip these errors in processing.                              |
| `ignored`     | **Never use.** Fix or ask user.                                                                  |
| `to_verify`   | Why pending + what to check. Example: `External API timeout. Monitor for 24h.`                   |
| `in_progress` | Beads task ID. Example: `Working on mc2-5ch`                                                     |

**Format:** `<root_cause>. <action_taken>.` — Max 100 chars.

**Examples:**

- `ESM import conflict. Renamed generator.ts to generator-node.ts.`
- `Constraint missing 'approved'. Added via migration 20250115_fix_status.`
- `Cloudflare 500. External issue, retry logic already exists. Monitoring.`

### 6. AUTO-MUTED ERRORS

Some errors are **automatically ignored** by the system with status `auto_muted`. These are expected events, NOT bugs.

**Current auto-mute rules** (from `src/shared/logger/auto-classification.ts`):

| Pattern                            | Reason            | Description                                |
| ---------------------------------- | ----------------- | ------------------------------------------ |
| `Redis connection (ended\|closed)` | graceful_shutdown | Redis disconnects during app restart       |
| `graceful.*shutdown`               | graceful_shutdown | Server shutdown events during deploys      |
| `/api/trpc/health.*404`            | monitoring_probe  | tRPC health endpoint probes (Uptime Kuma)  |
| `/health.*404`                     | monitoring_probe  | Generic health check probes                |
| `Cloudflare.*5\d{2}`               | external_service  | Cloudflare edge errors (502, 503, 521)     |
| `ECONNRESET.*external`             | external_service  | External API connection resets             |
| `Layer failed, trying next`        | cascading_repair  | Repair layer failed, trying next layer     |
| `Critique-revise attempt failed`   | cascading_repair  | Layer 2 retry attempt failed               |
| `Zod.*validation failed.*Layer`    | cascading_repair  | Layer 1 validation failed, escalating      |
| `Job stalled`                      | job_lifecycle     | BullMQ job restarted (long LLM operations) |
| `Unexpected exit code: 10`         | job_lifecycle     | Worker TTL timeout (10 min), will retry    |
| `No RAG chunks found`              | expected_behavior | Course without docs, generates w/o RAG     |
| `Mermaid.*fallback.*used`          | graceful_fallback | Diagram gen failed, fallback to text       |

**Total rules: 29** (test validates sync with code)

**When you see `auto_muted` errors:**

- Skip them in processing — they don't need fixes
- If you see a pattern that should be auto-muted, add it to `auto-classification.ts`

**How to add a new auto-mute rule:**

1. Edit `packages/course-gen-platform/src/shared/logger/auto-classification.ts`:

   ```typescript
   {
     pattern: /your-pattern/i,
     reason: 'category',  // graceful_shutdown | monitoring_probe | external_service
     description: 'Why this is expected',
   }
   ```

2. Update this SKILL.md with the new pattern

**When NOT to auto-mute:**

- Errors that SOMETIMES indicate real problems
- New error types (analyze first, then decide)
- Anything affecting user experience

### 7. SEARCH SIMILAR PROBLEMS FIRST (MANDATORY)

**Before fixing ANY error, search BOTH sources:**

#### 7a. Search in Beads (closed bug tasks)

```bash
# Search by error keywords
bd search "<keyword>" --type=bug --status=closed

# Example searches:
bd search "constraint violation"
bd search "tRPC timeout"
bd search "undefined property"
```

**What to look for in Beads:**

- Similar error patterns in task titles
- Root cause analysis in task descriptions
- Fix approach and files changed

#### 7b. Search in error_logs (resolved errors)

```sql
-- Search similar errors by message (use mcp__supabase__execute_sql)
SELECT el.id, el.error_message, el.severity, lis.status, lis.notes, el.created_at
FROM error_logs el
LEFT JOIN log_issue_status lis ON lis.log_id = el.id AND lis.log_type = 'error_log'
WHERE to_tsvector('english', el.error_message) @@ plainto_tsquery('english', '<keyword>')
  AND lis.status = 'resolved'
ORDER BY el.created_at DESC
LIMIT 5;
```

**What to search for:**

- Key error terms: `constraint`, `undefined`, `timeout`, `not found`
- Function/module names from stack trace
- Error codes or specific identifiers

#### 7c. If found similar resolved issue

1. **From Beads**: Read task description for root cause and fix approach
2. **From error_logs**: Read the `notes` field — contains root cause and fix
3. Apply same solution pattern if applicable
4. **Reference in your notes**: `Similar to mc2-xxx / <date>. Same fix applied.`

#### 7d. If NOT found — create Beads task (MANDATORY)

**Every new error MUST have a Beads task before fixing:**

```bash
# 1. Create task with all required fields
bd create --type=bug --priority=<1-3> --title="Fix: <error_message>" --files "<relevant_files>"

# 2. Start working
bd update <task_id> --status=in_progress

# 3. After fix - close with detailed reason
bd close <task_id> --reason="Root cause: <why>. Fix: <what was done>."
```

**Beads task MUST include:**

- Clear title with error essence
- Priority based on severity (CRITICAL=1, ERROR=2, WARNING=3)
- Files that will be modified (`--files`)
- Closing reason with root cause explanation

## Usage

Invoke via: `/process-logs` or "обработай логи ошибок"

## Workflow

### Step 1: Fetch New Errors

**IMPORTANT:** The `/admin/logs` UI shows errors from **TWO tables**:

1. `error_logs` — system errors, validation failures, worker errors
2. `generation_trace` (where `error_data IS NOT NULL`) — LLM generation errors

**Both tables must be checked.** Logs without a `log_issue_status` record show as "Новый" (new) in the UI.

#### 1a. Check error_logs

```sql
-- Use mcp__supabase__execute_sql
-- NOTE: This excludes auto_muted errors (they are handled automatically)
SELECT el.id, el.severity, el.error_message, el.metadata, el.stack_trace,
       el.course_id, el.lesson_id, el.request_id, el.trpc_path, el.trpc_input, el.attempted_value
FROM error_logs el
LEFT JOIN log_issue_status lis ON lis.log_id = el.id AND lis.log_type = 'error_log'
WHERE lis.id IS NULL OR (lis.status NOT IN ('resolved', 'ignored', 'auto_muted'))
ORDER BY
  CASE el.severity WHEN 'CRITICAL' THEN 1 WHEN 'ERROR' THEN 2 ELSE 3 END,
  el.created_at DESC
LIMIT 20;
```

#### 1b. Check generation_trace (LLM errors)

```sql
-- generation_trace with error_data shows as ERROR in UI
SELECT gt.id, gt.created_at, gt.stage, gt.phase, gt.step_name, gt.course_id,
       (gt.error_data->>'message')::text as error_message
FROM generation_trace gt
LEFT JOIN log_issue_status lis ON gt.id = lis.log_id AND lis.log_type = 'generation_trace'
WHERE gt.error_data IS NOT NULL
  AND (lis.id IS NULL OR lis.status NOT IN ('resolved', 'ignored', 'auto_muted'))
ORDER BY gt.created_at DESC
LIMIT 20;
```

#### 1c. Quick count check

```sql
-- Quick check: how many "new" errors in each table?
SELECT
  'error_logs' as source,
  (SELECT COUNT(*) FROM error_logs el
   LEFT JOIN log_issue_status lis ON el.id = lis.log_id AND lis.log_type = 'error_log'
   WHERE lis.id IS NULL) as new_count
UNION ALL
SELECT
  'generation_trace' as source,
  (SELECT COUNT(*) FROM generation_trace gt
   LEFT JOIN log_issue_status lis ON gt.id = lis.log_id AND lis.log_type = 'generation_trace'
   WHERE gt.error_data IS NOT NULL AND lis.id IS NULL) as new_count;
```

### Step 1.5: Filter by Environment (IMPORTANT)

> **CRITICAL**: Both DEV and STAGE are production-like servers. ALL errors on these
> environments must be investigated and fixed. Only LOCAL (NULL) can be bulk-resolved.

The `error_logs` table has an `environment` column that indicates where the error occurred:

| Value     | Environment    | Action                                            |
| --------- | -------------- | ------------------------------------------------- |
| `NULL`    | Local dev      | **Bulk resolve** — local testing/development only |
| `'dev'`   | Dev server     | **MUST FIX** — real errors affecting developers   |
| `'stage'` | Staging (prod) | **MUST FIX** — real production errors             |

**Always check environment distribution first:**

```sql
-- Check how many errors per environment
SELECT environment, COUNT(*) as count
FROM error_logs el
LEFT JOIN log_issue_status lis ON lis.fingerprint = el.fingerprint
WHERE lis.id IS NULL
GROUP BY environment
ORDER BY count DESC;
```

**Bulk resolve LOCAL errors only:**

```sql
-- Bulk resolve ONLY local environment errors (environment IS NULL)
-- NEVER bulk resolve dev or stage errors - they must be investigated individually!
WITH local_fingerprints AS (
  SELECT DISTINCT ON (el.fingerprint) el.id, el.fingerprint
  FROM error_logs el
  LEFT JOIN log_issue_status lis ON lis.fingerprint = el.fingerprint
  WHERE lis.id IS NULL
    AND el.environment IS NULL
    AND el.fingerprint IS NOT NULL
  ORDER BY el.fingerprint, el.created_at DESC
)
INSERT INTO log_issue_status (log_type, log_id, status, notes, fingerprint, updated_at)
SELECT 'error_log', lf.id, 'resolved', 'Local environment: Testing/development errors', lf.fingerprint, NOW()
FROM local_fingerprints lf
ON CONFLICT (log_type, log_id) DO UPDATE SET status = 'resolved', notes = EXCLUDED.notes, updated_at = NOW();
```

**Focus on server errors (dev + stage):**

```sql
-- Get only SERVER errors (dev and stage environments)
SELECT
  el.environment,
  el.fingerprint,
  el.severity,
  MIN(el.error_message) as error_message,
  COUNT(*) as count,
  MAX(el.created_at) as last_seen
FROM error_logs el
LEFT JOIN log_issue_status lis ON lis.fingerprint = el.fingerprint
WHERE lis.id IS NULL
  AND el.fingerprint IS NOT NULL
  AND el.environment IS NOT NULL  -- Exclude local (NULL)
GROUP BY el.environment, el.fingerprint, el.severity
ORDER BY
  CASE el.severity WHEN 'CRITICAL' THEN 1 WHEN 'ERROR' THEN 2 ELSE 3 END,
  COUNT(*) DESC
LIMIT 20;
```

**Why this matters:**

- Local testing generates thousands of errors (incomplete data, experiments)
- Dev and stage servers have real errors that need investigation
- Bulk resolving only local (NULL) errors saves time without missing real bugs

### Step 2: For EACH Error (Loop)

```
FOR each error:
  1. CREATE BEADS TASK (MANDATORY):
     bd create --type=bug --priority=<1-3> --title="Fix: <message>" --files "<files>"
     bd update <id> --status=in_progress

  2. ANALYZE error type and SELECT subagent:
     - DB constraint → database-architect
     - tRPC/API → fullstack-nextjs-specialist
     - Types → typescript-types-specialist
     - UI → nextjs-ui-designer

  3. QUERY context7 for relevant docs

  4. DELEGATE using Task tool:
     Task(subagent_type="<selected>", prompt="Fix error: <details>...")

  5. VERIFY results (MANDATORY):
     - Read tool: check modified files
     - Bash: pnpm type-check && pnpm build
     - If errors → re-delegate

  6. MARK resolved in DB:
     -- For error_logs:
     INSERT INTO log_issue_status (log_type, log_id, status, notes, updated_at)
     VALUES ('error_log', '<id>', 'resolved', 'Fixed: <desc>', NOW())
     ON CONFLICT (log_type, log_id) DO UPDATE SET status = 'resolved', notes = EXCLUDED.notes, updated_at = NOW();

     -- For generation_trace:
     INSERT INTO log_issue_status (log_type, log_id, status, notes, updated_at)
     VALUES ('generation_trace', '<id>', 'resolved', 'Fixed: <desc>', NOW())
     ON CONFLICT (log_type, log_id) DO UPDATE SET status = 'resolved', notes = EXCLUDED.notes, updated_at = NOW();

  7. CLOSE Beads task:
     bd close <id> --reason="Fixed"
```

### Step 3: Summary Report

```markdown
## Log Processing Summary

| Severity | Fixed | Pending | To Verify |
| -------- | ----- | ------- | --------- |
| CRITICAL | X     | Y       | Z         |
| ERROR    | X     | Y       | Z         |
| WARNING  | X     | Y       | Z         |

### Beads Tasks Created:

- mc2-xxx: <description> → <status>

### Pending (need user input):

- <log_id>: <reason>
```

## Subagent Delegation Examples

### DB Constraint Error

```
Task(
  subagent_type="database-architect",
  prompt="Fix DB constraint violation in error_logs.
  Error: <full_error_message>
  Context: <stack_trace>
  Course: <course_id>
  Create migration to fix the constraint."
)
```

### tRPC/API Error

```
Task(
  subagent_type="fullstack-nextjs-specialist",
  prompt="Fix tRPC error in <trpc_path>.
  Error: <full_error_message>
  Input: <trpc_input>
  Stack: <stack_trace>
  Fix the API endpoint."
)
```

### Type Error

```
Task(
  subagent_type="typescript-types-specialist",
  prompt="Fix TypeScript type error.
  Error: <full_error_message>
  File: <file_path>
  Fix types and ensure compatibility."
)
```

## Verification Checklist

Before marking ANY error as resolved:

- [ ] Beads task exists for this error
- [ ] Subagent was used (if not trivial fix)
- [ ] Modified files reviewed with Read tool
- [ ] `pnpm type-check` passes
- [ ] `pnpm build` passes
- [ ] No new errors introduced
- [ ] Beads task closed with reason

## Error Categories

| Pattern                | Category      | Subagent                      | Priority |
| ---------------------- | ------------- | ----------------------------- | -------- |
| `violates.*constraint` | DB constraint | `database-architect`          | 1        |
| `tRPC error`           | API bug       | `fullstack-nextjs-specialist` | 2        |
| `Type.*error`          | Type error    | `typescript-types-specialist` | 2        |
| `Error querying`       | Query bug     | `database-architect`          | 2        |
| Config missing         | Config issue  | **ASK USER**                  | 3        |
| External service       | External      | mark `to_verify`              | 3        |
| Redis shutdown         | Expected      | **SKIP** (auto_muted)         | -        |
| Health probe 404       | Expected      | **SKIP** (auto_muted)         | -        |

**Errors with status `auto_muted` are automatically ignored by the system. Skip them.**

## Reference Docs

- Admin Logs Guide: `.claude/docs/admin-logs-guide.md`
- Error Types: `packages/course-gen-platform/src/shared/logger/types.ts`
- Logs Router: `packages/course-gen-platform/src/server/routers/admin/logs.ts`
- CLAUDE.md: Main orchestration rules

## Architecture Note

The `/admin/logs` page aggregates errors from **two sources**:

| Table              | log_type             | What it contains                            |
| ------------------ | -------------------- | ------------------------------------------- |
| `error_logs`       | `'error_log'`        | System errors, validation, worker failures  |
| `generation_trace` | `'generation_trace'` | LLM errors (where `error_data IS NOT NULL`) |

Status is tracked in `log_issue_status` table with composite key `(log_type, log_id)`.

**UI Logic:** If no `log_issue_status` record exists → status shows as "Новый" (new).

### Grouped View (fingerprint)

The UI has two views:

1. **List view** — individual logs, status by `log_id`
2. **Grouped view** — errors grouped by `fingerprint`, status by `fingerprint`

**Auto-sync trigger** (`trg_sync_log_status_fingerprint`):

- When you INSERT/UPDATE `log_issue_status` for an `error_log`
- The trigger automatically copies `fingerprint` from `error_logs`
- This ensures grouped view shows correct status

**IMPORTANT:** You don't need to manually handle fingerprint — the trigger does it automatically. Just use the standard `INSERT INTO log_issue_status` by `log_id`.
