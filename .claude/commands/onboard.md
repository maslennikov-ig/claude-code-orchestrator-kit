---
description: Connect any project to Gastown multi-agent orchestration
argument-hint: [rig-name]
---

Connect the current project to Gastown for multi-agent AI orchestration. Run this from the project directory.

**Important**: Ensure `gt` and `bd` are in PATH before running commands.

**Kit location**: Determine the kit path by finding where this file lives:
```bash
KIT_PATH=$(dirname "$(dirname "$(dirname "$(readlink -f "$0" 2>/dev/null || echo ".")")")")
# Fallback: search common locations
for p in "$HOME/code/claude-code-orchestrator-kit" "$HOME/projects/claude-code-orchestrator-kit"; do
  [ -d "$p/.claude/templates" ] && KIT_PATH="$p" && break
done
```
Or set explicitly: `KIT_PATH="$HOME/code/claude-code-orchestrator-kit"`

**What you must do:**

## 1. Pre-flight checks

```bash
which gt && gt --version 2>&1 | head -1
which bd && bd --version 2>&1 | head -1
systemctl --user is-active gastown-daemon
git rev-parse --show-toplevel
```

All must succeed. If `gt`/`bd` not found — tell user to install them first. If daemon not active — `systemctl --user start gastown-daemon`.

## 2. Determine parameters

```bash
PROJECT_PATH=$(git rev-parse --show-toplevel)
```

Rig name: use `$ARGUMENTS` if provided, otherwise `basename "$PROJECT_PATH"`.

```bash
RIG=${ARGUMENTS:-$(basename "$PROJECT_PATH")}
```

Confirm with user: "Connecting project at `$PROJECT_PATH` as rig `$RIG`. Correct?"

## 3. Check if already connected

```bash
gt rig list 2>/dev/null
```

If `$RIG` already in the list — skip to step 7 (file copy). Tell user rig already exists.

## 4. Add rig to Gastown

```bash
cd ~/gt && gt rig add "$RIG" "$PROJECT_PATH"
```

This auto-provisions ~30 components: bare repo, clones, Dolt database, beads config, patrol molecules, agent beads, routes, settings.

If it fails, show error and stop.

## 5. Update daemon.json

Read `~/gt/mayor/daemon.json` and add the new rig to patrol arrays:

- Add `$RIG` to `patrols.witness.rigs[]` (if not already present)
- Add `$RIG` to `patrols.refinery.rigs[]` (if not already present)

Write the updated JSON back.

**Example** — if daemon.json has:
```json
"witness": { "rigs": ["mc2"] }
```
Change to:
```json
"witness": { "rigs": ["mc2", "newrig"] }
```

## 6. Restart daemon

```bash
echo '{"agents":{}}' > ~/gt/daemon/restart_state.json
systemctl --user restart gastown-daemon
sleep 5
gt daemon status
```

## 7. Run doctor

```bash
gt doctor --fix --rig "$RIG"
```

Report results. Warnings are OK for fresh rigs.

## 8. Beads initialization

Check if `.beads/` exists in the project:

```bash
ls "$PROJECT_PATH/.beads/config.yaml" 2>/dev/null
```

If NOT found — tell user they can run `/beads-init` to set up issue tracking.
If found — skip, beads already initialized.

## 9. Copy Gastown slash commands

Copy these files from the orchestrator kit to the project's `.claude/commands/`:

```bash
DEST="$PROJECT_PATH/.claude/commands"
mkdir -p "$DEST"
```

Files to copy:
- `$KIT_PATH/.claude/commands/work.md` → `$DEST/work.md`
- `$KIT_PATH/.claude/commands/status.md` → `$DEST/status.md`
- `$KIT_PATH/.claude/commands/upgrade.md` → `$DEST/upgrade.md`
- `$KIT_PATH/.claude/commands/onboard.md` → `$DEST/onboard.md`

**Before copying each file**: check if it already exists at destination. If it does, ask user whether to overwrite.

Use the Read tool to read each source file, then Write tool to write to destination.

## 10. Copy agent instruction templates

Copy base templates for all AI runtimes from the orchestrator kit:

```bash
## Note: KIT_PATH was determined in step 1 pre-flight
```

**Templates to copy** (source → destination in project root):
- `$KIT_PATH/.claude/templates/CLAUDE.md` → `$PROJECT_PATH/CLAUDE.md`
- `$KIT_PATH/.claude/templates/AGENTS.md` → `$PROJECT_PATH/AGENTS.md`
- `$KIT_PATH/.claude/templates/GEMINI.md` → `$PROJECT_PATH/GEMINI.md`

**Rules**:
- If the file **already exists** and **already contains "Gastown"** — skip it (already configured)
- If the file **already exists** but **does NOT contain "Gastown"** — append the Gastown sections from the template to the existing file (preserve project-specific content)
- If the file **does not exist** — copy the template as-is

After copying, replace `RIG_NAME` placeholder (if any) with the actual `$RIG` value.

These templates include:
- **CLAUDE.md**: Full Gastown orchestration rules, Quick Start, Infrastructure, Beads workflow, conventions
- **AGENTS.md**: Codex-compatible instructions with Gastown workflow, session end protocol
- **GEMINI.md**: Gemini-compatible instructions with Gastown workflow

Each template has a `<!-- PROJECT-SPECIFIC -->` comment — user adds their stack details there later.

## 11. Report

Present a summary:

```
## Onboarding Complete

**Project**: $PROJECT_PATH
**Rig**: $RIG

### What was done:
- [ ] gt rig add (30 auto-provisioned components)
- [ ] daemon.json updated (witness + refinery patrols)
- [ ] Daemon restarted
- [ ] gt doctor results: X passed, Y warnings, Z failures
- [ ] Slash commands copied: /work, /status, /upgrade, /onboard
- [ ] Agent instruction files: CLAUDE.md, AGENTS.md, GEMINI.md
- [ ] Beads: initialized / already present / user to run /beads-init

### Available commands:
- /work "task" — dispatch to AI agent
- /status — see what's happening
- /upgrade — safely update gt/bd
- bd ready — find tasks

### Next steps:
1. Run /beads-init if beads not initialized
2. Try: /work "Hello from new rig"
3. Check: /status
```
