---
description: Manage git worktrees for parallel feature development (create, remove, list, cleanup)
---

# Git Worktree Manager

Manage git worktrees for parallel feature development.

## Usage

```bash
/worktree create <feature-name> [base-branch]
/worktree remove <feature-name> [--force] [--delete-branch]
/worktree list
/worktree cleanup [--dry-run] [--remove-dirs]
```

---

## Commands

### create

Create new worktree for parallel development.

**What it does:**
- Creates `megacampus2-worktrees/` directory (if not exists)
- Creates new branch `feature/<name>` from base
- Creates worktree in separate directory
- Copies gitignored files per `.worktree-sync.json`

**Process:**
1. Validate feature name (alphanumeric, hyphens only)
2. Check for uncommitted changes (warn if present)
3. Create worktree: `git worktree add ../megacampus2-worktrees/<name> -b feature/<name> <base>`
4. Sync files from `.worktree-sync.json`:
   - `sync.files`: `.env`, `.env.local`, `.mcp.json`, etc.
   - `sync.directories`: `.vscode`
   - `sync.patterns`: `packages/*/.env`, `services/*/.env`
5. Output next steps (open in IDE, commit workflow)

**Errors:**
- Worktree exists: suggest different name or remove existing
- Branch exists: checkout existing or use different name

---

### remove

Remove worktree and optionally delete branch.

**What it does:**
- Checks for uncommitted changes
- Removes worktree directory
- Optionally deletes local and remote branch
- Runs `git worktree prune`

**Process:**
1. Find worktree by name
2. Check git status (if uncommitted changes, require --force or user choice)
3. Remove: `git worktree remove [--force] <path>`
4. If --delete-branch:
   - Check if merged: `git branch --merged main | grep feature/<name>`
   - Delete local: `git branch -d/-D feature/<name>`
   - Delete remote: `git push origin --delete feature/<name>`
5. Cleanup: `git worktree prune`

**Errors:**
- Not found: show available worktrees
- Main worktree: cannot remove
- Uncommitted changes: offer commit/force/cancel
- Unmerged branch: warn, offer PR/force/keep-branch

---

### list

Show all worktrees with status.

**Output:**
```
# Git Worktrees (N total)

| Name | Branch | Path | Status |
|------|--------|------|--------|
| main (основной) | main | /home/me/code/megacampus2 | Active |
| feature-name | feature/feature-name | .../megacampus2-worktrees/feature-name | Active |

Commands: /worktree create <name> | /worktree remove <name>
```

**Process:**
1. Run `git worktree list --porcelain`
2. For each worktree: extract path, branch, HEAD, status (locked/prunable)
3. Format table with status indicators

---

### cleanup

Clean up stale worktree files and orphaned directories.

**What it does:**
- Prunes administrative files for deleted worktrees
- Repairs recoverable worktrees
- Removes orphaned directories (with --remove-dirs)

**Process:**
1. Dry-run check: `git worktree prune --dry-run --verbose`
2. Find orphaned dirs in `megacampus2-worktrees/` not in `git worktree list`
3. Try repair: `git worktree repair <path>`
4. If not --dry-run: `git worktree prune --verbose`
5. If --remove-dirs: remove orphaned/empty directories

**Output:**
```
# Worktree Cleanup Report

✅ Pruned administrative records: N
✅ Removed directories: N (--remove-dirs)
✅ Recovered worktrees: N

Active worktrees: N
All valid: ✅
```

---

## File Sync Config

`.worktree-sync.json` format:
```json
{
  "sync": {
    "files": [".env", ".env.local", ".mcp.json"],
    "directories": [".vscode"],
    "patterns": ["packages/*/.env", "services/*/.env"]
  }
}
```

---

## Notes

- Worktrees share `.git` → saves disk space
- Each worktree must be on unique branch
- Cannot checkout same branch in multiple worktrees
- Main worktree cannot be removed
- Use --dry-run with cleanup to preview changes
