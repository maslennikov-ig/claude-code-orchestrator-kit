<!--
Sync Impact Report
==================
Version Change: INITIAL → 1.0.0
Modified Principles: N/A (Initial version)
Added Sections: All core sections (initial creation)
Removed Sections: None

Templates Requiring Updates:
✅ plan-template.md - Constitution Check section already references constitution file
✅ spec-template.md - Already aligned with user-centric requirements approach
✅ tasks-template.md - Already organized by user stories and testability principles
✅ CLAUDE.md - Root orchestration rules reference constitution principles

Follow-up TODOs: None - all placeholders resolved
-->

# Symancy Project Constitution

## Core Principles

### I. Context-First Development

Every feature implementation MUST begin with comprehensive context gathering before any code is written or delegated. This principle is NON-NEGOTIABLE.

**Requirements:**
- Read existing code in related files
- Search codebase for similar patterns and implementations
- Review relevant documentation files (specs, design docs, ADRs)
- Check recent commits that touched related areas
- Understand dependencies and integration points

**Rationale:** Context-first prevents duplicate work, ensures consistency with existing patterns, and prevents conflicting approaches. Blind implementation or delegation leads to rework and technical debt.

### II. Agent-Based Orchestration

Complex tasks MUST be delegated to specialized subagents. The orchestrator coordinates but does not implement beyond minimal changes.

**Requirements:**
- Provide complete context to subagents (code snippets, file paths, patterns, documentation references)
- Specify exact expected output and validation criteria
- Verify results after subagent completes (read modified files, run type-check)
- Re-delegate with corrections if results incorrect
- Only execute directly for trivial tasks (single-line fixes, simple imports, minimal configuration)

**Rationale:** Specialized agents produce higher quality results in their domain. Orchestrator maintains oversight while leveraging specialized expertise.

### III. Test-Driven Development (Conditional)

When tests are specified in feature requirements, Test-Driven Development (TDD) is MANDATORY. Tests MUST be written first, verified to fail, then implementation proceeds.

**Requirements:**
- Write tests BEFORE implementation
- Verify tests FAIL before implementing
- Follow Red-Green-Refactor cycle
- Tests MUST be independently verifiable for each user story

**Rationale:** TDD ensures requirements are testable, prevents over-engineering, and provides immediate validation of implementation correctness.

**Note:** Tests are OPTIONAL by default. Only when explicitly requested in feature specifications does this principle activate.

### IV. Atomic Task Execution

Each task MUST be independently completable, testable, and committable. Tasks are completed one at a time with immediate validation.

**Requirements:**
- Mark task in_progress BEFORE starting
- Verify implementation (read files + run type-check)
- Mark task completed IMMEDIATELY after validation
- Update tasks.md with [X] and artifacts
- Commit with `/push patch` after EACH task
- Move to next task only after current task validated

**Rationale:** Atomic commits provide detailed history, easy rollback, better code review, and clear progress tracking. Batching hides granularity and complicates debugging.

### V. User Story Independence

Features MUST be decomposed into independently testable user stories. Each user story delivers standalone value and can be deployed independently.

**Requirements:**
- Prioritize user stories (P1, P2, P3...)
- Each story MUST be independently implementable
- Each story MUST be independently testable
- Each story MUST deliver measurable value
- Foundation phase MUST complete before any user story work begins

**Rationale:** Independent user stories enable incremental delivery, parallel development, and risk reduction. MVP can be delivered with just P1 story.

### VI. Quality Gates (NON-NEGOTIABLE)

Type-check and build MUST pass before any commit. No exceptions.

**Requirements:**
- Run type-check after implementation
- Run build verification
- No hardcoded credentials
- No TODO comments without issue references

**Rationale:** Quality gates prevent broken code from entering main branch, reduce debugging time, and maintain codebase health.

### VII. Progressive Specification

Features progress through mandatory specification phases before implementation. Each phase builds upon previous validated artifacts.

**Requirements:**
- Phase 0: Specification (spec.md with user stories)
- Phase 1: Planning (plan.md with technical approach)
- Phase 2: Task Generation (tasks.md organized by user stories)
- Phase 3: Implementation (execute tasks atomically)
- No phase can be skipped
- Each phase output MUST be validated before proceeding

**Rationale:** Progressive specification reduces rework, ensures shared understanding, and validates approach before expensive implementation.

## Security Requirements

### Data Protection

All user data MUST comply with 152-ФЗ (Russian data protection law) and GDPR where applicable.

**Requirements:**
- No hardcoded credentials in code
- Use environment variables for secrets
- Supabase RLS policies for data access
- Audit logs for sensitive operations

### Authentication & Authorization

All API endpoints MUST enforce authentication via Supabase Auth.

**Requirements:**
- Use Supabase MCP for auth operations when available
- Implement RLS policies for data isolation
- Session management via Supabase
- No custom auth implementations without justification

## Technology Standards

### Core Stack

**Frontend:**
- React 19+ with TypeScript
- Vite for build tooling
- Tailwind CSS for styling
- Supabase client for auth and data

**Backend:**
- Supabase PostgreSQL for primary database
- Netlify Functions for serverless logic
- n8n for workflow automation
- Redis for caching (when needed)

**AI/ML:**
- Google Gemini API (primary)
- OpenRouter for alternative models
- pgvector for semantic search

### File Organization

**Agents:** `.claude/agents/{domain}/{orchestrators|workers}/`
**Commands:** `.claude/commands/`
**Skills:** `.claude/skills/{skill-name}/SKILL.md`
**Specifications:** `.specify/specs/{###-feature-name}/`
**Templates:** `.specify/templates/`
**Temporary Files:** `.tmp/current/` (git ignored)
**Reports:** `docs/reports/{domain}/{YYYY-MM}/`

### MCP Configuration

**BASE Configuration** (`.mcp.base.json`): context7 + sequential-thinking (~600 tokens)
**FULL Configuration** (`.mcp.full.json`): + supabase + playwright + n8n + shadcn (~5000 tokens)

Switch configurations with `./switch-mcp.sh` based on task needs.

## Governance

### Constitution Authority

This constitution supersedes all other development practices. When conflicts arise between this constitution and other guidance, the constitution takes precedence.

### Amendment Procedure

Constitution amendments require:
1. Documented rationale for change
2. Impact analysis on existing templates and workflows
3. Version bump according to semantic versioning:
   - **MAJOR**: Backward incompatible governance or principle removals/redefinitions
   - **MINOR**: New principle or section added, or materially expanded guidance
   - **PATCH**: Clarifications, wording, typo fixes, non-semantic refinements
4. Sync Impact Report identifying affected templates
5. Update of all dependent templates and documentation

### Compliance Review

All feature specifications, plans, and implementations MUST verify compliance with this constitution. The "Constitution Check" section in plan-template.md enforces this requirement.

### Complexity Justification

Any violation of constitutional principles MUST be justified in the "Complexity Tracking" section of plan.md. Justifications must explain:
- Why the principle violation is necessary
- Why simpler alternatives were rejected
- Mitigation strategies for introduced complexity

### Runtime Guidance

Development runtime guidance is maintained in `CLAUDE.md` at repository root. This file provides operational procedures that implement constitutional principles but may be updated more frequently than the constitution itself.

**Version**: 1.0.0 | **Ratified**: 2025-11-10 | **Last Amended**: 2025-11-10
