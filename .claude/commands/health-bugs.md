---
description: Bug detection and fixing workflow (inline orchestration)
---

# Bug Health Check

Execute the `bug-health-inline` skill for inline orchestration.

**You ARE the orchestrator.** Do not spawn a separate orchestrator agent.

## Quick Start

1. Read `.claude/skills/bug-health-inline/SKILL.md`
2. Follow the workflow phases directly
3. Use Task tool only for workers (bug-hunter, bug-fixer)
4. Run quality gates inline via Bash

## Workflow Summary

```
Pre-flight → Detect → [Fix by Priority] → Verify → Report
```

**Workers**: bug-hunter, bug-fixer
**Quality gates**: `pnpm type-check && pnpm build`
**Max iterations**: 3

---

Now read and execute the skill: `.claude/skills/bug-health-inline/SKILL.md`
