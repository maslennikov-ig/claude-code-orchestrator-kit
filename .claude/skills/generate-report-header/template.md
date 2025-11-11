# Report Header Template

## Standard Format

```markdown
# {ReportType} Report: {Version}

**Generated**: {Timestamp}
**Status**: {Emoji} {Status}
**Version**: {Version}

---

## Executive Summary
```

## Status Values

- **success** (✅): Operation completed successfully
- **partial** (⚠️): Operation completed with warnings or partial failures
- **failed** (❌): Operation failed critically
- **in_progress** (🔄): Operation is currently running

## Timestamp Format

ISO-8601 or human-readable: "YYYY-MM-DD HH:mm:ss UTC"

## Optional Metadata Fields

Common additional fields:
- **Agent**: Worker agent name
- **Duration**: Execution time
- **Files Processed**: Number of files
- **Issues Found**: Count of issues
- **Error**: Error message (for failed status)

## Report Types

- Bug Hunting Report
- Security Audit Report
- Dead Code Report
- Dependency Audit Report
- Version Update Report
- Code Health Report
- Verification Report

## Example Complete Header

```markdown
# Bug Hunting Report: 2025-10-17

**Generated**: 2025-10-17 14:30:00 UTC
**Status**: ✅ success
**Version**: 2025-10-17
**Agent**: bug-hunter
**Duration**: 3m 45s
**Files Scanned**: 147
**Bugs Found**: 23

---

## Executive Summary

This report documents the results of automated bug detection across the codebase.
Critical: 3 | High: 8 | Medium: 12
```
