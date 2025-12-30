---
allowed-tools: Read, Write, Edit, Bash, Task
argument-hint: [--all] | --queries | --indexes | --rls | --functions | --realtime | --storage
description: Optimize Supabase database performance by delegating to specialized agents
---

# Supabase Performance Optimizer

Optimize Supabase database performance with specialized agents: **$ARGUMENTS**

## Agent Delegation Matrix

| Argument | Agent | What it fixes |
|----------|-------|---------------|
| `--queries`, `--indexes`, `--rls`, `--functions` | `supabase-fixer` | Advisors API issues (security + performance) |
| `--realtime` | `supabase-realtime-optimizer` | Publication issues, subscription indexes |
| `--storage` | `supabase-storage-optimizer` | Orphaned files, table sizes, data types |
| `--all` | All three agents | Complete optimization |

## Task Execution

Based on **$ARGUMENTS**, delegate to the appropriate agent(s):

### For `--queries`, `--indexes`, `--rls`, `--functions`:

Use Task tool with:
- `subagent_type`: `supabase-fixer`
- `prompt`: Focus on performance advisors for query/index optimization, or security advisors for RLS/function issues

### For `--realtime`:

Use Task tool with:
- `subagent_type`: `supabase-realtime-optimizer`
- `prompt`: Optimize realtime subscriptions, check publications, add missing indexes for filters

### For `--storage`:

Use Task tool with:
- `subagent_type`: `supabase-storage-optimizer`
- `prompt`: Analyze table sizes, find orphaned files, optimize data types

### For `--all`:

Run all three agents sequentially:
1. First: `supabase-fixer` (security + performance advisors)
2. Then: `supabase-realtime-optimizer` (realtime publications)
3. Finally: `supabase-storage-optimizer` (storage cleanup)

## Expected Output

Each agent generates a structured report in `.tmp/current/`:
- `database-fixing-report.md` (from supabase-fixer)
- `realtime-optimization-report.md` (from supabase-realtime-optimizer)
- `storage-optimization-report.md` (from supabase-storage-optimizer)

## Quick Reference

```bash
# Fix security issues (RLS, functions)
/supabase-performance-optimizer --rls --functions

# Optimize queries and indexes
/supabase-performance-optimizer --queries --indexes

# Optimize realtime subscriptions
/supabase-performance-optimizer --realtime

# Clean up storage
/supabase-performance-optimizer --storage

# Full optimization (all agents)
/supabase-performance-optimizer --all
```
