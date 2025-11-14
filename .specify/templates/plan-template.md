# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature spec from `/specs/[###-feature-name]/spec.md`

**Note**: Template filled by `/speckit.plan` command.

## Summary

[Primary requirement + technical approach from research]

## Technical Context

<!-- Replace with actual technical details for project -->

**Language/Version**: [e.g., Python 3.11 or NEEDS CLARIFICATION]
**Primary Dependencies**: [e.g., FastAPI or NEEDS CLARIFICATION]
**Storage**: [PostgreSQL, files or N/A]
**Testing**: [pytest, cargo test or NEEDS CLARIFICATION]
**Target Platform**: [Linux server, iOS 15+ or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines structure]
**Performance Goals**: [1000 req/s, 60 fps or NEEDS CLARIFICATION]
**Constraints**: [<200ms p95, offline-capable or NEEDS CLARIFICATION]
**Scale/Scope**: [10k users, 1M LOC or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0. Re-check after Phase 1.*

[Gates from constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md          # This file
├── research.md      # Phase 0 output
├── research/        # Complex research (if needed)
├── data-model.md    # Phase 1 output
├── quickstart.md    # Phase 1 output
├── contracts/       # Phase 1 output
└── tasks.md         # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

<!-- Replace with concrete layout. Delete unused options. Expand with real paths. -->

```text
# Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Web application (frontend + backend)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Mobile + API (iOS/Android)
api/
└── [same as backend]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: [Document selected structure]

## Complexity Tracking

> Fill ONLY if Constitution Check has violations requiring justification

| Violation | Why Needed | Simpler Alternative Rejected |
|-----------|------------|------------------------------|
| [e.g., 4th project] | [need] | [why 3 insufficient] |
