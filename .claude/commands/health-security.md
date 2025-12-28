---
description: Security vulnerability detection and remediation workflow (inline orchestration)
---

# Security Health Check

Execute the `security-health-inline` skill for inline orchestration.

**You ARE the orchestrator.** Do not spawn a separate orchestrator agent.

## Quick Start

1. Read `.claude/skills/security-health-inline/SKILL.md`
2. Follow the workflow phases directly
3. Use Task tool only for workers (security-scanner, vulnerability-fixer)
4. Run quality gates inline via Bash

## Workflow Summary

```
Pre-flight → Detect → [Fix by Priority] → Verify → Report
```

**Workers**: security-scanner, vulnerability-fixer
**Quality gates**: `pnpm type-check && pnpm build`
**Max iterations**: 3

---

Now read and execute the skill: `.claude/skills/security-health-inline/SKILL.md`
