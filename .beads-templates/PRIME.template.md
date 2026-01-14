# Beads Context Injection Template
# =================================
#
# This template is used by `bd prime` to inject workflow context.
# Customize after running /beads-init.
#
# Variables to replace:
#   {{PREFIX}} - Your issue prefix (e.g., myproject)
#   {{PROJECT_NAME}} - Your project name

## SESSION CLOSE PROTOCOL (MANDATORY!)

**NEVER say "done" without completing these steps:**

```bash
git status              # 1. What changed?
git add <files>         # 2. Stage code
bd sync                 # 3. Sync beads
git commit -m "... ({{PREFIX}}-xxx)"  # 4. Commit with issue ID
bd sync                 # 5. Sync new changes
git push                # 6. Push to remote
```

**Work is NOT done until pushed!**

---

## Quick Reference

| Action | Command |
|--------|---------|
| Find work | `bd ready` |
| Take task | `bd update ID --status in_progress` |
| Create task | `bd create "Title" -t type -p priority` |
| Close task | `bd close ID --reason "..."` |
| Sync | `bd sync` |

---

## Multi-Terminal Safety

- Each terminal works on DIFFERENT issues
- Exclusive lock (30m timeout) prevents conflicts
- If issue is locked: `bd list --unlocked`

---

## Types & Priorities

**Types**: feature, bug, chore, docs, test, epic

**Priorities**:
- P0: Critical (blocks release)
- P1: Critical
- P2: High
- P3: Medium (default)
- P4: Low / backlog

---

## Emergent Work

Found something while working on {{PREFIX}}-xxx?

```bash
bd create "Found issue" -t bug --deps discovered-from:{{PREFIX}}-xxx
```

---

## Available Formulas

```bash
bd formula list
```

| Formula | Use When |
|---------|----------|
| bigfeature | Feature >1 day (Spec-kit → Beads) |
| bugfix | Standard bug fix |
| hotfix | Emergency production fix |
| healthcheck | Codebase health audit |
| codereview | Code review + fixes |
| release | Version release |
| techdebt | Technical debt work |
| exploration | Research / spike |

---

*Project: {{PROJECT_NAME}} | Prefix: {{PREFIX}}*
