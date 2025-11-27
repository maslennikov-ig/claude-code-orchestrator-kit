# Session Log

> Decisions, issues, and learnings from this session.
> Newest entries at the top.

---

## YYYY-MM-DDTHH:MM:SS

### [Category]: [Brief Title]

**Context:** [What were you trying to do]

**Issue/Decision:** [What happened or what decision was made]

**Resolution:** [How it was resolved or why this decision was made]

**Learning:** [Optional - what to remember for future]

---

## Entry Categories

Use these categories for consistency:

- **Decision** — Architectural or implementation choice made
- **Issue** — Problem encountered and how it was solved
- **Discovery** — Something learned about the codebase
- **Blocker** — Something that stopped progress (and resolution)
- **Rollback** — Change that was reverted and why

---

## Example Entries

### 2025-11-27T14:30:00

### Decision: Auth validation approach

**Context:** Multiple auth checks scattered across codebase

**Issue/Decision:** Chose middleware-based approach over per-route validation

**Resolution:** Created `authMiddleware.ts` in `src/middleware/`

**Learning:** Check existing patterns in `middleware/` before adding new auth logic

---

### 2025-11-27T15:00:00

### Issue: TypeScript error after fix

**Context:** Fixed auth validation, but broke type inference

**Issue/Decision:** Type 'string | undefined' not assignable to 'string'

**Resolution:** Added nullish coalescing `?? ''` fallback

---

### 2025-11-27T15:30:00

### Blocker: Missing dependency

**Context:** Tried to use zod validation

**Issue/Decision:** zod not installed in this package

**Resolution:** Added to package.json, ran pnpm install

**Learning:** Check package.json before using external libraries
