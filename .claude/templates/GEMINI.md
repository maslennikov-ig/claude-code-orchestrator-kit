# Project Guidelines

## Orchestration

Uses **Gastown** (`gt`) + **Beads** (`bd`). Global tools at `~/gt/`.

Multi-runtime: `claude` (default), `codex`, `gemini` — all subscription-based.

## Workflow

```bash
bd ready                              # Find work
bd update <id> --status in_progress   # Claim
# ... work ...
bd close <id> --reason "Done"         # Close
git commit -m "..." && git push       # Ship
```

## Rules

- Quality gates (type-check, build, tests) before commit
- Never hardcode credentials
- Follow conventional commits: `type(scope): summary`

## Session End

```bash
git status && git add <files> && git commit -m "..." && git push
```

<!-- PROJECT-SPECIFIC: Add your stack and deployment details below -->
