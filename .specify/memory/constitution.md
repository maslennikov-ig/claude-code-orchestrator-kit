<!--
Sync Impact Report
==================
Version Change: 1.0.0 → 2.0.0
Modified Principles: Restructured all principles for clarity and brevity
Added Sections: Single Source of Truth, Library-First, Code Reuse, Accessibility, Error Handling, Observability
Removed Sections: Detailed tech stack (now parameterized)

Templates Requiring Updates:
- plan-template.md - Review Constitution Check section
- spec-template.md - Aligned with new principles
- tasks-template.md - No changes needed
- CLAUDE.md - Operational procedures, not affected

Follow-up TODOs: Replace {{PLACEHOLDER}} values for each project
-->

# {{PROJECT_NAME}} Constitution

> **Authority**: This constitution supersedes all other development practices. Runtime guidance in `CLAUDE.md` implements these principles operationally.

## Core Principles

### I. Context-First Development (NON-NEGOTIABLE)

Before any implementation or delegation, gather comprehensive context:
- Read existing code in related files
- Search for similar patterns and implementations
- Review specs, ADRs, and recent commits
- Understand dependencies and integration points

**Rationale**: Prevents duplicate work, ensures consistency, avoids conflicting approaches.

### II. Single Source of Truth

Types, constants, enums, schemas, and shared logic MUST be defined in designated central locations (e.g., `{{SHARED_TYPES_PATH}}`). Duplication is forbidden — consumers must import from the source.

**Rationale**: Eliminates drift between duplicate definitions, simplifies refactoring.

### III. Library-First Development

Before implementing custom solutions (>20 lines):
1. Search for existing libraries (npm, PyPI, etc.)
2. Evaluate: maintenance status, security, bundle size, TypeScript support
3. Use library if it covers >70% of requirements

**Context7 Rule**: Before writing code that uses ANY library, MUST fetch up-to-date documentation via `mcp__context7__get-library-docs`. This ensures correct API usage and avoids deprecated patterns.

**Rationale**: Reduces maintenance burden, leverages community standards and security fixes.

### IV. Code Reuse & DRY

Before creating new components, utilities, or logic:
1. Search existing codebase for reusable implementations
2. Prefer adapting and extending over duplicating
3. Document why reuse was not possible if creating new

**Rationale**: Reduces codebase size, ensures consistent behavior, lowers cognitive load.

### V. Strict Type Safety (NON-NEGOTIABLE)

- TypeScript `strict` mode enforced
- `any` is prohibited — use `unknown` or proper types
- Explicit return types for exported functions
- Type-check must pass before commit

**Rationale**: Catches errors at compile time, enables safe refactoring, improves IDE support.

### VI. Atomic Task Execution

Each task must be independently completable, testable, and committable:
- Mark task `in_progress` before starting
- Verify implementation (read files + run checks)
- Mark `completed` after validation only
- Commit after EACH task, not in batches

**Atomic Delegation Rule**: One agent invocation = one task. Never batch multiple tasks into a single agent call.
- Parallel work: Launch N agents in single message, each with exactly one task
- Sequential work: Complete one agent call, then start next
- Same agent type can run multiple times in parallel — each instance handles one task

**Rationale**: Enables easy rollback, clear progress tracking, better code review. Atomic delegation ensures predictable agent behavior and simplifies error handling.

### VII. Quality Gates (NON-NEGOTIABLE)

Before any commit:
- [ ] Type-check passes
- [ ] Build succeeds
- [ ] No hardcoded credentials
- [ ] No `TODO` without issue reference

**Rationale**: Prevents broken code in main branch, maintains codebase health.

### VIII. Progressive Specification

Features progress through mandatory phases:
1. **Spec** → User stories and requirements
2. **Plan** → Technical approach and decisions
3. **Tasks** → Atomic, ordered implementation steps
4. **Implement** → Execute with validation

No phase can be skipped. Each output validated before proceeding.

**Rationale**: Reduces rework, validates approach before expensive implementation.

## Operational Excellence

### IX. Error Handling

- All errors must be typed (custom Error classes or union types)
- User-facing errors: localized, actionable, no stack traces
- Internal errors: structured logging with context
- Never swallow errors silently

### X. Observability

- Structured logging (JSON) in production
- Correlation IDs for distributed operations
- Performance metrics for critical paths
- Audit logs for sensitive operations

### XI. Accessibility ({{A11Y_LEVEL}})

<!-- Set {{A11Y_LEVEL}} to: MANDATORY, RECOMMENDED, or N/A -->
- WCAG 2.1 AA compliance minimum
- Keyboard navigation support
- Screen reader compatibility
- Color contrast requirements met
- Visual changes verified in Light and Dark themes

## Security Requirements

### Data Protection

- No hardcoded credentials — use environment variables
- {{AUTH_PROVIDER}} for authentication
- Row-Level Security (RLS) for data isolation
- Input validation via Zod or equivalent
- Audit logs for sensitive operations

### Compliance

<!-- Specify applicable regulations -->
- {{COMPLIANCE_REQUIREMENTS}}

## Technology Standards

### Core Stack

<!-- Replace placeholders with project-specific values -->
| Layer | Technology |
|-------|------------|
| Language | {{LANGUAGE}} |
| Framework | {{FRAMEWORK}} |
| Database | {{DATABASE}} |
| Auth | {{AUTH_PROVIDER}} |
| Hosting | {{HOSTING}} |

### File Organization

```
.claude/agents/       # Agent definitions
.claude/commands/     # Slash commands
.claude/skills/       # Reusable skills
.specify/specs/       # Feature specifications
.specify/templates/   # Spec templates
.specify/memory/      # Constitution, context
.tmp/current/         # Temporary files (git ignored)
docs/reports/         # Generated reports
```

## Governance

### Amendment Procedure

Constitution changes require:
1. Documented rationale
2. Impact analysis on templates/workflows
3. Version bump (MAJOR: breaking, MINOR: additive, PATCH: clarification)
4. Sync Impact Report in header
5. Update dependent documentation

### Exception Process

Principle violations require justification in plan.md:
- Why violation is necessary
- Alternatives considered and rejected
- Mitigation strategies

### Document Hierarchy

1. **Constitution** (this file) — Principles and laws
2. **CLAUDE.md** — Operational procedures implementing principles
3. **Spec/Plan/Tasks** — Feature-specific guidance

---

**Version**: 2.0.0 | **Ratified**: {{RATIFIED_DATE}} | **Last Amended**: {{AMENDED_DATE}}
