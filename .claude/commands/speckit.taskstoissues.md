---
description: Convert existing tasks into actionable, dependency-ordered GitHub issues for the feature based on available design artifacts.
scripts:
  sh: .specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: .specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. From the executed script, extract the path to **tasks.md**.

3. **Verify GitHub remote**:

```bash
git config --get remote.origin.url
```

> [!CAUTION]
> ONLY PROCEED TO NEXT STEPS IF THE REMOTE IS A GITHUB URL (contains `github.com`)

4. **Check `gh` CLI availability**:

```bash
gh --version
```

If `gh` is not installed, inform the user:
```
GitHub CLI (gh) is not installed. Install it:
- macOS: brew install gh
- Ubuntu: sudo apt install gh
- Windows: winget install GitHub.cli

Then authenticate: gh auth login
```

5. **Verify authentication**:

```bash
gh auth status
```

If not authenticated, prompt user to run `gh auth login`.

6. **Parse tasks.md** and extract all incomplete tasks:
   - Tasks matching `- [ ] T### ...` pattern
   - Extract: Task ID, description, phase, parallel marker [P], user story [US#]

7. **For each task, create a GitHub issue** using `gh` CLI:

```bash
gh issue create \
  --title "T001: Create project structure" \
  --body "## Task Details

**ID**: T001
**Phase**: Setup
**Parallel**: No
**User Story**: N/A

### Description
Create project structure per implementation plan

### Acceptance Criteria
- [ ] Task completed as specified in tasks.md

---
*Generated from tasks.md by /speckit.taskstoissues*" \
  --label "speckit"
```

**Formatting rules**:
- Title: `T###: <short description>`
- Body: Task details, phase, parallel info, acceptance criteria
- Label: `speckit` (create if doesn't exist)
- Optional labels based on phase: `setup`, `foundational`, `user-story`, `polish`

8. **Create labels if needed** (first run only):

```bash
gh label create speckit --description "Generated from spec-kit tasks" --color "0052CC" 2>/dev/null || true
gh label create setup --description "Setup phase task" --color "C5DEF5" 2>/dev/null || true
gh label create user-story --description "User story implementation" --color "D4C5F9" 2>/dev/null || true
```

9. **Report results**:
   - Number of issues created
   - Links to created issues
   - Any errors encountered

> [!CAUTION]
> UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL

## Options

User can specify in `$ARGUMENTS`:
- `--dry-run` — показать какие issues будут созданы, но не создавать
- `--phase N` — создать issues только для Phase N
- `--limit N` — создать только первые N issues

## Examples

```bash
# Создать issues для всех задач
/speckit.taskstoissues

# Только показать что будет создано
/speckit.taskstoissues --dry-run

# Только Phase 1 (Setup)
/speckit.taskstoissues --phase 1

# Первые 5 задач
/speckit.taskstoissues --limit 5
```
