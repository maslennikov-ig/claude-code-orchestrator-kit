# Beads Commands Quick Reference

## View Issues

```bash
bd ready                    # Available work (no blockers)
bd list                     # All open issues
bd list --all               # Include closed
bd list -t bug              # Filter by type
bd list -p 1                # Filter by priority
bd list --status in_progress # Filter by status
bd list --unlocked          # Multi-terminal safe
bd blocked                  # Show blocked issues

bd show ID                  # Issue details
bd show ID --tree           # With hierarchy
```

## Create Issues

```bash
bd create "Title" -t type -p priority
bd create "Title" -t type -p priority -d "Description"
bd create "Title" --files path/to/file.tsx    # Auto-labels

# With dependencies
bd create "Title" --deps blocks:OTHER_ID
bd create "Title" --deps blocked-by:OTHER_ID
bd create "Title" --deps discovered-from:OTHER_ID
bd create "Title" --deps parent:EPIC_ID
```

## Update Issues

```bash
bd update ID --status in_progress
bd update ID --status blocked
bd update ID --status open
bd update ID --priority 1
bd update ID --add-label security
```

## Close Issues

```bash
bd close ID --reason "Description"
bd close ID1 ID2 ID3 --reason "Batch done"
bd close ID --reason "Won't fix" --wontfix
```

## Dependencies

```bash
bd dep add CHILD PARENT     # CHILD depends on PARENT
bd dep remove CHILD PARENT
```

## Labels

```bash
bd label add ID label-name
bd label remove ID label-name
```

## Sync & Diagnostics

```bash
bd sync                     # Sync DB ↔ JSONL ↔ Git
bd sync --force             # Force from JSONL
bd info                     # Project status
bd doctor                   # Health check
bd prime                    # Context injection
bd prime --full             # Full context
```

## Daemon

```bash
bd daemon status
bd daemon start
bd daemon stop
bd daemon restart
```

## Formulas (Workflows)

```bash
bd formula list             # List templates

# Ephemeral (wisp)
bd mol wisp NAME --vars "key=value"

# Persistent
bd mol pour NAME --vars "key=value"

# Manage
bd mol progress WISP_ID
bd mol current
bd mol squash WISP_ID       # Save
bd mol burn WISP_ID         # Discard
```

## Patrols

```bash
bd patrol list
bd patrol run NAME --vars "key=value"
```
