# Beads Templates

> **Attribution**: [Beads](https://github.com/steveyegge/beads) is a distributed, git-backed graph issue tracker for AI agents, created by [Steve Yegge](https://github.com/steveyegge).

This directory contains templates for integrating Beads into your project.

## What is Beads?

Beads is an AI-native issue tracking system designed specifically for AI coding agents like Claude. Key features:

- **Git-backed**: All issues stored in `.beads/issues.jsonl`, tracked in git
- **Hash-based IDs**: Collision-resistant IDs (e.g., `myproject-a3f8`)
- **Dependency Graph**: Track blocking relationships between tasks
- **Multi-session Safe**: Exclusive locks prevent conflicts
- **Context Injection**: `bd prime` restores workflow context

## Quick Start

```bash
# Run the initialization command
/beads-init

# Or manually:
# 1. Install Beads CLI
go install github.com/steveyegge/beads/cmd/bd@latest
# or: npm install -g @beads/bd

# 2. Initialize in your project
bd init

# 3. Copy config template
cp .beads-templates/config/full.yaml .beads/config.yaml

# 4. Copy formulas
cp -r .beads-templates/formulas/* .beads/formulas/

# 5. Customize config.yaml (change issue-prefix!)
```

## Directory Structure

```
.beads-templates/
├── config/
│   ├── base.yaml      # Minimal config
│   ├── full.yaml      # Full features (recommended)
│   └── stealth.yaml   # Local-only mode
├── formulas/          # Workflow templates
│   ├── bigfeature.formula.toml
│   ├── bugfix.formula.toml
│   ├── codereview.formula.toml
│   ├── exploration.formula.toml
│   ├── healthcheck.formula.toml
│   ├── hotfix.formula.toml
│   ├── release.formula.toml
│   └── techdebt.formula.toml
├── PRIME.template.md  # Context injection template
└── README.md          # This file
```

## Configuration Options

| Config | Description | Use Case |
|--------|-------------|----------|
| `base.yaml` | Minimal setup | Getting started |
| `full.yaml` | All features | Production projects |
| `stealth.yaml` | No auto-push | Shared repos, local tracking |

## Available Formulas

| Formula | Description |
|---------|-------------|
| `bigfeature` | Large features (>1 day) with Spec-kit integration |
| `bugfix` | Standard bug fix workflow |
| `codereview` | Code review with issue tracking |
| `exploration` | Research spikes and prototyping |
| `healthcheck` | Codebase health audit |
| `hotfix` | Emergency production fixes |
| `release` | Version release process |
| `techdebt` | Technical debt remediation |

## Core Workflow

```bash
# Start session
bd prime                    # Inject context
bd ready                    # Find available work

# Work on task
bd update ID --status in_progress
# ... do work ...
bd close ID --reason "Done"
/push patch

# End session (MANDATORY!)
bd sync
git push
```

## Links

- [Beads GitHub Repository](https://github.com/steveyegge/beads)
- [Beads CLI Reference](https://github.com/steveyegge/beads/blob/main/docs/CLI_REFERENCE.md)
- [Molecules Guide](https://github.com/steveyegge/beads/blob/main/docs/MOLECULES.md)

---

*Beads methodology by Steve Yegge. Templates adapted for Claude Code Orchestrator Kit.*
