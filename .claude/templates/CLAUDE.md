# Agent Instructions

> **IMPORTANT**: This file overrides default Claude Code behavior. Follow strictly.

## Quick Start: Gastown + Beads

| Command                           | What it does                |
| --------------------------------- | --------------------------- |
| `/work "task description"`        | Give task to AI agent       |
| `/work --agent codex "task"`      | Use specific runtime        |
| `/status`                         | See what's happening        |
| `bd ready`                        | Find available tasks        |
| `gt dashboard --open`             | Visual monitoring           |
| `git push`                        | Ship changes                |

> Everything below is reference. For daily work, these 6 commands are enough.

---

## Multi-Agent Orchestration with Gastown

This project uses **Gastown** (`gt`) for multi-agent orchestration and **Beads** (`bd`) for issue tracking. Global tools at `~/gt/`.

Runtimes: `claude` (default), `codex`, `gemini` — all subscription-based, no API billing.

### Core Rules

**1. GATHER CONTEXT FIRST** — Read code, search patterns, check commits. NEVER implement blindly.

**2. VERIFY** — Never trust agent output without verification:

- Read modified files (`Read` tool)
- Run quality gates (type-check, build, tests)
- Check for regressions

**3. NEVER DISCARD CHANGES**

- **FORBIDDEN**: `git reset`, `git checkout --`, `git stash` without explicit user request
- **ALWAYS** commit all uncommitted changes or ASK user first

### Task Management with Beads

```bash
# FIND WORK
bd ready                          # Available tasks (no blockers)

# GIVE TASK TO AGENT
/work Fix the login validation bug
/work --agent codex Refactor auth module

# MANUAL WORK
bd update <id> --status in_progress
# ... do the work ...
bd close <id> --reason "Done"

# CHECK STATUS
/status                           # Unified view

# SESSION END
git add . && git commit -m "..." && git push
```

### Infrastructure (Self-Managed)

All services auto-start on boot via systemd. **No manual intervention needed.**

- **Daemon** (`gastown-daemon.service`): Manages Dolt, heartbeats, patrols
- **Dolt**: Managed internally by daemon via `dolt_server` config in `~/gt/mayor/daemon.json`
- **Witness**: Monitors polecat health per rig (auto-spawned by daemon)
- **Refinery**: Merge queue processor (auto-spawned by daemon)
- **Deacon**: Health orchestrator (auto-spawned by daemon)

If something breaks:

```bash
RIG=$(basename "$(git rev-parse --show-toplevel)")
gt doctor --fix --rig $RIG       # Diagnose and auto-fix
gt daemon logs                   # Check daemon logs
systemctl --user restart gastown-daemon  # Restart everything
```

**NEVER start Dolt manually** (`gt dolt start`) — daemon manages it with health checks every 30s.

---

## Project Conventions

**File Organization**:
- Agents: `.claude/agents/{domain}/{orchestrators|workers}/`
- Commands: `.claude/commands/`
- Skills: `.claude/skills/{skill-name}/SKILL.md`
- Temporary: `.tmp/current/` (git ignored)
- Reports: `docs/reports/{domain}/{YYYY-MM}/`

**Code Standards**:
- Type-check + build must pass before commit
- No hardcoded credentials
- Follow conventional commits: `type(scope): summary`

<!-- PROJECT-SPECIFIC: Add your stack, deployment, and other project-specific sections below -->

---
