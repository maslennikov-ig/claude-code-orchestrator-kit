# Project Index: Claude Code Orchestrator Kit

> Quick navigation for AI agents. Updated: 2025-11-27
>
> **Purpose:** Helps agents understand project structure without reading entire codebase.

## Architecture

- **[CLAUDE.md](../../CLAUDE.md)** — Behavioral rules, orchestration patterns, main entry point
- **[docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)** — System design, C4 diagrams, workflow patterns
- **[docs/FAQ.md](../../docs/FAQ.md)** — Common questions and answers

## Core Domains

### Agents (.claude/agents/)
- **[agents/](agents/)** — 33+ specialized AI agents
  - **[health/orchestrators/](agents/health/orchestrators/)** — Bug, security, deps, cleanup workflows
  - **[health/workers/](agents/health/workers/)** — Bug-hunter, bug-fixer, security-scanner, etc.
  - **[development/workers/](agents/development/workers/)** — LLM, TypeScript, cost specialists
  - **[meta/workers/](agents/meta/workers/)** — meta-agent-v3, skill-builder-v2
  - Pattern: Orchestrator delegates to Workers via Task tool

### Commands (.claude/commands/)
- **[commands/](commands/)** — 19+ slash commands
  - Key: `health-*.md` — Health monitoring workflows
  - Key: `speckit.*.md` — Specification toolkit
  - Key: `push.md` — Release automation
  - Pattern: Commands trigger orchestrators or direct actions

### Skills (.claude/skills/)
- **[skills/](skills/)** — 15+ reusable utilities
  - Key: `run-quality-gate/` — Type-check, build, tests validation
  - Key: `validate-plan-file/` — JSON schema validation
  - Key: `rollback-changes/` — File restoration
  - Pattern: Stateless utilities, <100 lines, invoked via Skill tool

### MCP Configurations (mcp/)
- **[mcp/](../../mcp/)** — 7 MCP server configurations
  - Key: `.mcp.base.json` — Minimal (~600 tokens)
  - Key: `.mcp.serena.json` — LSP semantic search (~2500 tokens)
  - Key: `.mcp.full.json` — All servers (~6500 tokens)
  - Pattern: switch-mcp.sh for dynamic switching

## Temporary Files

- **[.tmp/current/](../../.tmp/current/)** — Active workflow artifacts (git-ignored)
  - `plans/` — Orchestrator plan files
  - `reports/` — Worker-generated reports
  - `session/` — Session context and logs

## Configuration

- **[.env.example](../../.env.example)** — Environment variables template
- **[switch-mcp.sh](../../switch-mcp.sh)** — MCP configuration switcher

## Patterns & Conventions

- **Orchestration:** Main Claude Code delegates to sub-agents via Task tool
- **Verification:** Always read modified files + run type-check after delegation
- **Quality Gates:** type-check, build, tests must pass before commit
- **Commits:** `/push patch` after each completed task

## Key Entry Points

| Purpose | File | Description |
|---------|------|-------------|
| Behavioral rules | `CLAUDE.md` | Read by Claude Code at session start |
| Agent selection | `settings.local.json` | Task tool subagent_type mapping |
| Health workflows | `commands/health-*.md` | Entry points for health checks |

## Recent Changes

- 2025-11-27: Added Serena MCP, DeksdenFlow integration started
- 2025-11-27: Added reuse-hunting workflow agents
- 2025-11-26: Updated agent configurations
