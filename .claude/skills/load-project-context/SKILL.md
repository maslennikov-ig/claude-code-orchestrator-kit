---
name: load-project-context
description: Load project structure and navigation for complex tasks. Use when exploring unfamiliar parts of codebase or starting complex multi-file tasks.
trigger: When exploring unfamiliar code areas, planning complex features, or needing project structure overview
---

# Load Project Context

Loads the project index file to understand project structure without reading the entire codebase.

## When to Use

- Before exploring unfamiliar parts of the codebase
- When planning complex multi-file changes
- When you need to understand where specific functionality lives
- At the start of complex orchestrator workflows

## When NOT to Use

- For simple, single-file tasks
- When you already know the file locations
- For trivial bug fixes

## Algorithm

1. Check if `.claude/project-index.md` exists
2. If exists:
   - Read the file
   - Return the content for agent consumption
3. If not exists:
   - Inform that project index is not configured
   - Suggest creating one from template

## Implementation

```markdown
### Step 1: Check for project index

Read the file `.claude/project-index.md`

### Step 2: If file exists

Return the full content. The agent should use this to:
- Understand project structure
- Identify key directories for the task
- Find relevant patterns and conventions

### Step 3: If file does not exist

Return this message:
"Project index not found. To create one:
1. Copy `.claude/templates/project-index.template.md` to `.claude/project-index.md`
2. Customize for your project structure
3. Keep under 150 lines for token efficiency"
```

## Output Format

The skill returns the project index content directly, which includes:
- Architecture overview with links
- Core domains with key directories
- Patterns and conventions
- Recent changes

## Token Cost

- File read: ~100-200 tokens (if index is well-maintained at <150 lines)
- No additional processing overhead

## Example Usage

```
Agent: I need to understand where authentication is handled in this project.

[Invokes load-project-context skill]

Skill returns project-index.md content showing:
- Auth pattern: "Supabase Auth + RLS policies"
- Key directory: "packages/api/src/middleware/" for auth middleware

Agent now knows exactly where to look without scanning entire codebase.
```

## Maintenance

The project index should be updated:
- When major architectural changes occur
- Weekly for "Recent Changes" section
- When new domains/packages are added
