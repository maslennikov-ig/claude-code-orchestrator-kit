# Project Index

> Quick navigation for AI agents. Updated: YYYY-MM-DD
>
> **Purpose:** This file helps agents understand project structure without reading entire codebase.
> **Usage:** Read by `load-project-context` skill when exploring unfamiliar areas.

## Architecture

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** — System design, diagrams, data flow
- **[CLAUDE.md](CLAUDE.md)** — Behavioral rules, orchestration patterns

## Core Domains

### [Domain 1 Name]
- **[path/to/domain/](path/to/domain/)** — Brief description of what this domain does
  - Key: `src/` — Main source code
  - Key: `types/` — TypeScript types and interfaces
  - Pattern: [Describe the main pattern used, e.g., "Repository pattern", "MVC"]

### [Domain 2 Name]
- **[path/to/domain/](path/to/domain/)** — Brief description
  - Key: `components/` — UI components
  - Key: `hooks/` — Custom React hooks

## Shared Code

- **[packages/shared/](packages/shared/)** — Shared utilities, types, constants
  - Key: `utils/` — Helper functions
  - Key: `types/` — Shared TypeScript types

## Configuration

- **[.env.example](.env.example)** — Environment variables template
- **[tsconfig.json](tsconfig.json)** — TypeScript configuration
- **[package.json](package.json)** — Dependencies and scripts

## Patterns & Conventions

- **Auth:** [How authentication is implemented]
- **State:** [State management approach]
- **Styling:** [CSS/styling approach]
- **Testing:** [Testing framework and patterns]
- **Error Handling:** [How errors are handled]

## Key Entry Points

| Purpose | File | Description |
|---------|------|-------------|
| App entry | `src/index.ts` | Main application entry point |
| API routes | `src/routes/` | All API endpoints |
| Database | `src/db/` | Database connection and queries |

## Recent Changes (last 7 days)

- YYYY-MM-DD: [Brief description of change]
- YYYY-MM-DD: [Brief description of change]

---

## Usage Notes

1. Keep this file under 150 lines
2. Update "Recent Changes" weekly
3. Only include KEY directories and files
4. Annotations should be 1 line max
5. Link to detailed docs, don't duplicate content
