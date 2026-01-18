---
description: Process error logs from database - fetch, analyze, fix, mark resolved
---

# Process Error Logs

Execute the `process-logs` skill for automated error processing.

## Quick Start

1. Read `.claude/skills/process-logs/SKILL.md`
2. Follow the workflow phases directly
3. Use Task tool for complex fixes (delegate to subagents)
4. Run quality gates inline via Bash

## Workflow Summary

```
Fetch Errors → Analyze → Fix → Verify → Mark Resolved → Report
```

**Subagents**: database-architect, fullstack-nextjs-specialist, typescript-types-specialist
**Quality gates**: `pnpm type-check && pnpm build`

---

Now read and execute the skill: `.claude/skills/process-logs/SKILL.md`
