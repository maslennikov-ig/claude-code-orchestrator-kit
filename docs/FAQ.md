# ❓ Frequently Asked Questions

## Table of Contents

- [General Questions](#general-questions)
- [MCP Configuration](#mcp-configuration)
- [Agents & Workflows](#agents--workflows)
- [Development](#development)
- [Troubleshooting](#troubleshooting)

---

## General Questions

### What is Claude Code Orchestrator Kit?

Claude Code Orchestrator Kit is a comprehensive automation framework for Claude Code that provides:
- 33+ specialized AI agents for various development tasks
- 19+ slash commands for common workflows
- 15+ reusable skills (utility functions)
- 6 optimized MCP server configurations
- Quality gates and health monitoring

It transforms Claude Code from a conversational assistant into a powerful orchestration system for professional development workflows.

---

### Who is this for?

This kit is designed for:
- **Professional developers** building production applications with Claude Code
- **Teams** that need standardized workflows and quality gates
- **Projects** requiring automated testing, security audits, and dependency management
- **Anyone** who wants to supercharge their Claude Code experience

---

### Do I need to know how to code to use this?

**Basic usage**: No coding required for using existing agents and slash commands.

**Advanced usage**: Understanding of TypeScript, Node.js, and Git helps for:
- Creating custom agents
- Modifying MCP configurations
- Extending the system

---

### Is this compatible with existing Claude Code projects?

**Yes!** The kit is designed to be added to existing projects:

1. Copy `.claude/` directory to your project
2. Merge with existing agents (if any)
3. Configure MCP servers
4. Start using slash commands

See [MIGRATION-GUIDE.md](./MIGRATION-GUIDE.md) for detailed instructions.

---

## MCP Configuration

### When should I use BASE vs FULL MCP config?

**Use BASE (~600 tokens)** for:
- Daily development work
- Code reviews and refactoring
- Reading and understanding code
- Simple bug fixes
- Working with limited context window

**Use FULL (~5000 tokens)** for:
- Complex workflows requiring multiple integrations
- Database + UI + automation in single session
- Intensive development sessions (2+ hours)
- Working with multiple external services

**Rule of thumb**: Start with BASE (80% of use cases), upgrade to specialized configs only when needed.

---

### How do I know which MCP config to use?

Use this decision tree:

```
Need database work?
├─ Yes → SUPABASE or SUPABASE-FULL
└─ No → Continue

Need workflow automation (n8n)?
├─ Yes → N8N
└─ No → Continue

Need UI/UX work (Playwright, ShadCN)?
├─ Yes → FRONTEND
└─ No → Continue

Need multiple integrations at once?
├─ Yes → FULL
└─ No → BASE
```

See [PERFORMANCE-OPTIMIZATION.md](./PERFORMANCE-OPTIMIZATION.md) for token usage comparison.

---

### How do I switch between MCP configurations?

```bash
# Interactive menu
./switch-mcp.sh

# Select option 1-6 based on your needs
# Then restart Claude Code
```

The script copies the selected config to `.mcp.json` and restarts automatically loads it.

---

### What if I need custom MCP servers?

1. Create new config file: `mcp/.mcp.custom.json`
2. Add your MCP servers
3. Update `switch-mcp.sh` to include your config
4. Use environment variables for secrets (`.env.local`)

Example:
```json
{
  "mcpServers": {
    "my-custom-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "env": {
        "API_KEY": "${MY_CUSTOM_API_KEY}"
      }
    }
  }
}
```

---

### Why are environment variables not loading?

**Common issues:**

1. **File doesn't exist**: Ensure `.env.local` is present
   ```bash
   cp .env.example .env.local
   ```

2. **Wrong format**: Don't use quotes around values
   ```bash
   # ✅ Correct
   SUPABASE_PROJECT_REF=abc123xyz

   # ❌ Wrong
   SUPABASE_PROJECT_REF="abc123xyz"
   ```

3. **Not restarted**: Environment variables load on Claude Code startup
   - Fully quit and restart Claude Code (not just reload)

4. **Special characters**: Escape special chars in values
   ```bash
   PASSWORD=my\$ecret\!pass
   ```

---

## Agents & Workflows

### What's the difference between an Agent and a Skill?

| Aspect | Agent | Skill |
|--------|-------|-------|
| **Invocation** | Via Task tool | Via Skill tool |
| **Context** | Isolated context window | Caller's context |
| **Purpose** | Multi-step workflows | Single utility function |
| **Size** | Any size | <100 lines logic |
| **State** | Stateful, tracks progress | Stateless, pure function |
| **Reports** | Generates reports | Returns data directly |
| **Examples** | bug-hunter, security-scanner | parse-git-status, validate-plan-file |

**Rule of thumb**:
- Agent = autonomous workflow that needs coordination
- Skill = reusable utility that can be called from anywhere

---

### What's the difference between Orchestrator and Worker?

**Orchestrator**:
- Coordinates multi-phase workflows
- Creates plan files for workers
- Validates worker outputs at quality gates
- Manages iterations (e.g., max 3 cycles)
- Does NOT invoke workers directly (violates PD-1)
- Examples: bug-orchestrator, security-orchestrator

**Worker**:
- Executes specific tasks from plan files
- Generates structured reports
- Returns control to orchestrator
- Performs validation before reporting success
- Examples: bug-hunter, bug-fixer, security-scanner

**Pattern**: Orchestrator plans → Worker executes → Orchestrator validates → Repeat or finish

---

### What is the "Return Control Pattern"?

**Problem**: If orchestrators invoke workers via Task tool, context gets nested and complex.

**Solution**: Return Control Pattern

```
1. Orchestrator creates plan file (.tmp/current/plans/.workflow-plan.json)
2. Orchestrator signals "Ready for {worker-name}" and exits
3. Main session invokes worker manually
4. Worker reads plan, executes, generates report, exits
5. Main session invokes orchestrator to resume
6. Orchestrator validates report and continues
```

**Why?** Keeps context clean, enables rollback, prevents infinite loops.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for visual diagram.

---

### How do Quality Gates work?

Quality gates are automated validation checkpoints that ensure code quality before proceeding.

**Types**:
- **Blocking**: MUST pass or workflow halts (e.g., type-check, build)
- **Non-blocking**: Optional checks (e.g., tests, lint)

**Usage in plan files**:
```json
{
  "validation": {
    "required": ["type-check", "build"],
    "optional": ["tests"]
  }
}
```

**Behavior**:
- If blocking gate fails → HALT workflow, report error to user, ask fix/skip
- If optional gate fails → Log warning, continue
- All gates pass → Proceed to next phase

**Skill**: `run-quality-gate` executes validation commands.

---

### How do I create a custom agent?

**Quick method**: Use meta-agent

```
Ask Claude Code: "Create a worker agent for linting TypeScript files with ESLint"

Meta-agent will:
1. Ask for agent type (worker/orchestrator/simple)
2. Read ARCHITECTURE.md patterns
3. Generate agent file with proper structure
4. Validate against checklist
5. Write to .claude/agents/{category}/workers/{name}.md
```

**Manual method**: See [TUTORIAL-CUSTOM-AGENTS.md](./TUTORIAL-CUSTOM-AGENTS.md) for step-by-step guide.

---

### Can I use agents in CI/CD pipelines?

**Yes!** Example GitHub Actions workflow:

```yaml
name: Health Check

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run bug scan
        run: |
          claude-code /health-bugs

      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: bug-report
          path: bug-hunting-report.md
```

See `.github/workflows/` for examples.

---

### What is CLAUDE.md and why is it important?

**CLAUDE.md** is the "Behavioral Operating System" for all agents. It defines:

- **Prime Directives (PDs)**: Non-negotiable rules (e.g., Return Control Pattern, Quality Gates)
- **Behavioral Contracts**: What orchestrators/workers/MCPs promise to do
- **Fallback Strategies**: How to handle Context7 unavailable, quality gate failures, etc.
- **Emergency Protocols**: Infinite loop detection, file corruption, token exhaustion
- **Operational Procedures**: File structure, agent selection, plan file format

**All agents MUST comply** with CLAUDE.md. It ensures consistency, prevents anti-patterns, and enables self-diagnostics.

Think of it as the "constitution" for the agent ecosystem.

---

## Development

### How do I add a new MCP server to existing config?

1. Edit the MCP config file (e.g., `mcp/.mcp.base.json`):
   ```json
   {
     "mcpServers": {
       "existing-server": { ... },
       "new-server": {
         "command": "npx",
         "args": ["-y", "new-mcp-package"],
         "env": {
           "API_KEY": "${NEW_SERVER_API_KEY}"
         }
       }
     }
   }
   ```

2. Add environment variable to `.env.local`:
   ```bash
   NEW_SERVER_API_KEY=your-key-here
   ```

3. Restart Claude Code

---

### How do I test agents locally?

**Method 1: Direct invocation**
```
Ask Claude Code to invoke agent directly:
"Use bug-hunter agent to scan src/ directory"
```

**Method 2: Via orchestrator**
```
Run full workflow:
/health-bugs
```

**Method 3: Unit testing skills**
```bash
# Skills can be tested with simple inputs
# Example: Test parse-git-status skill
git status | claude-code "Use parse-git-status skill on this output"
```

---

### Can I modify existing agents?

**Yes!** Agents are just markdown files:

1. Open agent file: `.claude/agents/{category}/{type}/{name}.md`
2. Modify instructions, add phases, change validation
3. Save and test

**Best practice**: Keep modifications aligned with ARCHITECTURE.md patterns.

---

### How do I contribute new agents back to the project?

1. Fork repository
2. Create agent in `.claude/agents/{category}/`
3. Follow agent template structure
4. Test thoroughly
5. Update README.md with agent description
6. Submit PR with:
   - Agent file
   - Test examples
   - Documentation updates

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

---

## Troubleshooting

### Quality gates keep failing even after fixes

**Diagnosis**:
```bash
# Run gates manually to see full errors
npm run type-check
npm run build
npm run test

# Check for configuration issues
cat .claude/scripts/gates/check-*.sh
```

**Common fixes**:
- Update TypeScript strict mode settings
- Fix test configuration (jest.config.js)
- Check for circular dependencies
- Verify build output directory exists

---

### Orchestrator workflow stuck or not progressing

**Check progression artifacts**:
```bash
# 1. Verify plan file exists and is valid
cat .tmp/current/plans/*.json

# 2. Check if worker generated report
ls -la .tmp/current/reports/

# 3. Review changes log
cat .tmp/current/changes/*.json

# 4. Check for infinite loop
# (orchestrator should use check-infinite-loop skill)
```

**Common issues**:
- Worker failed silently (no report generated)
- Plan file missing `nextAgent` field
- Quality gate blocking without user prompt
- Infinite loop detected (same agent invoked 3+ times)

**Solution**: Check orchestrator logs, manually invoke next step, or restart workflow.

---

### Context7 MCP server not working

**Symptoms**: "Context7 unavailable" warnings in reports

**Diagnosis**:
```bash
# Check if Context7 is in active MCP config
cat .mcp.json | grep context7

# Test Context7 directly
# (Claude Code MCP tools should show mcp__context7__* tools)
```

**Fixes**:
1. Ensure `context7` is in your MCP config
2. Check internet connectivity (Context7 is cloud-based)
3. Verify no firewall blocking outbound requests
4. Switch to BASE or higher config (Context7 included)

**Fallback**: Workers will continue with reduced confidence if Context7 unavailable.

---

### Reports are incomplete or missing sections

**Diagnosis**: Use `validate-report-file` skill

```
Ask Claude Code: "Use validate-report-file skill to check {report-path}"
```

**Common missing sections**:
- Executive Summary
- Changes Made
- Validation Results
- Next Steps

**Fix**: Workers MUST follow REPORT-TEMPLATE-STANDARD.md format. Update worker agent if non-compliant.

---

### Agent says "violates PD-1" or similar

**Explanation**: Agent detected it's about to violate a Prime Directive (PD) from CLAUDE.md.

**Common PDs**:
- **PD-1**: Orchestrators cannot invoke workers via Task tool
- **PD-2**: Cannot skip blocking quality gates without user confirmation
- **PD-3**: Must log all file changes
- **PD-4**: Must validate with Context7 when available
- **PD-6**: Workers must generate structured reports

**Action**: This is CORRECT behavior. The agent is preventing an anti-pattern. Adjust workflow to comply with PD.

---

### Token budget exhausted before workflow completes

**At 180k tokens**:
- Agents automatically simplify (minimal reports, essential Context7 only)

**At 195k tokens**:
- Workflow HALTS
- Emergency summary generated
- User must start new session

**Prevention strategies**:
1. Use BASE config for daily work (saves 90% tokens)
2. Break large workflows into smaller chunks
3. Use specialized configs only when needed
4. Clear context periodically (`/clear` command)

See [PERFORMANCE-OPTIMIZATION.md](./PERFORMANCE-OPTIMIZATION.md) for details.

---

### How do I rollback changes after failed workflow?

**Automatic rollback**: Workers log changes to `.tmp/current/changes/{workflow}-changes.json`

**Manual rollback**:
```
Ask Claude Code: "Use rollback-changes skill to restore files from last workflow"

Skill will:
1. Read changes log
2. Restore backed-up files from .tmp/current/backups/
3. Revert file modifications
4. Report restored files
```

**Prevention**: Quality gates should catch failures before committing changes.

---

## Additional Resources

- **Architecture**: [ARCHITECTURE.md](./ARCHITECTURE.md) — System design and diagrams
- **Tutorial**: [TUTORIAL-CUSTOM-AGENTS.md](./TUTORIAL-CUSTOM-AGENTS.md) — Create custom agents
- **Use Cases**: [USE-CASES.md](./USE-CASES.md) — Real-world examples
- **Performance**: [PERFORMANCE-OPTIMIZATION.md](./PERFORMANCE-OPTIMIZATION.md) — Token/cost optimization
- **Migration**: [MIGRATION-GUIDE.md](./MIGRATION-GUIDE.md) — Add to existing projects
- **Roadmap**: [ROADMAP.md](./ROADMAP.md) — Future plans

---

**Still have questions?**

- Open an issue: [GitHub Issues](https://github.com/maslennikov-ig/claude-code-orchestrator-kit/issues)
- Join discussion: [GitHub Discussions](https://github.com/maslennikov-ig/claude-code-orchestrator-kit/discussions)
- Check main docs: [Agents Ecosystem](./Agents%20Ecosystem/)
