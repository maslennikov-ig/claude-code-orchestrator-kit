# Beads Decision Matrix

## When to Use What

| Scenario | Tool | Command |
|----------|------|---------|
| Large feature (>1 day) | Spec-kit → Beads | `/speckit.specify` → `/speckit.tobeads` |
| Small feature (<1 day) | Beads only | `bd create -t feature` |
| Bug fix | Beads | `bd create -t bug` |
| Tech debt | Beads | `bd create -t chore` |
| Research / spike | Beads formula | `bd mol wisp exploration` |
| Emergency fix | Beads formula | `bd mol wisp hotfix` |
| Health check | Beads formula | `bd mol wisp healthcheck` |
| Code review | Beads formula | `bd patrol run code-review` |
| Release | Beads formula | `bd mol wisp release` |

## Beads vs TodoWrite

| Use Beads When | Use TodoWrite When |
|----------------|-------------------|
| Multi-session work | Single session |
| Need persistence | Temporary tracking |
| Dependencies matter | Simple list |
| Team collaboration | Solo work |
| Audit trail needed | No history needed |

## Formula Selection

| Formula | Best For |
|---------|----------|
| `bigfeature` | Features requiring planning docs |
| `bugfix` | Standard bug fixes |
| `hotfix` | Production emergencies |
| `healthcheck` | Codebase audits |
| `codereview` | Structured code review |
| `release` | Version releases |
| `techdebt` | Debt remediation |
| `exploration` | Research, spikes, POCs |

## Priority Guidelines

| Priority | Use When |
|----------|----------|
| P0 | Blocks release, security critical |
| P1 | Critical bug, major impact |
| P2 | High priority, should do soon |
| P3 | Normal work (default) |
| P4 | Nice to have, backlog |

## Dependency Types

| Type | Meaning | Use When |
|------|---------|----------|
| `blocks` | This task blocks another | Task must complete first |
| `blocked-by` | This task is blocked | Waiting on another task |
| `discovered-from` | Found during other work | Emergent work |
| `parent` | Child of epic | Organizing under epic |
| `related` | Informational link | Cross-reference |
