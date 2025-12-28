---
name: run-quality-gate
description: Execute quality gate validation with configurable blocking behavior. Use when running type-check, build, tests, lint, or custom validation commands in orchestrators or workers to enforce quality standards.
allowed-tools: Bash, Read
---

# Run Quality Gate

Execute validation commands as quality gates with structured error reporting.

## When to Use

- Type-check, build, test, lint validation
- Orchestrator phase validation
- Worker self-validation

## Input

```json
{
  "gate": "type-check|build|tests|lint|custom",
  "blocking": true,
  "custom_command": "pnpm custom-validate"
}
```

## Gate Commands

| Gate | Command |
|------|---------|
| type-check | `pnpm type-check` |
| build | `pnpm build` |
| tests | `pnpm test` |
| lint | `pnpm lint` |
| custom | `custom_command` value |

## Process

1. **Map gate to command** - Validate custom_command if gate="custom"
2. **Execute via Bash** - Timeout: 5 minutes, capture stdout/stderr
3. **Parse result** - Exit code 0 = passed, non-zero = failed
4. **Extract errors** - Lines with "error", "failed", TS#### codes
5. **Determine action**:
   - Passed → action="continue"
   - Failed + blocking → action="stop"
   - Failed + non-blocking → action="warn"

## Output

```json
{
  "gate": "type-check",
  "passed": true,
  "blocking": true,
  "action": "continue",
  "errors": [],
  "exit_code": 0,
  "duration_ms": 2345,
  "command": "pnpm type-check",
  "timestamp": "2025-10-18T14:30:00Z"
}
```

## Examples

**Blocking gate passes**:
```json
{ "gate": "type-check", "blocking": true }
→ { "passed": true, "action": "continue", "errors": [] }
```

**Blocking gate fails** (stops workflow):
```json
{ "gate": "build", "blocking": true }
→ { "passed": false, "action": "stop", "errors": ["Module not found: missing-module"] }
```

**Non-blocking gate fails** (warns only):
```json
{ "gate": "lint", "blocking": false }
→ { "passed": false, "action": "warn", "errors": ["Missing semicolon"] }
```

## Error Handling

- **Timeout (5 min)**: Return failed with timeout error
- **Missing custom_command**: Return error
- **Command not found**: Return failed with exit_code=127

## Notes

- Exit code 0 always = success regardless of output
- Blocking flag only affects action, not passed status
- Error extraction is best-effort
