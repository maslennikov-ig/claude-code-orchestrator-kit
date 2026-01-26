# Prompts

Ready-to-use prompts for setting up various features in your project. Copy, paste, and let Claude Code do the work.

## Available Prompts

| Prompt | Description | Prerequisites |
|--------|-------------|---------------|
| [setup-health-workflows.md](./setup-health-workflows.md) | Health workflows with Beads integration (`/health-bugs`, `/health-security`, etc.) | Node.js project, Git |
| [setup-error-logging.md](./setup-error-logging.md) | Complete error logging system with DB table, logger service, auto-mute rules | Database (Supabase/Postgres) |

## How to Use

1. **Copy the prompt** to your chat with Claude Code
2. **Answer any questions** Claude asks about your project
3. **Review the changes** before committing

## Health Workflows Quick Start

The easiest way to get started with health workflows:

```bash
# 1. Install Beads CLI
npm install -g @anthropic/beads-cli

# 2. Initialize Beads in your project
bd init

# 3. Ensure you have type-check and build scripts
# In package.json:
{
  "scripts": {
    "type-check": "tsc --noEmit",
    "build": "your-build-command"
  }
}

# 4. Run any health command in Claude Code
/health-bugs
```

See [setup-health-workflows.md](./setup-health-workflows.md) for full documentation.

## Contributing

Have a useful setup prompt? Create a PR with:
- Clear step-by-step instructions
- Code examples for different frameworks
- Verification steps

---

## Coming Soon

- `setup-realtime-dashboard.md` - Admin dashboard with real-time updates
- `setup-github-issues-workflow.md` - GitHub Issues processing with Beads
- `setup-blue-green-deploy.md` - Zero-downtime deployment setup
