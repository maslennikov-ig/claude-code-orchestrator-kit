# Command: /health-metrics

Generate monthly agent ecosystem health metrics report.

## Usage

```
/health-metrics           # Current month
/health-metrics 2025-09   # Specific month
/health-metrics last-month
```

## Process

### 1. Read Metrics Files

- Current: `.tmp/metrics/YYYY-MM.json`
- Previous (comparison): `.tmp/metrics/YYYY-(MM-1).json`

If file missing: Report "No metrics data for {month}" and exit.

### 2. Analyze Metrics

**Agent Performance**:
- Success Rate: `(successes / invocations) * 100`
- Categories: Top (>=90%), Needs Improvement (<70%), Underutilized (<5 invocations)

**Orchestrators**: Success rate, abort rate, avg iterations

**Quality Gates** (type-check, build, tests): Pass rate, flag if <85%

**Complexity Distribution**: % by level (trivial/moderate/high/critical)

**Context7**: Success rate, availability, avg response time, top libraries

**Behavioral OS**: Fallback frequency (flag if >5%), emergency incidents

### 3. Generate Recommendations

- **High Priority**: Success rate <70%, emergencies
- **Medium Priority**: Pass rate <85%, underutilization
- **Low Priority**: Optimizations

### 4. Create Report

**Location**: `docs/reports/metrics/YYYY-MM-ecosystem-health.md`

**Report Sections**:
1. Executive Summary (Overall Health: GOOD >=90% | FAIR >=75% | POOR <75%)
2. Agent Performance (Top Performers, Needs Improvement, Underutilized)
3. Orchestrator Performance (table with runs, success rate, iterations)
4. Quality Gates (table with pass rates, status indicators)
5. Complexity Distribution (table by level)
6. Context7 Integration (queries, success rate, top libraries)
7. Token Efficiency (minimal vs full MCP mode)
8. Behavioral OS Health (fallbacks, emergencies, violations)
9. Recommendations (prioritized)
10. Trend Analysis (vs previous month with indicators)
11. Conclusion (overall status, next steps)

**Trend Indicators**: Change >2% = increase, <-2% = decrease, else stable

**Health Determination**:
- HEALTHY AND IMPROVING: >=90% + no emergencies + positive trends
- HEALTHY: >=80% + <2 emergencies
- NEEDS ATTENTION: 70-79% OR 2-5 emergencies
- CRITICAL: <70% OR >5 emergencies

### 5. Output Summary

```
Report: docs/reports/metrics/YYYY-MM-ecosystem-health.md
- Overall Health: {status}
- Total Invocations: {count}
- Success Rate: {percent}%
- Top Performer: {agent}
- Top Concern: {issue}
```

## Error Handling

- **No data**: Exit with suggestion to run agent workflows
- **Corrupt file**: Try backup `.tmp/metrics/YYYY-MM.json.backup`
- **Write failure**: Check disk space and permissions

## Related

- `record-metrics` Skill: Records events to metrics files
- `.tmp/metrics/YYYY-MM.json`: Monthly data files
