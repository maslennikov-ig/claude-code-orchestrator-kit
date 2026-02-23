---
description: Give task to AI agent via Gastown (create bead + sling to polecat)
argument-hint: [--agent claude|codex|gemini] [--ab] [--all] <task description>
---

Dispatch a task to a Gastown AI agent. This is the primary way the user gives work to AI polecats.

**Important**: Ensure `gt` and `bd` are in PATH, then `cd ~/gt` before running `gt` commands.

**What you must do:**

1. Determine the rig name:
   ```bash
   RIG=$(basename "$(git rev-parse --show-toplevel)")
   ```
   Verify the rig exists: `gt rig list | grep -q "$RIG"`. If not found, tell user to run `/onboard` first.

2. Parse `$ARGUMENTS`:
   - `--agent <name>` — use specific agent (claude/codex/gemini). Default: claude
   - `--ab` — A/B test: dispatch to claude AND codex in parallel
   - `--all` — dispatch to all 3 agents (claude, codex, gemini) in parallel
   - Everything else is the task description

3. Create a bead for the task:
   ```bash
   cd ~/gt/$RIG/mayor/rig && bd create --title "<task description>" --type task
   ```
   Extract bead ID from output (format: `PREFIX-xxx`).

4. Sling the bead to polecat(s):

   **Single agent (default):**
   ```bash
   cd ~/gt && gt sling <bead-id> $RIG --agent <agent>
   ```

   **A/B test (--ab):** dispatch same bead to 2 agents, each gets its own polecat:
   ```bash
   cd ~/gt && gt sling <bead-id> $RIG --agent claude --merge=local
   cd ~/gt && gt sling <bead-id> $RIG --agent codex --merge=local
   ```

   **All agents (--all):** dispatch to all 3:
   ```bash
   cd ~/gt && gt sling <bead-id> $RIG --agent claude --merge=local
   cd ~/gt && gt sling <bead-id> $RIG --agent codex --merge=local
   cd ~/gt && gt sling <bead-id> $RIG --agent gemini --merge=local
   ```

   Note: `--merge=local` keeps changes on feature branches so user can compare results.

5. Show convoy status:
   ```bash
   cd ~/gt && gt convoy list
   ```

6. Report to user: bead ID, which agent(s) assigned, convoy status.

**Examples:**

```
/work Fix the login validation bug
  Single agent (claude): creates bead, slings to polecat

/work --agent codex Refactor the auth module
  Specific agent: slings to codex polecat

/work --ab Optimize database queries
  A/B test: claude + codex work in parallel on same task

/work --all Implement dark mode
  All 3 agents work in parallel, user picks best result
```

**Error handling:**
- If `bd create` fails, show the error and stop
- If `gt sling` fails, show the error but keep the bead (user can retry with `gt sling <id> $RIG`)
- If no task description provided, ask the user what they want to work on
- If rig not found, tell user to run `/onboard` first
