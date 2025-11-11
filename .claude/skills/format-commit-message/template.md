# Commit Message Template

## Format

```
{type}({scope}): {description}

{body}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Valid Types

- **feat**: New feature
- **fix**: Bug fix
- **chore**: Maintenance tasks, dependency updates
- **docs**: Documentation changes
- **refactor**: Code refactoring without behavior change
- **test**: Adding or updating tests
- **style**: Code style changes (formatting, whitespace)
- **perf**: Performance improvements

## Guidelines

1. **Type** (required): Use lowercase
2. **Scope** (optional): Component or area affected (lowercase, no spaces)
3. **Description** (required): Brief summary (< 72 chars, lowercase, no period)
4. **Body** (optional): Detailed explanation, wrap at 72 characters
5. **Footer** (auto-added): Claude Code attribution

## Breaking Changes

Add "BREAKING CHANGE: " prefix to body or as separate footer section.

## Examples

### Simple
```
feat: add user authentication
```

### With Scope
```
fix(api): resolve CORS configuration error
```

### With Body
```
refactor(database): optimize query performance

Replaced N+1 queries with batch loading strategy.
Reduced average query time by 60%.
```

### Breaking Change
```
feat(api): migrate to REST API v2

BREAKING CHANGE: Authentication tokens from v1 are no longer valid.
All clients must obtain new tokens using the v2 /auth endpoint.
```
