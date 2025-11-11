# Command: /health-metrics

You are analyzing agent ecosystem health metrics to generate monthly performance reports.

## Purpose

Generate comprehensive monthly metrics report showing agent performance, quality gates, complexity distribution, Context7 usage, and system health for data-driven optimization decisions.

## Process

### Step 1: Determine Reporting Period

**Default**: Current month (YYYY-MM format)

**User can specify**: Previous month or specific month

**Examples**:
- `/health-metrics` → Current month (2025-10)
- `/health-metrics 2025-09` → September 2025
- `/health-metrics last-month` → Previous month

### Step 2: Read Metrics Files

**Current Month**:
```
File: .tmp/metrics/YYYY-MM.json
```

**Previous Month** (for comparison):
```
File: .tmp/metrics/YYYY-(MM-1).json
```

**If file doesn't exist**:
- Report: "No metrics data for {month}"
- Suggest: "Run agent workflows to generate metrics first"
- Exit gracefully

**If file corrupt**:
- Attempt to read backup: `.tmp/metrics/YYYY-MM.json.backup`
- If backup also corrupt: Report error and exit
- Log corruption incident

### Step 3: Analyze Metrics

Calculate key insights from metrics data.

#### Agent Performance Analysis

**For each agent**:
- **Success Rate**: `(successes / invocations) * 100`
- **Performance Trend**: Compare avg_duration vs previous month
- **Value Delivered**: Count of bugs/vulnerabilities/issues found

**Categorize Agents**:
- **Top Performers**: Success rate >= 90%
- **Needs Improvement**: Success rate < 70%
- **Underutilized**: Invocations < 5 per month

#### Orchestrator Performance Analysis

**For each orchestrator**:
- **Success Rate**: `(completed / runs) * 100`
- **Abort Rate**: `(aborted / runs) * 100`
- **Iteration Efficiency**: avg_iterations (lower is better)
- **Max Iterations Hit**: Count (indicates complexity issues)

#### Quality Gates Analysis

**For each gate (type-check, build, tests)**:
- **Pass Rate**: Already calculated in metrics
- **Trend**: Compare pass rate vs previous month
- **Flag Concerns**: Pass rate < 85%

#### Complexity Distribution

**Analyze complexity levels**:
- **Percentage by level**: Calculate % for trivial/moderate/high/critical
- **Research Usage**: % of high/critical that triggered research
- **Average Score**: Indicates overall task difficulty

#### Context7 Integration Health

**Metrics**:
- **Success Rate**: `(successful_queries / total_queries) * 100`
- **Availability**: `100 - (unavailable_events / total_invocations * 100)`
- **Performance**: avg_response_time_ms
- **Top Libraries**: Sort by query count

#### Behavioral OS Health

**Fallback Frequency**:
- Count total fallbacks
- Calculate % of invocations that triggered fallbacks
- Flag if any fallback > 5% frequency

**Emergency Incidents**:
- Count each emergency type
- Flag if any emergency occurred (should be rare)

**Prime Directive Violations**:
- Should be 0 (self-diagnostics prevent violations)
- If > 0: Critical issue, needs investigation

### Step 4: Generate Trend Analysis

Compare current month vs previous month (if available).

**Metrics to Compare**:
- Total invocations (growth indicator)
- Overall success rate (reliability trend)
- Quality gate pass rates (code health trend)
- Context7 usage (adoption trend)
- Research phases triggered (complexity trend)

**Change Indicators**:
- ⬆️ Increase
- ⬇️ Decrease
- ➡️ No change (within 2%)

### Step 5: Generate Recommendations

Based on data analysis, provide actionable recommendations.

**High Priority** (Success rate < 70%, emergency incidents):
- Specific agent improvements needed
- Quality gate investigations required
- System reliability issues

**Medium Priority** (Pass rate < 85%, underutilization):
- Agent discoverability improvements
- Documentation updates
- Workflow optimizations

**Low Priority** (Nice-to-have optimizations):
- Token efficiency improvements
- Performance optimizations
- Feature requests

### Step 6: Create Report

**Location**: `docs/reports/metrics/YYYY-MM-ecosystem-health.md`

**Directory Creation**:
- If `docs/reports/metrics/` doesn't exist: create it
- Ensure parent directories exist

**Report Format**:

```markdown
# Agent Ecosystem Health Report — {Month} {Year}

**Generated**: {timestamp}
**Period**: {Month} 1-{last day}, {Year}
**Total Agent Invocations**: {count}

---

## Executive Summary

**Overall Health**: ✅ **GOOD** | ⚠️ **FAIR** | ❌ **POOR** ({success_rate}% success rate)

**Determination**:
- >= 90% success rate: GOOD ✅
- >= 75% success rate: FAIR ⚠️
- < 75% success rate: POOR ❌

**Highlights**:
- Most used agent: {agent_name} ({invocations} invocations)
- Best performer: {agent_name} ({success_rate}% success rate)
- Top concern: {agent_name} ({issue_description})

**Key Metrics**:
- Total bugs found: {count}
- Total vulnerabilities found: {count}
- Context7 queries: {count} ({success_rate}% success rate)
- Quality gates pass rate: {percent}%

---

## Agent Performance

### Top Performers ✅

For each agent with >= 90% success rate:

#### {Agent Name}
- **Success Rate**: {percent}% ({successes}/{invocations})
- **Avg Duration**: {minutes} minutes
- **Value**: {metric description}
- **Context7 Usage**: {percent}% ({queries} queries)
- **Trend**: {comparison to previous month}

### Needs Improvement ⚠️

For each agent with < 70% success rate:

#### {Agent Name}
- **Success Rate**: {percent}% ({successes}/{invocations})
- **Avg Duration**: {minutes} minutes
- **Failures**: {count} ({failure_rate}%)
- **Root Cause**: {analysis based on failure patterns}
- **Recommendation**: {specific actionable improvement}

### Underutilized 📊

For each agent with < 5 invocations:

#### {Agent Name}
- **Invocations**: Only {count} (lowest usage)
- **Success Rate**: {percent}% ({successes}/{invocations})
- **Value**: {metric description}
- **Recommendation**: {discoverability/documentation improvements}

---

## Orchestrator Performance

| Orchestrator | Runs | Completed | Aborted | Success Rate | Avg Duration | Avg Iterations |
|--------------|------|-----------|---------|--------------|--------------|----------------|
| {name} | {runs} | {completed} | {aborted} | {percent}% | {minutes} min | {iterations} |

**Insights**:
- {Analysis of orchestrator patterns}
- {Concerns about abort rates or iterations}
- {Recommendations for improvements}

---

## Quality Gates

| Gate | Runs | Passes | Failures | Pass Rate | Avg Duration |
|------|------|--------|----------|-----------|--------------|
| type-check | {runs} | {passes} | {failures} | {percent}% {status} | {seconds}s |
| build | {runs} | {passes} | {failures} | {percent}% {status} | {seconds}s |
| tests | {runs} | {passes} | {failures} | {percent}% {status} | {seconds}s |

**Status Indicators**:
- ✅ Pass rate >= 90%
- ⚠️ Pass rate 75-89%
- ❌ Pass rate < 75%

**Concerns**:
For each gate with pass rate < 85%:
- **{Gate Name}**: {percent}% pass rate (below 90% target)
  - Investigation needed: {reason for failures}
  - Recommendation: {specific action}

---

## Complexity Distribution

**Tasks Analyzed**: {count}

| Level | Count | % | Research Triggered |
|-------|-------|---|--------------------|
| Trivial (0-3) | {count} | {percent}% | {count} |
| Moderate (4-6) | {count} | {percent}% | {count} |
| High (7-8) | {count} | {percent}% | {count} |
| Critical (9-10) | {count} | {percent}% | {count} |

**Insights**:
- Most tasks are {level} complexity ({percent}%)
- Research phase used {appropriately|too often|too rarely}
- Avg complexity score: {score} ({level})

**Analysis**:
- If avg score > 6: Codebase has many complex issues, consider dedicated research time
- If avg score < 4: Mostly simple fixes, direct workflow is efficient
- If research triggered for trivial/moderate: Scoring calibration needed

---

## Context7 Integration

**Total Queries**: {count}
**Success Rate**: {percent}% ({successes}/{total})
**Avg Response Time**: {seconds} seconds
**Unavailable Events**: {count} ({percent}% of time)

**Top Libraries Queried**:
1. {Library}: {count} queries ({percent}%)
2. {Library}: {count} queries ({percent}%)
3. {Library}: {count} queries ({percent}%)
4. {Library}: {count} queries ({percent}%)
5. {Library}: {count} queries ({percent}%)

**Performance**: {EXCELLENT|GOOD|FAIR|POOR}

**Determination**:
- Success rate >= 95% AND response time < 2s: EXCELLENT ✅
- Success rate >= 90% AND response time < 3s: GOOD ✅
- Success rate >= 80% OR response time < 5s: FAIR ⚠️
- Otherwise: POOR ❌

**Concerns** (if any):
- If success rate < 95%: {analysis and recommendation}
- If response time > 2s: {analysis and recommendation}
- If unavailable > 1%: {analysis and recommendation}

---

## Token Efficiency

**Estimated Conversations**: {count}
**Minimal MCP Mode**: {count} ({percent}%)
**Full MCP Mode**: {count} ({percent}%)

**Token Savings**:
- Avg tokens saved per conversation: ~{count}
- Total tokens saved (estimated): ~{count}
- **ROI**: Minimal MCP mode reduces token usage by ~{percent}% per conversation

**Analysis**:
- {percent}% of conversations use minimal mode (target: >85%)
- Estimated savings: {count} tokens/month
- {Recommendations for optimizing MCP usage}

---

## Behavioral OS Health

### Fallback Strategies Triggered

| Fallback | Count | % of Invocations |
|----------|-------|------------------|
| Context7 unavailable | {count} | {percent}% |
| Quality gate failure | {count} | {percent}% |
| Max iterations reached | {count} | {percent}% |
| Worker failure | {count} | {percent}% |
| Plan invalid | {count} | {percent}% |

**Analysis**: {HEALTHY|CONCERNING|CRITICAL}

**Determination**:
- All fallbacks < 5%: HEALTHY ✅
- Any fallback 5-10%: CONCERNING ⚠️
- Any fallback > 10%: CRITICAL ❌

**Concerns** (if any):
For each fallback > 5%:
- **{Fallback Type}**: {percent}% frequency
  - Root cause: {analysis}
  - Recommendation: {action to reduce frequency}

### Emergency Protocols Triggered

| Emergency | Count |
|-----------|-------|
| Infinite loop | {count} |
| File corruption | {count} |
| Token exhaustion | {count} |
| Concurrent conflict | {count} |

**Analysis**: {EXCELLENT|CONCERNING|CRITICAL}

**Determination**:
- Zero emergencies: EXCELLENT ✅
- 1-2 emergencies: CONCERNING ⚠️
- > 2 emergencies: CRITICAL ❌

**Incidents** (if any):
For each emergency > 0:
- **{Emergency Type}**: {count} incident(s)
  - Details: {from emergency metadata if available}
  - Impact: {analysis}
  - Prevention: {recommendation}

### Prime Directive Violations

**Count**: {count} {flagged and prevented|CRITICAL - violations occurred}

**Status**:
- 0 violations: ✅ **EXCELLENT** (self-diagnostics working)
- > 0 violations: ❌ **CRITICAL** (system integrity compromised)

**Details** (if > 0):
For each violation:
1. {PD-X violation description}
   - Agent: {name}
   - When: {timestamp}
   - How caught: {self-diagnostics|manual detection}
   - Impact: {user impact assessment}
   - Fix: {what was done to prevent}

---

## Recommendations

### High Priority

For critical issues (success rate < 70%, emergencies, violations):

1. **{Recommendation Title}**
   - Issue: {specific problem}
   - Impact: {why it matters}
   - Action: {what to do}
   - Target: {measurable goal}

### Medium Priority

For important improvements (pass rate < 85%, underutilization):

2. **{Recommendation Title}**
   - Issue: {specific problem}
   - Impact: {why it matters}
   - Action: {what to do}
   - Target: {measurable goal}

### Low Priority

For optimizations (nice-to-have improvements):

3. **{Recommendation Title}**
   - Opportunity: {what could be better}
   - Benefit: {value of improvement}
   - Action: {what to do}

---

## Trend Analysis (vs. {Previous Month})

| Metric | {Current Month} | {Previous Month} | Change |
|--------|-----------------|------------------|--------|
| Total invocations | {count} | {count} | {percent}% {indicator} |
| Success rate | {percent}% | {percent}% | {percent}% {indicator} |
| Context7 usage | {percent}% | {percent}% | {percent}% {indicator} |
| Quality gate pass rate | {percent}% | {percent}% | {percent}% {indicator} |
| Research phases | {count} | {count} | {percent}% {indicator} |

**Insights**:
- Ecosystem usage {growing|stable|declining} ({indicator} invocations)
- Reliability {improving|stable|declining} ({indicator} success rate)
- Complexity {increasing|stable|decreasing} ({indicator} research phases)

**Analysis**:
- {Interpretation of trends}
- {What's working well}
- {What needs attention}

---

## Conclusion

**Overall Status**: {HEALTHY AND IMPROVING|HEALTHY|NEEDS ATTENTION|CRITICAL}

**Determination**:
- Success rate >= 90% AND no emergencies AND positive trends: HEALTHY AND IMPROVING ✅
- Success rate >= 80% AND < 2 emergencies: HEALTHY ✅
- Success rate 70-79% OR 2-5 emergencies: NEEDS ATTENTION ⚠️
- Success rate < 70% OR > 5 emergencies: CRITICAL ❌

**Summary**:
{1-2 paragraph summary of ecosystem health, key achievements, main concerns, and overall trajectory}

**Next Steps**:
1. {Most important action item with timeline}
2. {Second most important action with timeline}
3. {When to re-evaluate metrics}

---

## Appendix: Raw Data

**Metrics File**: `.tmp/metrics/{YYYY-MM}.json`

To view detailed raw metrics:
```bash
cat .tmp/metrics/{YYYY-MM}.json | jq .
```

To compare with previous month:
```bash
diff <(cat .tmp/metrics/{YYYY-MM-1}.json | jq .) <(cat .tmp/metrics/{YYYY-MM}.json | jq .)
```
```

### Step 7: Display Report Location

Report successful generation to user.

**Message**:
```
✅ Metrics report generated successfully

Report: docs/reports/metrics/{YYYY-MM}-ecosystem-health.md

Summary:
- Overall Health: {status}
- Total Invocations: {count}
- Success Rate: {percent}%
- Top Performer: {agent_name}
- Top Concern: {issue if any}

View full report:
cat docs/reports/metrics/{YYYY-MM}-ecosystem-health.md
```

---

## Error Handling

### No Metrics Data

**Issue**: Metrics file doesn't exist for requested month

**Action**:
```
❌ No metrics data for {month}

Metrics file not found: .tmp/metrics/{YYYY-MM}.json

This means no agent workflows were run during {month}.

To generate metrics:
1. Run agent workflows: /health-bugs, /health-security, etc.
2. Agents automatically record metrics via record-metrics Skill
3. Re-run /health-metrics after workflows complete

Note: Metrics are stored monthly in .tmp/metrics/ directory.
```

### Corrupt Metrics File

**Issue**: Metrics file exists but has invalid JSON

**Action**:
```
⛔ Metrics file corrupt

File: .tmp/metrics/{YYYY-MM}.json
Error: Invalid JSON (SyntaxError: ...)

Attempting to read backup...
```

If backup exists and valid:
```
✅ Restored from backup

Backup: .tmp/metrics/{YYYY-MM}.json.backup
Status: Valid

Generating report from backup data...
```

If backup also corrupt:
```
❌ Backup also corrupt or not found

Cannot generate report from corrupted data.

Options:
1. Review .tmp/metrics/{YYYY-MM}.json manually
2. Delete corrupt file and start fresh next month
3. Report this issue (file corruption shouldn't happen)

File corruption may indicate:
- Concurrent write conflict
- Disk I/O error
- System crash during metrics recording
```

### Report Generation Failed

**Issue**: Error creating report file

**Action**:
```
⛔ Report generation failed

Target: docs/reports/metrics/{YYYY-MM}-ecosystem-health.md
Error: {error message}

Possible causes:
- Insufficient disk space
- Permission denied (check docs/reports/metrics/ permissions)
- Disk I/O error

Recommendation:
1. Check disk space: df -h
2. Check permissions: ls -la docs/reports/
3. Retry after resolving issue
```

---

## Examples

### Example 1: Current Month Report

**Command**: `/health-metrics`

**Actions**:
1. Determine current month: 2025-10
2. Read `.tmp/metrics/2025-10.json`
3. Read `.tmp/metrics/2025-09.json` (previous month for comparison)
4. Analyze all metrics sections
5. Calculate trends (vs September)
6. Generate recommendations
7. Write report to `docs/reports/metrics/2025-10-ecosystem-health.md`

**Output**:
```
✅ Metrics report generated successfully

Report: docs/reports/metrics/2025-10-ecosystem-health.md

Summary:
- Overall Health: HEALTHY AND IMPROVING ✅
- Total Invocations: 150
- Success Rate: 91%
- Top Performer: security-scanner (100% success rate)
- Top Concern: dependency-updater (70% success rate)

View full report:
cat docs/reports/metrics/2025-10-ecosystem-health.md
```

### Example 2: Previous Month Report

**Command**: `/health-metrics last-month`

**Actions**:
1. Determine previous month: 2025-09
2. Read `.tmp/metrics/2025-09.json`
3. Read `.tmp/metrics/2025-08.json` (for comparison)
4. Generate report for September

**Output**:
```
✅ Metrics report generated successfully

Report: docs/reports/metrics/2025-09-ecosystem-health.md

Summary:
- Overall Health: HEALTHY ✅
- Total Invocations: 132
- Success Rate: 88%
- Top Performer: security-scanner (100% success rate)
- Top Concern: dependency-updater (65% success rate)
```

### Example 3: Specific Month

**Command**: `/health-metrics 2025-08`

**Actions**:
1. Parse month: 2025-08
2. Read `.tmp/metrics/2025-08.json`
3. Read `.tmp/metrics/2025-07.json` (for comparison)
4. Generate report for August

### Example 4: No Data Available

**Command**: `/health-metrics 2025-07`

**Actions**:
1. Attempt to read `.tmp/metrics/2025-07.json`
2. File not found

**Output**:
```
❌ No metrics data for July 2025

Metrics file not found: .tmp/metrics/2025-07.json

This means no agent workflows were run during July 2025.

To generate metrics:
1. Run agent workflows: /health-bugs, /health-security, etc.
2. Agents automatically record metrics via record-metrics Skill
3. Re-run /health-metrics after workflows complete
```

---

## Implementation Notes

### Month Calculation

**Current Month**:
```
Today: 2025-10-21
Current month: 2025-10
```

**Previous Month**:
```
Current: 2025-10
Previous: 2025-09

Edge case (January):
Current: 2025-01
Previous: 2024-12
```

### Health Status Determination

**Agent Success Rate**:
- >= 90%: Top Performer ✅
- 70-89%: Acceptable
- < 70%: Needs Improvement ⚠️

**Overall System Health**:
- >= 90% success rate + no emergencies + positive trends: HEALTHY AND IMPROVING ✅
- >= 80% success rate + < 2 emergencies: HEALTHY ✅
- 70-79% success rate OR 2-5 emergencies: NEEDS ATTENTION ⚠️
- < 70% success rate OR > 5 emergencies: CRITICAL ❌

### Report File Naming

**Format**: `{YYYY-MM}-ecosystem-health.md`

**Examples**:
- `2025-10-ecosystem-health.md`
- `2025-09-ecosystem-health.md`

### Trend Indicators

**Calculation**:
```
Change % = ((New - Old) / Old) * 100

If change > 2%: ⬆️ (increase)
If change < -2%: ⬇️ (decrease)
If change between -2% and 2%: ➡️ (stable)
```

---

## Benefits

✅ **Visibility**: Clear view of ecosystem health each month
✅ **Trends**: Track improvements (or regressions) over time
✅ **Data-Driven**: Make optimization decisions based on real metrics
✅ **Accountability**: Demonstrate ROI with concrete numbers
✅ **Early Detection**: Flag issues before they become critical
✅ **Transparency**: Share ecosystem health with team/stakeholders

---

## Related

- `record-metrics` Skill: Records events that populate metrics files
- `.tmp/metrics/YYYY-MM.json`: Monthly metrics data files
- CLAUDE.md PART 5: Self-Diagnostics uses metrics for validation
