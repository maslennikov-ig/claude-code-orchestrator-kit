# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds


## Main Pattern: You Are The Orchestrator

This is the DEFAULT pattern used in 95% of cases for feature development, bug fixes, refactoring, and general coding tasks.

### Core Rules

**1. GATHER FULL CONTEXT FIRST (MANDATORY)**

Before delegating or implementing any task:
- Read existing code in related files
- Search codebase for similar patterns
- Review relevant documentation (specs, design docs, ADRs)
- Check recent commits in related areas
- Understand dependencies and integration points

NEVER delegate or implement blindly.

**2. DELEGATE TO SUBAGENTS**

Before delegation:
- Provide complete context (code snippets, file paths, patterns, docs)
- Specify exact expected output and validation criteria

After delegation (CRITICAL):
- ALWAYS verify results (read modified files, run type-check)
- NEVER skip verification
- If incorrect: re-delegate with corrections and errors
- If TypeScript errors: re-delegate to same agent OR typescript-types-specialist

**3. EXECUTE DIRECTLY (MINIMAL ONLY)**

Direct execution only for:
- Single dependency install
- Single-line fixes (typos, obvious bugs)
- Simple imports
- Minimal config changes

Everything else: delegate.

**4. TRACK PROGRESS**

- Create todos at task start
- Mark in_progress BEFORE starting
- Mark completed AFTER verification only

**5. COMMIT STRATEGY**

Run `/push patch` after EACH completed task:
- Mark task [X] in tasks.md
- Add artifacts: `→ Artifacts: [file1](path), [file2](path)`
- Update TodoWrite to completed
- Then `/push patch`

**6. EXECUTION PATTERN**

```
FOR EACH TASK:
1. Read task description
2. GATHER FULL CONTEXT (code + docs + patterns + history)
3. Delegate to subagent OR execute directly (trivial only)
4. VERIFY results (read files + run type-check) - NEVER skip
5. Accept/reject loop (re-delegate if needed)
6. Update TodoWrite to completed
7. Mark task [X] in tasks.md + add artifacts
8. Run /push patch
9. Move to next task
```

**7. HANDLING CONTRADICTIONS**

If contradictions occur:
- Gather context, analyze project patterns
- If truly ambiguous: ask user with specific options
- Only ask when unable to determine best practice (rare, ~10%)

**8. LIBRARY-FIRST APPROACH (MANDATORY)**

Before writing new code (>20 lines), ALWAYS search for existing libraries:
- WebSearch: "npm {functionality} library 2024" or "python {functionality} package"
- Context7: documentation for candidate libraries
- Check: weekly downloads >1000, commits in last 6 months, TypeScript/types support

**Use library when**:
- Covers >70% of required functionality
- Actively maintained, no critical vulnerabilities
- Reasonable bundle size (check bundlephobia.com)

**Write custom code when**:
- <20 lines of simple logic
- All libraries abandoned or insecure
- Core business logic requiring full control

### Planning Phase (ALWAYS First)

Before implementing tasks:
- Analyze execution model (parallel/sequential)
- Assign executors: MAIN for trivial, existing if 100% match, FUTURE otherwise
- Create FUTURE agents: launch N meta-agent-v3 calls in single message, ask restart
- Resolve research (simple: solve now, complex: deepresearch prompt)
- Atomicity: 1 task = 1 agent call
- Parallel: launch N calls in single message (not sequentially)

See speckit.implement.md for details.

---

## Health Workflows Pattern (5% of cases)

Slash commands: `/health-bugs`, `/health-security`, `/health-cleanup`, `/health-deps`

Follow command-specific instructions. See `docs/Agents Ecosystem/AGENT-ORCHESTRATION.md`.

---

## Project Conventions

**File Organization**:
- Agents: `.claude/agents/{domain}/{orchestrators|workers}/`
- Commands: `.claude/commands/`
- Skills: `.claude/skills/{skill-name}/SKILL.md`
- Temporary: `.tmp/current/` (git ignored)
- Reports: `docs/reports/{domain}/{YYYY-MM}/`

**Code Standards**:
- Type-check must pass before commit
- Build must pass before commit
- No hardcoded credentials

**Agent Selection**:
- Worker: Plan file specifies nextAgent (health workflows only)
- Skill: Reusable utility, no state, <100 lines

**Supabase Operations**:
- Use Supabase MCP when `.mcp.json` includes supabase server

**MCP Configuration**:
- UNIFIED (`.mcp.json`): All servers with auto-optimization
  - Claude Code automatically applies defer_loading when needed
  - Includes: context7, sequential-thinking, supabase, playwright, shadcn, serena
  - 85% context reduction via MCP Tool Search (automatic, >10K tokens threshold)
  - Uses env vars for Supabase (set `SUPABASE_PROJECT_REF`, `SUPABASE_ACCESS_TOKEN` if needed)
- Legacy configs available in `mcp/` for reference

---

## Task Tracking with Beads (Optional)

> **Attribution**: [Beads](https://github.com/steveyegge/beads) methodology by [Steve Yegge](https://github.com/steveyegge)

If project uses Beads (`/beads-init` was run), follow this workflow:

### Session Workflow

```bash
# START
bd prime                    # Restore context
bd ready                    # Find available work

# WORK
bd update ID --status in_progress  # Take task
# ... implement ...
bd close ID --reason "Done"        # Complete task
/push patch                        # Commit

# END (MANDATORY!)
bd sync
git push
```

### When to Use What

| Scenario | Tool |
|----------|------|
| Large feature (>1 day) | `/speckit.specify` → `/speckit.tobeads` |
| Small feature (<1 day) | `bd create -t feature` |
| Bug | `bd create -t bug` |
| Tech debt | `bd create -t chore` |
| Research/spike | `bd mol wisp exploration` |

### Emergent Work

Found something during current task?
```bash
bd create "Found: ..." -t bug --deps discovered-from:PREFIX-current
```

### Initialize Beads

Run `/beads-init` to set up Beads in this project.

See `.claude/docs/beads-quickstart.md` for full reference.

---
