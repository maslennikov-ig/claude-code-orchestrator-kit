# Setup Health Workflows with Beads Integration

This prompt helps you set up complete health workflows (`/health-bugs`, `/health-security`, `/health-deps`, `/health-cleanup`, `/health-reuse`) with Beads issue tracking.

## What You'll Get

1. **Beads CLI** for git-backed issue tracking
2. **Health workflows** that automatically create/close Beads issues
3. **Quality gates** (type-check, build) between fixing phases
4. **Rollback capability** via changes logging

---

## Prerequisites

- Node.js/TypeScript project with `package.json`
- Scripts `type-check` and `build` in package.json (or adapt for your stack)
- Git repository (Beads stores issues in git)

---

## Step 1: Install Beads CLI

```bash
# Install globally
npm install -g @anthropic/beads-cli

# Or via npx (no install)
npx @anthropic/beads-cli --help
```

**Alternative**: Install from source:
```bash
git clone https://github.com/steveyegge/beads.git
cd beads
npm install && npm link
```

---

## Step 2: Initialize Beads in Your Project

Run in your project root:

```bash
bd init
```

This creates:
- `.beads/` directory (tracked in git) — stores issues as JSON files
- `.beads/config.json` — configuration
- `.beads/labels.json` — label definitions

**Verify**:
```bash
bd list  # Should show empty list
```

---

## Step 3: Configure package.json Scripts

Ensure you have these scripts (adapt for your stack):

```json
{
  "scripts": {
    "type-check": "tsc --noEmit",
    "build": "next build"
  }
}
```

**For other stacks**:
- **Vite**: `"build": "vite build"`
- **Node.js**: `"type-check": "tsc --noEmit", "build": "tsc"`
- **Python**: `"type-check": "mypy .", "build": "echo 'No build required'"`

---

## Step 4: Create Temporary Directories

The health workflows use `.tmp/current/` for:
- **plans/** — execution plans (JSON)
- **changes/** — change logs for rollback
- **backups/** — file backups before edits

Add to `.gitignore`:
```
.tmp/
```

Directories are created automatically by workflows, but you can pre-create:
```bash
mkdir -p .tmp/current/{plans,changes,backups}
```

---

## Step 5: Copy Health Skills

If using claude-code-orchestrator-kit, skills are already included. Otherwise, copy these skills to `.claude/skills/`:

1. `health-bugs/SKILL.md` — Bug detection with history enrichment
2. `cleanup-health-inline/SKILL.md` — Dead code removal
3. `deps-health-inline/SKILL.md` — Dependency audit
4. `security-health-inline/SKILL.md` — Security scanning
5. `reuse-health-inline/SKILL.md` — Code duplication consolidation

---

## Step 6: Verify Setup

Run any health command:

```bash
# In Claude Code
/health-bugs
```

**Expected behavior**:
1. Creates Beads wisp: `bd mol wisp healthcheck`
2. Runs bug detection via `bug-hunter` agent
3. Creates Beads issues for each bug found
4. Fixes bugs by priority (critical → low)
5. Closes issues after fixing
6. Runs verification scan
7. Completes wisp: `bd mol squash/burn`

---

## Workflow Structure

All health workflows follow this pattern:

```
Phase 1: Pre-flight & Beads Init
  ├─ Create .tmp/current/ directories
  ├─ Validate environment (package.json, scripts)
  └─ Create Beads wisp: bd mol wisp healthcheck

Phase 2: Detection
  ├─ Invoke worker agent (bug-hunter, security-scanner, etc.)
  └─ Generate report: {domain}-report.md

Phase 2.5: History Enrichment (health-bugs only, CRITICAL/HIGH)
  ├─ Search closed Beads issues for similar bugs
  └─ Enrich bug data with historical context

Phase 3: Create Beads Issues
  ├─ For each finding: bd create "TITLE" -t bug -p N
  └─ Track issue IDs for later closure

Phase 4: Quality Gate (Pre-fix)
  ├─ pnpm type-check
  └─ pnpm build (fail = exit)

Phase 5: Fix Loop (by priority)
  For critical → high → medium → low:
    ├─ Claim issue: bd update ID --status in_progress
    ├─ Invoke fixer agent
    ├─ Quality gate (type-check + build)
    └─ Close issue: bd close ID --reason "Fixed"

Phase 6: Verification
  ├─ Re-run detection
  └─ Compare: fixed vs remaining vs new

Phase 7: Complete
  ├─ Squash wisp: bd mol squash (or burn if nothing found)
  ├─ Create issues for remaining items
  └─ Generate summary report
```

---

## Beads Quick Reference

```bash
# View all issues
bd list

# View specific issue
bd show mc2-xxx

# Search issues
bd search "keyword"
bd search "security" --status closed

# Create issue
bd create "Title" -t bug -p 1 -d "Description"

# Update status
bd update mc2-xxx --status in_progress

# Close issue
bd close mc2-xxx --reason "Fixed: description"

# Wisps (exploration sessions)
bd mol wisp healthcheck     # Create
bd mol squash mc2-xxx       # Complete with results
bd mol burn mc2-xxx         # Abandon (nothing found)

# Sync with git
bd sync
```

---

## Customization

### Change Priority Levels

Edit skill files to adjust priorities:
- `critical` = P0/P1 (must fix immediately)
- `high` = P1/P2 (important)
- `medium` = P2/P3 (should fix)
- `low` = P3/P4 (nice to have)

### Add Auto-Mute Rules

For expected errors (e.g., network timeouts), add patterns to your logger's auto-classification.

### Customize Quality Gates

Edit skill files to use different commands:
```bash
# Instead of pnpm
npm run type-check
npm run build

# For Python
mypy .
pytest
```

---

## Troubleshooting

### "bd: command not found"

Install Beads CLI:
```bash
npm install -g @anthropic/beads-cli
```

### "No scripts found"

Add required scripts to package.json:
```json
{
  "scripts": {
    "type-check": "tsc --noEmit",
    "build": "your-build-command"
  }
}
```

### "Permission denied on .beads/"

```bash
chmod -R 755 .beads/
```

### Workflow exits early

Check quality gate output:
```bash
pnpm type-check
pnpm build
```

Fix any errors before re-running health workflow.

---

## Files Created by Workflows

| Workflow | Reports |
|----------|---------|
| `/health-bugs` | `bug-hunting-report.md`, `bug-fixes-implemented.md` |
| `/health-security` | `security-scan-report.md`, `security-fixes-implemented.md` |
| `/health-deps` | `dependency-scan-report.md`, `dependency-updates-implemented.md` |
| `/health-cleanup` | `dead-code-report.md`, `dead-code-cleanup-summary.md` |
| `/health-reuse` | `reuse-hunting-report.md`, `reuse-consolidation-implemented.md` |

All reports are created in project root (or `.tmp/current/plans/` depending on configuration).

---

## Session End Protocol

**Important**: After running health workflows, always sync Beads and push:

```bash
bd sync
git add .
git commit -m "fix: health check complete"
git push
```

This ensures:
- Beads issues are persisted in git
- Changes are tracked for rollback
- Other team members see the updates
