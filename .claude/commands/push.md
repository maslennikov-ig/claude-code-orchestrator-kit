---
description: Automated release management with version bumping and changelog updates
argument-hint: [patch|minor|major]
---

Execute the release automation script with auto-confirmation for Claude Code.

**Features:**
- Auto-syncs package.json versions with latest git tag (prevents version conflicts)
- Analyzes commits since last release
- Auto-detects version bump type from conventional commits
- Generates CHANGELOG entries
- Updates all package.json files
- Creates git tag and pushes to GitHub
- Full rollback support on errors

**Usage:**

# Navigate to project root first
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
cd "$PROJECT_ROOT" && bash .claude/scripts/release.sh $ARGUMENTS --yes
