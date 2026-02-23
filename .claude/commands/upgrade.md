---
description: Safely upgrade Gastown and Beads
argument-hint: [gt|bd|all]
---

Safely upgrade Gastown (`gt`) and/or Beads (`bd`) binaries.

**Important**: Ensure `gt` and `bd` are in PATH before running commands.

**What you must do:**

1. Parse `$ARGUMENTS`:
   - `gt` — upgrade Gastown only
   - `bd` — upgrade Beads only
   - `all` or empty — upgrade both

2. **Pre-flight: save current state**
   ```bash
   gt --version 2>&1 | head -1
   bd --version 2>&1 | head -1
   cat ~/.local/share/systemd/user/gastown-daemon.service
   cat ~/gt/mayor/daemon.json
   gt rig list
   ```
   Save these outputs — you'll compare after upgrade.

3. **Stop daemon before upgrade**
   ```bash
   systemctl --user stop gastown-daemon
   ```

4. **Upgrade binaries**

   For Gastown:
   ```bash
   go install github.com/steveyegge/gastown/cmd/gt@latest
   ```
   If that fails (unreleased changes), build from source:
   ```bash
   cd /tmp && rm -rf gastown-src && git clone https://github.com/steveyegge/gastown.git gastown-src
   cd /tmp/gastown-src && go build -o "$(go env GOPATH)/bin/gt" ./cmd/gt
   ```

   For Beads:
   ```bash
   go install github.com/steveyegge/beads/cmd/bd@latest
   ```

5. **CRITICAL: Check if systemd service was overwritten**
   ```bash
   cat ~/.local/share/systemd/user/gastown-daemon.service
   ```

   The service file MUST contain these Environment lines (they are NOT in the default template):
   ```
   Environment="GT_TOWN_ROOT=$HOME/gt"
   Environment="GT_ROOT=$HOME/gt"
   Environment="PATH=<your go/bin, .local/bin, node, cargo, bun paths>:/usr/local/bin:/usr/bin:/bin"
   Environment="HOME=$HOME"
   ```

   If these lines are MISSING (e.g., `gt daemon enable-supervisor` was re-run), add them back.
   The `[Unit]` section must be `After=network.target` only — NO `Requires=gastown-dolt.service`.

   **Note**: You must expand `$HOME` and provide the actual full paths in the service file (systemd does not expand shell variables).

6. **Check daemon.json preserved**
   ```bash
   cat ~/gt/mayor/daemon.json
   ```
   Must contain `"dolt_server": { "enabled": true, "port": 3307, ... }` inside `patrols`.
   If missing — the daemon won't manage Dolt and everything will break.

7. **Restart and verify**
   ```bash
   echo '{"agents":{}}' > ~/gt/daemon/restart_state.json
   systemctl --user daemon-reload
   systemctl --user start gastown-daemon
   sleep 5
   gt daemon status
   gt dolt status
   ```

   Run doctor for all rigs:
   ```bash
   for RIG in $(gt rig list 2>/dev/null | awk '{print $1}'); do
     echo "=== Doctor: $RIG ==="
     gt doctor --fix --rig "$RIG"
   done
   ```

8. **Report to user:**
   - Old versions -> New versions
   - Doctor results per rig (passed/warnings/failures)
   - Whether any manual fixes were needed
   - Confirm Dolt is running as daemon child process

**Known risks:**
- `gt daemon enable-supervisor` overwrites systemd service (loses PATH)
- New gt version may add fields to daemon.json — check release notes
- Formula format may change — `gt doctor --fix` updates them
- `time.Duration` fields in daemon.json must be integers (nanoseconds), NOT strings like "30s"
