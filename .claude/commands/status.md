---
description: Show Gastown status (convoys, agents, pending tasks)
---

Show a unified view of everything happening in Gastown.

**What you must do:**

1. Determine the rig name:
   ```bash
   RIG=$(basename "$(git rev-parse --show-toplevel)")
   ```

2. Run these commands and present a consolidated summary:

   Active convoys:
   ```bash
   gt convoy list
   ```

   Town status (running agents):
   ```bash
   gt status --fast
   ```

   Pending tasks ready for work:
   ```bash
   cd ~/gt/$RIG/mayor/rig && bd ready
   ```

**Present the results as a clear summary:**

- **Active Work**: List running convoys with their polecats and progress
- **Agents**: Which polecats are active and what they're doing
- **Ready Tasks**: Tasks available for assignment (no blockers)
- **Issues**: Any health warnings if present

Keep it concise. If everything is idle, just say "No active work. X tasks ready."
