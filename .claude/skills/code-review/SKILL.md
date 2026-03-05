---
name: code-review
description: Analyzes code changes for bugs, security vulnerabilities, performance problems, and architectural improvements. Generates structured markdown reports with evidence-based findings tied to specific file:line references, and creates Beads tasks for tracking. Adapts review depth based on scope — from quick pre-commit checks to thorough branch reviews. Use proactively when reviewing code before commits, after implementing features, before PRs, when checking code quality, or when the user mentions "review", "check changes", "code review", "PR review", "review branch", or any code quality assessment.
---

# Code Review

Review code directly in the main context. Read the code, analyze git history, write the report, create Beads tasks.

The goal is **risk reduction, not perfect code**. "Heartbleed was 2 lines" — size doesn't determine risk. Focus on findings that matter: real bugs, security gaps, and meaningful improvements. If the code is clean, say so.

## Workflow

```
Scope → Git History → Read & Analyze → Quality Gates → Report → Beads Tasks → Summary
```

## Step 1: Determine Scope

| User says               | Scope             | Command                                                  |
| ----------------------- | ----------------- | -------------------------------------------------------- |
| "review my changes"     | Staged + unstaged | `git diff --name-only` + `git diff --cached --name-only` |
| "review before commit"  | Staged only       | `git diff --cached --name-only`                          |
| "review the branch"     | Branch vs base    | `git diff --name-only develop...HEAD`                    |
| "review PR #N"          | PR diff           | `gh pr diff N --name-only`                               |
| "review src/foo/"       | Specific path     | Read files in path                                       |
| "review recent changes" | Last N commits    | `git diff --name-only HEAD~N`                            |

If ambiguous, ask. Skip non-reviewable: `*.lock`, `*.min.js`, `*.map`, generated `database.types.ts`.

**Adapt depth to scale:**

- **1-5 files**: Exhaustive line-by-line analysis
- **6-20 files**: Focus on risky areas (auth, data handling, new patterns)
- **20+ files**: Surgical — prioritize security-critical paths, new APIs, schema changes

## Step 2: Analyze Git History

Do not skip this. Surface analysis misses regressions that history reveals.

```bash
# What changed and why
git log --oneline -10 -- <changed-files>

# Was validation/auth logic removed?
git log -p --all -S 'functionName' -- <file>
```

Look for:

- **Removed safety checks** — validation, auth, error handling deleted without replacement
- **Reverted patterns** — code going back to a previously fixed approach
- **Blast radius** — if a shared utility changed, who else uses it?

## Step 3: Read & Analyze

Read each changed file or diff. Separate findings into **Issues** (broken/dangerous) and **Improvements** (works but could be better).

### Issues — things that need fixing

| Priority      | When                                | Examples                                                    |
| ------------- | ----------------------------------- | ----------------------------------------------------------- |
| Critical (P0) | Security vulnerability or data loss | Exposed secrets, SQL injection, missing auth, RLS gaps      |
| High (P1)     | Will cause bugs in production       | Stale closures, unhandled crashes, wrong types via `as any` |
| Medium (P2)   | Should fix but won't break things   | Empty catch blocks, missing input validation                |
| Low (P3)      | Cleanup                             | Dead code, leftover console.log                             |

### Improvements — things that could be better

| Priority | When                                   | Examples                                                             |
| -------- | -------------------------------------- | -------------------------------------------------------------------- |
| High     | Significant impact on maintenance/perf | N+1 queries, monolithic 500+ line components, missing code-splitting |
| Medium   | Moderate benefit                       | DRY violations, missing memoization, inconsistent patterns           |
| Low      | Minor polish                           | Naming, minor readability tweaks                                     |

### What makes a good finding

**Good finding** (specific, evidence-based, actionable):

```
FlashcardViewer.tsx:237 — `onCardFlip` defined as plain function inside render body,
creating new reference every render. This defeats React.memo on FlashcardCard (line 22).
Fix: wrap in useCallback([handleFlip]).
```

**Bad finding** (vague, no evidence):

```
Consider improving performance of the component.
```

Frame uncertain points as questions: "Is the 80px swipe threshold intentional? On small screens this may be hard to trigger."

### Escalation flags

Flag for senior review (don't just note — explicitly call out):

- Database schema changes or migrations
- API contract modifications (new/changed endpoints)
- Authentication or authorization logic
- New external dependencies
- Changes to shared utilities used by multiple packages

## Step 4: Quality Gates

```bash
pnpm type-check
pnpm build
```

If either fails, it's a Critical finding. Include pass/fail in report.

## Step 5: Generate Report

Write to: `docs/reports/code-reviews/{YYYY-MM}/CR-{YYYY-MM-DD}-{topic}.md`

Use this structure, but adapt — a 2-file i18n review doesn't need the same sections as a 20-file refactor:

```markdown
# Code Review: {Topic}

**Date**: {YYYY-MM-DD}
**Scope**: {what was reviewed}
**Files**: {count} | **Changes**: +{added} / -{removed}

## Summary

|              | Critical | High | Medium | Low |
| ------------ | -------- | ---- | ------ | --- |
| Issues       | {n}      | {n}  | {n}    | {n} |
| Improvements | —        | {n}  | {n}    | {n} |

**Verdict**: {PASS | NEEDS WORK}

## Issues

### {Priority}

#### {n}. {Title}

- **File**: `{path}:{line}`
- **Problem**: {what's wrong}
- **Impact**: {why it matters — be specific}
- **Fix**: {concrete code or action}

## Improvements

### {Priority}

{same format, "Current" / "Recommended" for code}

## Positive Patterns

{Note 2-3 things done well — balanced feedback}

## Escalation

{Items requiring senior review, if any}

## Validation

- Type Check: {PASS/FAIL}
- Build: {PASS/FAIL}
```

Every finding must have: file:line, evidence of the problem, and a concrete fix. No generic advice.

## Step 6: Create Beads Tasks

```bash
# Issues
bd create "BUG: {title}" -t bug -p {0-3} -d "{file}:{line} — {description}. Fix: {fix}"

# Improvements
bd create "IMPROVE: {title}" -t chore -p {2-4} -d "{file}:{line} — {description}"

# Label all
bd update {id} --add-label code-review
```

## Step 7: Present Summary

```
## Code Review Complete

**Report**: `{path}`
**Verdict**: {PASS / NEEDS WORK}

| Priority | Issues | Improvements |
|---|---|---|
| Critical | {n} | — |
| High | {n} | {n} |
| Medium | {n} | {n} |
| Low | {n} | {n} |

**Beads tasks created**: {total} ({list IDs})

**Next**: {actionable guidance based on verdict}
```

## Project Conventions

These are specific to this codebase — the things you wouldn't know without being told:

- **Types**: Import from `@megacampus/shared-types`, never duplicate
- **Supabase**: Two admin clients by design (Node.js + Next.js runtimes)
- **Quality**: `pnpm type-check && pnpm build` must pass before merge
- **Monorepo**: `packages/web` (Next.js), `packages/course-gen-platform` (backend), `packages/shared-*`
- **i18n**: `next-intl` with ICU MessageFormat plurals, locales in `packages/web/messages/{en,ru}/`
- **Styling**: Tailwind + shadcn/ui, `cn()` utility for conditional classes
- **State**: No global state management — React hooks + context
- **Don't flag**: Two Supabase admin clients (intentional), generated `database.types.ts` (auto-generated)
