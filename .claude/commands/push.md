---
description: Automated release management with version bumping and dual changelog generation
argument-hint: [patch|minor|major]
---

Execute the release automation script with auto-confirmation for Claude Code.

**Features:**
- Auto-syncs package.json versions with latest git tag (prevents version conflicts)
- Analyzes commits since last release
- Auto-detects version bump type from conventional commits
- **Generates dual changelogs:**
  - `CHANGELOG.md` - Technical format (Keep a Changelog) for developers
  - `RELEASE_NOTES.md` - User-facing format with friendly language for marketing
- Updates all package.json files
- Creates git tag and pushes to GitHub
- Full rollback support on errors

**Generated RELEASE_NOTES.md format:**
- Friendly scope names (auth → Authentication, db → Database)
- Emojis for visual clarity (✨ Features, 🐛 Fixes, 🔒 Security)
- Skips technical commits (chore, ci, docs) not relevant to users
- Ready to copy for announcements, app stores, emails

**Usage:**

# Navigate to project root first
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
cd "$PROJECT_ROOT" && bash .claude/scripts/release.sh $ARGUMENTS --yes
