---
description: Initialize Beads issue tracking in your project with interactive configuration setup.
---

# Beads Initialization

> **Attribution**: [Beads](https://github.com/steveyegge/beads) is created by [Steve Yegge](https://github.com/steveyegge).

## User Input

```text
$ARGUMENTS
```

## Prerequisites Check

First, verify Beads CLI is installed:

```bash
bd version
```

If not installed, provide installation options:

**Option 1: Go (recommended)**
```bash
go install github.com/steveyegge/beads/cmd/bd@latest
```

**Option 2: npm**
```bash
npm install -g @beads/bd
```

**Option 3: Homebrew (macOS)**
```bash
brew install steveyegge/tap/beads
```

## Configuration Selection

Ask user to choose configuration:

1. **base** - Minimal setup, good for getting started
2. **full** - All features enabled (recommended for production)
3. **stealth** - Local-only mode, no auto-push to remote

## Project Prefix

Ask user for their issue prefix (3-8 characters, lowercase):
- Should be short project name
- All issues will be `PREFIX-xxx`
- Examples: `myapp`, `web`, `api`, `proj`

## Initialization Steps

1. **Initialize Beads**:
```bash
bd init
```

2. **Copy configuration** (based on user choice):
```bash
cp .beads-templates/config/{chosen}.yaml .beads/config.yaml
```

3. **Update issue-prefix** in config.yaml with user's chosen prefix

4. **Copy formulas**:
```bash
mkdir -p .beads/formulas
cp .beads-templates/formulas/*.toml .beads/formulas/
```

5. **Copy PRIME template**:
```bash
cp .beads-templates/PRIME.template.md .beads/PRIME.md
```

6. **Update PRIME.md** - replace `{{PREFIX}}` and `{{PROJECT_NAME}}`

7. **Initial sync**:
```bash
bd sync
```

## Post-Setup Instructions

After initialization, display:

```
## Beads Initialized!

**Prefix**: {PREFIX}
**Config**: {CONFIG_TYPE}

### Quick Start

1. Create your first task:
   bd create "Setup project" -t chore -p 3

2. View available work:
   bd ready

3. Start working:
   bd update {PREFIX}-xxx --status in_progress

4. Complete task:
   bd close {PREFIX}-xxx --reason "Done"

### Session Workflow

START:  bd prime → bd ready
WORK:   bd update → work → bd close → /push patch
END:    bd sync → git push

### Documentation

- Quick reference: .claude/docs/beads-quickstart.md
- Templates: .beads-templates/README.md
- Official docs: https://github.com/steveyegge/beads

### Next Steps

- [ ] Review .beads/config.yaml and customize directory-labels
- [ ] Create REF: issues for project knowledge (optional)
- [ ] Run /speckit.tobeads after generating tasks.md
```

## Troubleshooting

If bd init fails:
- Check if .beads/ already exists
- Try: `rm -rf .beads && bd init`

If daemon doesn't start:
- Check logs: `cat .beads/daemon.log`
- Restart: `bd daemon restart`

## Example Session

```
User: /beads-init