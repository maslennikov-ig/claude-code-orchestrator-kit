# 🔄 Migration Guide

## Adding Orchestrator Kit to Existing Projects

### Quick Start

```bash
# 1. Backup your existing .claude directory (if exists)
mv .claude .claude.backup

# 2. Copy Orchestrator Kit
cp -r /path/to/claude-code-orchestrator-kit/.claude ./

# 3. If you had custom agents, merge them
cp .claude.backup/agents/my-custom-agent.md .claude/agents/

# 4. Configure environment
cp .env.example .env.local
# Edit .env.local with your credentials

# 5. Select MCP configuration
./switch-mcp.sh

# 6. Restart Claude Code
```

---

## Step-by-Step Migration

### Step 1: Assessment

**Before copying anything, assess your current setup:**

```bash
# Check existing agents
ls -la .claude/agents/

# Check custom commands
ls -la .claude/commands/

# Check scripts
ls -la .claude/scripts/

# Check if CLAUDE.md exists
cat CLAUDE.md
```

**Document what you have:**
- Custom agents you want to keep
- Custom commands
- Custom scripts
- Existing MCP configurations

---

### Step 2: Backup

**Create backup of existing setup:**

```bash
# Full backup
tar -czf claude-backup-$(date +%Y%m%d).tar.gz .claude/ CLAUDE.md .mcp.json

# Or simple copy
cp -r .claude .claude.backup
cp CLAUDE.md CLAUDE.md.backup
cp .mcp.json .mcp.json.backup
```

---

### Step 3: Install Orchestrator Kit

```bash
# Clone or download kit
git clone https://github.com/maslennikov-ig/claude-code-orchestrator-kit.git
# Or: download and extract ZIP

# Copy .claude directory
cp -r claude-code-orchestrator-kit/.claude ./

# Copy CLAUDE.md (Behavioral OS)
cp claude-code-orchestrator-kit/CLAUDE.md ./

# Copy MCP configurations
cp -r claude-code-orchestrator-kit/mcp ./

# Copy switch script
cp claude-code-orchestrator-kit/switch-mcp.sh ./
chmod +x switch-mcp.sh

# Copy environment template
cp claude-code-orchestrator-kit/.env.example ./.env.local
```

---

### Step 4: Merge Custom Agents

**If you had custom agents in `.claude.backup/agents/`:**

```bash
# List your custom agents
ls .claude.backup/agents/

# Copy custom agents to appropriate category
cp .claude.backup/agents/my-custom-worker.md .claude/agents/development/workers/
cp .claude.backup/agents/my-orchestrator.md .claude/agents/custom/orchestrators/

# Verify no conflicts
diff .claude.backup/agents/my-agent.md .claude/agents/development/workers/my-agent.md
```

**Update custom agents to follow new patterns:**
```markdown
# Update YAML frontmatter if needed
---
name: my-agent
description: Use proactively for {task}...
model: sonnet
color: cyan
---

# Check references to ARCHITECTURE.md, CLAUDE.md
# Update plan file locations to .tmp/current/plans/
# Update report locations to .tmp/current/reports/
```

---

### Step 5: Configure Environment

**Edit `.env.local`:**

```bash
# Required for Supabase MCP
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_ACCESS_TOKEN=your-token
SUPABASE_DB_PASSWORD=your-password

# Required for Sequential Thinking
SEQUENTIAL_THINKING_KEY=your-smithery-key
SEQUENTIAL_THINKING_PROFILE=your-profile

# Optional for n8n
N8N_API_URL=https://your-n8n.com
N8N_API_KEY=your-api-key
```

**Security check:**
```bash
# Verify .env.local is git-ignored
cat .gitignore | grep ".env.local"

# If not, add it
echo ".env.local" >> .gitignore
```

---

### Step 6: Select MCP Configuration

```bash
# Run interactive switcher
./switch-mcp.sh

# Select appropriate config:
# 1. BASE - Minimal (start here)
# 2. SUPABASE - Database work
# 3. SUPABASE-FULL - Multi-project
# 4. N8N - Workflow automation
# 5. FRONTEND - UI/UX work
# 6. FULL - Everything

# For first-time setup, recommend: BASE
```

---

### Step 7: Test Installation

```bash
# Verify agents loaded
# (In Claude Code)
"List available agents"

# Test a simple command
/health-metrics

# Test agent invocation
"Use bug-hunter to scan src/"

# Verify MCP servers working
"Check Context7 availability"
```

---

## Migration Scenarios

### Scenario 1: No Existing .claude Directory

**This is the easiest scenario:**

```bash
# Simply copy everything
cp -r claude-code-orchestrator-kit/.claude ./
cp claude-code-orchestrator-kit/CLAUDE.md ./
cp -r claude-code-orchestrator-kit/mcp ./
cp claude-code-orchestrator-kit/switch-mcp.sh ./
cp claude-code-orchestrator-kit/.env.example ./.env.local

# Configure and start
./switch-mcp.sh
```

---

### Scenario 2: Existing .claude with Custom Agents

**Merge approach:**

```bash
# 1. Backup existing
mv .claude .claude.backup

# 2. Install kit
cp -r claude-code-orchestrator-kit/.claude ./

# 3. Create custom category
mkdir -p .claude/agents/custom/workers/
mkdir -p .claude/agents/custom/orchestrators/

# 4. Copy custom agents
cp .claude.backup/agents/*.md .claude/agents/custom/workers/

# 5. Update custom agents (if needed)
# - Update YAML frontmatter
# - Update references to ARCHITECTURE.md
# - Update file paths (.tmp/current/...)
```

---

### Scenario 3: Existing MCP Configuration

**Merge MCP configs:**

```bash
# 1. Backup existing MCP
cp .mcp.json .mcp.json.backup

# 2. Copy kit's MCP configs
cp -r claude-code-orchestrator-kit/mcp ./

# 3. Merge custom MCP servers into BASE config
# Edit mcp/.mcp.base.json:
{
  "mcpServers": {
    "context7": { ... },
    "server-sequential-thinking": { ... },
    "my-custom-mcp": {
      "command": "...",
      "args": [...],
      "env": { ... }
    }
  }
}

# 4. Switch to merged config
./switch-mcp.sh
# Select BASE (now includes your custom MCP)
```

---

### Scenario 4: Existing CLAUDE.md

**Compare and merge:**

```bash
# 1. Backup existing
cp CLAUDE.md CLAUDE.md.backup

# 2. Compare
diff CLAUDE.md.backup claude-code-orchestrator-kit/CLAUDE.md

# 3. Options:
# A. Use kit's CLAUDE.md (recommended):
cp claude-code-orchestrator-kit/CLAUDE.md ./

# B. Merge manually (advanced):
# - Keep your project-specific rules
# - Add kit's Prime Directives (PD-1 to PD-7)
# - Add kit's Behavioral Contracts
```

---

## Post-Migration Checklist

### Verification

- [ ] `.claude/` directory exists with agents, commands, skills
- [ ] `CLAUDE.md` exists (Behavioral OS)
- [ ] `mcp/` directory has configuration files
- [ ] `.mcp.json` is active configuration (not git-ignored)
- [ ] `.env.local` configured with credentials (git-ignored)
- [ ] `switch-mcp.sh` executable (`chmod +x`)
- [ ] Custom agents copied to appropriate categories
- [ ] Git ignores sensitive files (.env.local, .tmp/)

### Functional Testing

```bash
# Test 1: Agents loaded
# (Ask Claude Code): "List health agents"
# Should see: bug-orchestrator, security-orchestrator, etc.

# Test 2: Commands work
/health-metrics
# Should generate metrics report

# Test 3: MCP servers active
# (Ask Claude Code): "Use Context7 to get React docs"
# Should return React documentation

# Test 4: Custom agents work
# (If you had custom agents): "Use my-custom-agent for..."
# Should invoke your custom agent
```

### Performance Check

```bash
# Verify configuration
./switch-mcp.sh
# Select 0 to see current config

# Check token usage
# Current config should be BASE (smallest footprint)
```

---

## Troubleshooting

### Issue: Agents Not Found

**Symptom**: Claude Code doesn't recognize health commands.

**Solution**:
```bash
# 1. Verify .claude/ structure
ls -la .claude/agents/health/orchestrators/
# Should see: bug-orchestrator.md, security-orchestrator.md, etc.

# 2. Restart Claude Code completely
# (Not just reload, full restart)

# 3. Check YAML frontmatter in agent files
head -10 .claude/agents/health/orchestrators/bug-orchestrator.md
# Should have valid YAML:
# ---
# name: bug-orchestrator
# description: ...
# model: sonnet
# color: blue
# ---
```

---

### Issue: MCP Servers Not Working

**Symptom**: Context7, Supabase MCPs show "not available".

**Solution**:
```bash
# 1. Verify .mcp.json copied
cat .mcp.json | jq .mcpServers

# 2. Check environment variables loaded
cat .env.local
# Variables should be present (no quotes)

# 3. Restart Claude Code
# Environment variables load on startup

# 4. Test specific MCP
# (Ask Claude Code): "Test Context7 MCP server"
```

---

### Issue: Custom Agents Broken

**Symptom**: Custom agents fail to run or give errors.

**Solution**:
```bash
# 1. Check agent location
# Custom agents should be in:
# .claude/agents/custom/workers/ or
# .claude/agents/{appropriate-category}/workers/

# 2. Update agent references
# Old: docs/ARCHITECTURE.md
# New: docs/Agents Ecosystem/ARCHITECTURE.md

# Old: .bug-plan.json
# New: .tmp/current/plans/.bug-plan.json

# 3. Check YAML frontmatter
# Must have: name, description, model, color

# 4. Test agent
# (Ask Claude Code): "Use {agent-name} for test"
```

---

### Issue: Git Shows Kit Files as Untracked

**Symptom**: `git status` shows `.claude/`, `docs/`, etc.

**Solution**:
```bash
# Option A: Commit kit files (recommended)
git add .claude/ docs/ CLAUDE.md mcp/ switch-mcp.sh
git commit -m "feat: Add Claude Code Orchestrator Kit"

# Option B: Add to .gitignore (not recommended)
# Kit files should be committed so team has access
```

---

### Issue: Conflicts with Existing Agents

**Symptom**: Kit agent has same name as custom agent.

**Solution**:
```bash
# 1. Rename custom agent
mv .claude/agents/custom/bug-hunter.md .claude/agents/custom/my-bug-hunter.md

# 2. Update YAML frontmatter
# Change: name: bug-hunter
# To: name: my-bug-hunter

# 3. Use renamed agent
# (Ask Claude Code): "Use my-bug-hunter for..."
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/health-check.yml
name: Health Check

on:
  pull_request:
  schedule:
    - cron: '0 0 * * 1'  # Weekly

jobs:
  health:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        uses: claude-code/setup@v1
        with:
          mcp-config: base  # Use BASE for CI

      - name: Run health checks
        run: |
          cp mcp/.mcp.base.json .mcp.json
          claude-code /health-bugs

      - name: Upload reports
        uses: actions/upload-artifact@v3
        with:
          name: health-reports
          path: .tmp/current/reports/
```

---

## Rollback Procedure

**If migration causes issues:**

```bash
# 1. Stop Claude Code

# 2. Restore backup
rm -rf .claude/
mv .claude.backup .claude/

rm CLAUDE.md
mv CLAUDE.md.backup CLAUDE.md

rm .mcp.json
mv .mcp.json.backup .mcp.json

# 3. Restart Claude Code

# 4. Verify system restored
# (Ask Claude Code): "List agents"
# Should see your original agents
```

---

## Next Steps

After successful migration:

1. **Run baseline health check**: `/health-bugs`, `/health-security`, `/health-deps`
2. **Review reports**: Understand current code health
3. **Create action plan**: Prioritize fixes based on reports
4. **Train team**: Share documentation, run demo session
5. **Integrate with workflow**: Add to code review, CI/CD

See:
- [TUTORIAL-CUSTOM-AGENTS.md](./TUTORIAL-CUSTOM-AGENTS.md) for creating agents
- [USE-CASES.md](./USE-CASES.md) for real-world examples
- [PERFORMANCE-OPTIMIZATION.md](./PERFORMANCE-OPTIMIZATION.md) for cost savings

---

**Document Version**: 1.0
**Last Updated**: 2025-01-11
**Maintained by**: [Igor Maslennikov](https://github.com/maslennikov-ig)
