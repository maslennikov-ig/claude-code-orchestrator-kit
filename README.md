# Claude Code Orchestrator Kit

> **Professional automation and orchestration system for Claude Code**

Complete toolkit with **39 AI agents**, **38 skills**, **21 slash commands**, **auto-optimized MCP**, **Beads issue tracking**, **ready-to-use prompts**, and **quality gates** for building production-ready projects with Claude Code.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/claude-code-orchestrator-kit.svg)](https://www.npmjs.com/package/claude-code-orchestrator-kit)
[![Agents](https://img.shields.io/badge/Agents-39-green.svg)](#agents-ecosystem)
[![Skills](https://img.shields.io/badge/Skills-39-blue.svg)](#skills-library)
[![Commands](https://img.shields.io/badge/Commands-21-orange.svg)](#slash-commands)

**[English](#overview)** | **[Русский](README.ru.md)**

---

## Table of Contents

- [Overview](#overview)
- [Key Innovations](#key-innovations)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Architecture](#architecture)
- [Agents Ecosystem](#agents-ecosystem)
- [Skills Library](#skills-library)
- [Slash Commands](#slash-commands)
- [MCP Configuration](#mcp-configuration)
- [Claude Code Settings](#claude-code-settings)
- [Prompts](#prompts)
- [Project Structure](#project-structure)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**Claude Code Orchestrator Kit** transforms Claude Code from a simple assistant into an intelligent orchestration system. Instead of doing everything directly, Claude Code acts as an orchestrator that delegates complex tasks to specialized sub-agents, preserving context and enabling indefinite work sessions.

### What You Get

| Category | Count | Description |
|----------|-------|-------------|
| **AI Agents** | 39 | Specialized workers for bugs, security, testing, database, frontend, DevOps |
| **Skills** | 39 | Reusable utilities for validation, reporting, automation, senior expertise |
| **Commands** | 21 | Health checks, SpecKit, Beads, process-logs, worktree, releases |
| **MCP Servers** | 6 | Auto-optimized: Context7, Sequential Thinking, Supabase, Playwright, shadcn, Serena |

### Key Benefits

- **Context Preservation**: Main session stays lean (~10-15K tokens vs 50K+ in standard usage)
- **Specialization**: Each agent is expert in its domain
- **Indefinite Work**: Can work on project indefinitely without context exhaustion
- **Quality Assurance**: Mandatory verification after every delegation
- **Senior Expertise**: Skills like `code-reviewer`, `senior-devops`, `senior-prompt-engineer`

---

## Key Innovations

### 1. Orchestrator Pattern

**The Core Paradigm**: Claude Code acts as orchestrator, delegating to specialized sub-agents.

```
┌─────────────────────────────────────────────────────────────────┐
│                     MAIN CLAUDE CODE                             │
│                   (Orchestrator Role)                            │
├─────────────────────────────────────────────────────────────────┤
│  1. GATHER CONTEXT    │  2. DELEGATE        │  3. VERIFY        │
│  - Read existing code │  - Invoke agent     │  - Read results   │
│  - Search patterns    │  - Provide context  │  - Run type-check │
│  - Check recent commits│  - Set criteria    │  - Accept/reject  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    SPECIALIZED AGENTS                            │
├──────────────┬──────────────┬──────────────┬───────────────────┤
│  bug-hunter  │  security-   │  database-   │  performance-     │
│  bug-fixer   │  scanner     │  architect   │  optimizer        │
│  dead-code-  │  vuln-fixer  │  api-builder │  accessibility-   │
│  hunter      │              │  supabase-   │  tester           │
│              │              │  auditor     │                   │
└──────────────┴──────────────┴──────────────┴───────────────────┘
```

### 2. Inline Skills (New Architecture)

**Evolution from Orchestrators**: We replaced heavy orchestrator agents with lightweight inline skills.

| Old Approach | New Approach |
|--------------|--------------|
| Separate orchestrator agent per workflow | Inline skill executed directly |
| ~1400 lines per workflow | ~150 lines per skill |
| 9+ orchestrator calls | 0 orchestrator calls |
| ~10,000+ tokens overhead | ~500 tokens |
| Context reload each call | Single session context |

**Example**: `/health-bugs` now uses `bug-health-inline` skill:
```
Detection → Validate → Fix by Priority → Verify → Repeat if needed
```

### 3. Senior-Level Skills

Professional-grade skills for complex tasks:

| Skill | Expertise |
|-------|-----------|
| `code-reviewer` | TypeScript, Python, Go, Swift, Kotlin code review |
| `senior-devops` | CI/CD, Docker, Kubernetes, Terraform, Cloud |
| `senior-prompt-engineer` | LLM optimization, RAG, agent design |
| `ux-researcher-designer` | User research, personas, journey mapping |
| `systematic-debugging` | Root cause analysis, debugging workflows |

### 4. Auto-Optimized MCP Configuration

**No manual switching required!** Claude Code automatically optimizes context usage:

- **Single `.mcp.json`** with all servers — no manual switching needed
- **Automatic deferred loading** via `ENABLE_TOOL_SEARCH=auto:5`
- **85% context reduction** for MCP tools (loaded on-demand via ToolSearch)
- **Transparent to user** — just works without configuration

### 5. SpecKit Integration

Specification-driven development workflow with Phase 0 Planning:
- Executor assignment (MAIN vs specialized agent)
- Parallel agent creation via meta-agent
- Atomicity: 1 Task = 1 Agent Invocation

### 6. Beads Issue Tracking (Optional)

[Beads](https://github.com/steveyegge/beads) by Steve Yegge — git-backed issue tracker for AI agents:
- **Persistent tasks**: Survives session restarts, tracked in git
- **Dependency graph**: `blocks`, `blocked-by`, `discovered-from`
- **Multi-session**: Work across multiple Claude sessions without losing context
- **8 workflow formulas**: `bigfeature`, `bugfix`, `hotfix`, `healthcheck`, etc.
- **Initialize**: Run `/beads-init` in your project

---

## Quick Start

### Option 1: npm Install

```bash
npm install -g claude-code-orchestrator-kit
cd your-project
claude-orchestrator  # Interactive setup
```

### Option 2: Clone Repository

```bash
git clone https://github.com/maslennikov-ig/claude-code-orchestrator-kit.git
cd claude-code-orchestrator-kit

# Configure environment (optional, for Supabase)
cp .env.example .env.local
# Edit .env.local with your credentials

# Restart Claude Code - ready!
```

### Option 3: Copy to Existing Project

```bash
# Copy orchestration system to your project
cp -r claude-code-orchestrator-kit/.claude /path/to/your/project/
cp claude-code-orchestrator-kit/.mcp.json /path/to/your/project/
cp claude-code-orchestrator-kit/CLAUDE.md /path/to/your/project/
```

---

## Installation

### Prerequisites

- **Claude Code** CLI installed
- **Node.js** 18+ (for MCP servers)
- **Git** (for version control features)

### Environment Variables

Create `.env.local` (git-ignored) with your credentials:

```bash
# Supabase (optional)
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_ACCESS_TOKEN=your-token

# Sequential Thinking (optional)
SEQUENTIAL_THINKING_KEY=your-smithery-key
SEQUENTIAL_THINKING_PROFILE=your-profile
```

### Verify Installation

```bash
# Check that .mcp.json and .claude/settings.json exist
ls -la .mcp.json .claude/settings.json

# Try a health command in Claude Code
/health-bugs
```

---

## Architecture

### Component Overview

```
┌────────────────────────────────────────────────────────────────┐
│                        CLAUDE.md                                │
│                  (Behavioral Operating System)                  │
│                                                                 │
│  Defines: Orchestration rules, delegation patterns, verification│
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                         AGENTS                                  │
│            (39 specialized workers)                             │
├────────────────────────────────────────────────────────────────┤
│  health/       development/   testing/      database/          │
│  ├─bug-hunter  ├─llm-service  ├─integration ├─database-arch   │
│  ├─bug-fixer   ├─typescript   ├─performance ├─api-builder     │
│  ├─security-   ├─code-review  ├─mobile      ├─supabase-audit  │
│  ├─dead-code   ├─utility-     ├─access-     │                  │
│  └─reuse-      └─skill-build  └─ibility     │                  │
│                                                                 │
│  infrastructure/  frontend/     meta/        research/         │
│  ├─deployment     ├─nextjs-ui   ├─meta-agent ├─problem-invest  │
│  ├─qdrant         ├─fullstack   └─skill-v2   └─research-spec   │
│  └─orchestration  └─visual-fx                                  │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                         SKILLS                                  │
│            (37 reusable utilities)                              │
├────────────────────────────────────────────────────────────────┤
│  Inline Orchestration:        Senior Expertise:                 │
│  ├─bug-health-inline          ├─code-reviewer                  │
│  ├─security-health-inline     ├─senior-devops                  │
│  ├─deps-health-inline         ├─senior-prompt-engineer         │
│  ├─cleanup-health-inline      ├─ux-researcher-designer         │
│  └─reuse-health-inline        └─systematic-debugging           │
│                                                                 │
│  Utilities:                   Creative:                         │
│  ├─validate-plan-file         ├─algorithmic-art                │
│  ├─run-quality-gate           ├─canvas-design                  │
│  ├─rollback-changes           ├─theme-factory                  │
│  ├─parse-git-status           └─artifacts-builder              │
│  └─generate-report-header                                       │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                        COMMANDS                                 │
│            (21 slash commands)                                  │
├────────────────────────────────────────────────────────────────┤
│  /health-bugs      /speckit.specify    /worktree              │
│  /health-security  /speckit.plan       /push                  │
│  /health-deps      /speckit.implement  /translate-doc          │
│  /health-cleanup   /speckit.clarify    /process-logs          │
│  /health-reuse     /speckit.constitution                       │
│  /health-metrics   /speckit.taskstoissues                      │
└────────────────────────────────────────────────────────────────┘
```

---

## Agents Ecosystem

### 39 Specialized Agents

#### Health (10 agents)
| Agent | Purpose |
|-------|---------|
| `bug-hunter` | Detect bugs, categorize by priority |
| `bug-fixer` | Fix bugs from reports |
| `security-scanner` | Find security vulnerabilities |
| `vulnerability-fixer` | Fix security issues |
| `dead-code-hunter` | Detect unused code |
| `dead-code-remover` | Remove dead code safely |
| `dependency-auditor` | Audit package dependencies |
| `dependency-updater` | Update dependencies safely |
| `reuse-hunter` | Find code duplication |
| `reuse-fixer` | Consolidate duplicated code |

#### Development (6 agents)
| Agent | Purpose |
|-------|---------|
| `llm-service-specialist` | LLM integration, prompts |
| `typescript-types-specialist` | Type definitions, generics |
| `cost-calculator-specialist` | Token/API cost estimation |
| `utility-builder` | Build utility services |
| `skill-builder-v2` | Create new skills |
| `code-reviewer` | Comprehensive code review |

#### Testing (6 agents)
| Agent | Purpose |
|-------|---------|
| `integration-tester` | Database, API, async tests |
| `test-writer` | Write unit/contract tests |
| `performance-optimizer` | Core Web Vitals, PageSpeed |
| `mobile-responsiveness-tester` | Mobile viewport testing |
| `mobile-fixes-implementer` | Fix mobile issues |
| `accessibility-tester` | WCAG compliance |

#### Database (3 agents)
| Agent | Purpose |
|-------|---------|
| `database-architect` | PostgreSQL schema design |
| `api-builder` | tRPC routers, auth middleware |
| `supabase-auditor` | RLS policies, security |

#### Infrastructure (5 agents)
| Agent | Purpose |
|-------|---------|
| `infrastructure-specialist` | Supabase, Qdrant, Redis |
| `qdrant-specialist` | Vector database operations |
| `quality-validator-specialist` | Quality gate validation |
| `orchestration-logic-specialist` | Workflow state machines |
| `deployment-engineer` | CI/CD, Docker, DevOps |

#### Frontend (3 agents)
| Agent | Purpose |
|-------|---------|
| `nextjs-ui-designer` | Modern UI/UX design |
| `fullstack-nextjs-specialist` | Full-stack Next.js |
| `visual-effects-creator` | Animations, visual effects |

#### Other (6 agents)
| Agent | Purpose |
|-------|---------|
| `meta-agent-v3` | Create new agents |
| `technical-writer` | Documentation |
| `problem-investigator` | Deep problem analysis |
| `research-specialist` | Technical research |
| `article-writer-multi-platform` | Multi-platform content |
| `lead-research-assistant` | Lead qualification |

---

## Skills Library

### 38 Reusable Skills

#### Inline Orchestration (5 skills)
Execute health workflows directly without spawning orchestrator agents. All skills include **Beads integration** for issue tracking.

| Skill | Invocation | Purpose | Version |
|-------|------------|---------|---------|
| `health-bugs` | `/health-bugs` | Bug detection & fixing with history enrichment | 3.1.0 |
| `security-health-inline` | `/health-security` | Security vulnerability scanning & fixing | 3.0.0 |
| `deps-health-inline` | `/health-deps` | Dependency audit & update | 3.0.0 |
| `cleanup-health-inline` | `/health-cleanup` | Dead code detection & removal | 3.0.0 |
| `reuse-health-inline` | `/health-reuse` | Code duplication consolidation | 3.0.0 |

#### Senior Expertise (6 skills)
Professional-grade domain expertise:

| Skill | Expertise |
|-------|-----------|
| `code-reviewer` | TypeScript, Python, Go, Swift, Kotlin review |
| `senior-devops` | CI/CD, containers, cloud, infrastructure |
| `senior-prompt-engineer` | LLM optimization, RAG, agents |
| `ux-researcher-designer` | User research, personas |
| `ui-design-system` | Design tokens, components |
| `systematic-debugging` | Root cause analysis |

#### Validation & Quality (6 skills)
| Skill | Purpose |
|-------|---------|
| `validate-plan-file` | JSON schema validation |
| `validate-report-file` | Report completeness |
| `run-quality-gate` | Type-check/build/tests |
| `calculate-priority-score` | Bug/task prioritization |
| `setup-knip` | Configure dead code detection |
| `rollback-changes` | Restore from changes log |

#### Reporting & Formatting (6 skills)
| Skill | Purpose |
|-------|---------|
| `generate-report-header` | Standardized report headers |
| `generate-changelog` | Changelog from commits |
| `format-markdown-table` | Well-formatted tables |
| `format-commit-message` | Conventional commits |
| `format-todo-list` | TodoWrite-compatible lists |
| `render-template` | Variable substitution |

#### Parsing & Extraction (4 skills)
| Skill | Purpose |
|-------|---------|
| `parse-git-status` | Parse git status output |
| `parse-package-json` | Extract version, deps |
| `parse-error-logs` | Parse build/test errors |
| `extract-version` | Semantic version parsing |

#### Creative & UI (6 skills)
| Skill | Purpose |
|-------|---------|
| `algorithmic-art` | Generative art with p5.js |
| `canvas-design` | Visual art in PNG/PDF |
| `theme-factory` | Theme styling for artifacts |
| `artifacts-builder` | Multi-component HTML artifacts |
| `webapp-testing` | Playwright testing |
| `frontend-aesthetics` | Distinctive UI design |

#### Automation Workflows (2 skills)
| Skill | Purpose | Version |
|-------|---------|---------|
| `process-logs` | Automated error log processing with Beads integration | 1.8.0 |
| `process-issues` | GitHub Issues processing with similar issue search | 1.1.0 |

#### Other (4 skills)
| Skill | Purpose |
|-------|---------|
| `git-commit-helper` | Commit message from diff |
| `changelog-generator` | User-facing changelogs |
| `content-research-writer` | Research-driven content |
| `lead-research-assistant` | Lead identification |

---

## Slash Commands

### 21 Commands

#### Health Monitoring (6 commands)

| Command | Purpose |
|---------|---------|
| `/health-bugs` | Bug detection and fixing workflow |
| `/health-security` | Security vulnerability scanning |
| `/health-deps` | Dependency audit and updates |
| `/health-cleanup` | Dead code detection and removal |
| `/health-reuse` | Code duplication elimination |
| `/health-metrics` | Monthly ecosystem health report |

**Example:**
```bash
/health-bugs
# Scans → Categorizes → Fixes by priority → Validates → Reports
```

#### SpecKit (9 commands)

| Command | Purpose |
|---------|---------|
| `/speckit.analyze` | Analyze requirements |
| `/speckit.specify` | Generate specifications |
| `/speckit.clarify` | Ask clarifying questions |
| `/speckit.plan` | Create implementation plan |
| `/speckit.implement` | Execute implementation |
| `/speckit.checklist` | Generate QA checklist |
| `/speckit.tasks` | Break into tasks |
| `/speckit.constitution` | Define project constitution |
| `/speckit.taskstoissues` | Convert tasks to GitHub issues |

#### Beads (2 commands)

| Command | Purpose |
|---------|---------|
| `/beads-init` | Initialize Beads in project |
| `/speckit.tobeads` | Import tasks.md to Beads |

#### Other (4 commands)

| Command | Purpose |
|---------|---------|
| `/process-logs` | Automated error log processing and fixing |
| `/push [patch\|minor\|major]` | Automated release with changelog |
| `/worktree` | Git worktree management |
| `/translate-doc` | Translate documentation (EN↔RU) |

---

## MCP Configuration

### Unified Auto-Optimized Setup

**No more manual switching!** The kit uses a single `.mcp.json` with automatic optimization.

#### How It Works

1. **Single config file** (`.mcp.json`) contains all MCP servers
2. **Auto-deferred loading** via `.claude/settings.json`:
   ```json
   {
     "env": { "ENABLE_TOOL_SEARCH": "auto:5" }
   }
   ```
3. **On-demand loading** — Claude loads tools only when needed via ToolSearch
4. **85% context savings** compared to loading all tools upfront

#### Included MCP Servers

| Server | Purpose | Tools |
|--------|---------|-------|
| **Context7** | Up-to-date library documentation | `resolve-library-id`, `query-docs` |
| **Sequential Thinking** | Structured reasoning for complex tasks | `sequentialthinking` |
| **Supabase** | Database operations, migrations, RLS | Tables, SQL, migrations, edge functions |
| **Playwright** | Browser automation & testing | Screenshots, navigation, form filling |
| **shadcn/ui** | UI component library integration | Registry search, component examples |
| **Serena** | Semantic code analysis (LSP) | Symbol search, references, refactoring |

#### Environment Variables

Set in `.env.local` for Supabase integration:
```bash
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_ACCESS_TOKEN=your-token
```

---

## Claude Code Settings

### `.claude/settings.json`

Project-level Claude Code configuration for enhanced workflow:

```json
{
  "plansDirectory": "./docs/plans",
  "env": {
    "ENABLE_TOOL_SEARCH": "auto:5"
  }
}
```

#### Settings Explained

| Setting | Value | Purpose |
|---------|-------|---------|
| `plansDirectory` | `./docs/plans` | Where Claude saves implementation plans when using Plan Mode |
| `ENABLE_TOOL_SEARCH` | `auto:5` | Auto-enables deferred MCP tool loading for servers with >5 tools |

#### Benefits

- **Plan Mode Integration**: Plans are saved to `docs/plans/` for version control and review
- **Automatic Context Optimization**: MCP tools load on-demand instead of upfront
- **No Manual Configuration**: Works transparently — just install and use

---

## Prompts

Ready-to-use prompts for setting up various features in your project. Copy, paste, and let Claude Code do the work.

| Prompt | Description |
|--------|-------------|
| [`setup-health-workflows.md`](prompts/setup-health-workflows.md) | Health workflows with Beads integration (`/health-bugs`, `/health-security`, etc.) |
| [`setup-error-logging.md`](prompts/setup-error-logging.md) | Complete error logging system with DB table, logger service, auto-mute rules |

### Quick Start: Health Workflows

```bash
# 1. Install Beads CLI
npm install -g @anthropic/beads-cli

# 2. Initialize in your project
bd init

# 3. Run in Claude Code
/health-bugs
```

**How to Use:**

1. Copy the prompt content to your chat with Claude Code
2. Answer any questions Claude asks about your project specifics
3. Review the generated code before committing

See [`prompts/README.md`](prompts/README.md) for full documentation.

---

## Project Structure

```
claude-code-orchestrator-kit/
├── .claude/
│   ├── agents/                 # 39 AI agents
│   │   ├── health/             # Bug, security, deps, cleanup
│   │   ├── development/        # LLM, TypeScript, utilities
│   │   ├── testing/            # Integration, performance, mobile
│   │   ├── database/           # Supabase, API, architecture
│   │   ├── infrastructure/     # Qdrant, deployment, orchestration
│   │   ├── frontend/           # Next.js, visual effects
│   │   ├── meta/               # Agent/skill creators
│   │   ├── research/           # Problem investigation
│   │   ├── documentation/      # Technical writing
│   │   ├── content/            # Article writing
│   │   └── business/           # Lead research
│   │
│   ├── skills/                 # 37 reusable skills
│   │   ├── bug-health-inline/  # Inline orchestration
│   │   ├── code-reviewer/      # Senior expertise
│   │   ├── validate-plan-file/ # Validation utilities
│   │   └── ...
│   │
│   ├── commands/               # 18 slash commands
│   │   ├── health-*.md         # Health monitoring
│   │   ├── speckit.*.md        # SpecKit workflow
│   │   └── ...
│   │
│   ├── schemas/                # JSON schemas
│   └── scripts/                # Quality gate scripts
│
├── mcp/                        # Legacy MCP configs (reference only)
│   └── ...
│
├── prompts/                    # Ready-to-use setup prompts
│   ├── README.md
│   └── setup-error-logging.md
│
├── docs/                       # Documentation
│   ├── FAQ.md
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL-CUSTOM-AGENTS.md
│   └── ...
│
├── .mcp.json                   # Unified MCP configuration
├── CLAUDE.md                   # Behavioral Operating System
└── package.json                # npm package config
```

---

## Usage Examples

### Example 1: Bug Fixing Workflow

```bash
# Run complete bug detection and fixing
/health-bugs

# What happens:
# 1. Pre-flight validation
# 2. Bug detection (bug-hunter agent)
# 3. Quality gate validation
# 4. Priority-based fixing (critical → low)
# 5. Quality gates after each priority
# 6. Verification scan
# 7. Final report
```

### Example 2: Code Review

```bash
# Invoke code-reviewer skill
/code-reviewer

# Provides:
# - Automated code analysis
# - Best practices checking
# - Security scanning
# - Review checklist
```

### Example 3: Release Automation

```bash
# Auto-detect version bump
/push

# Or specify type
/push minor

# Actions:
# 1. Analyze commits since last release
# 2. Bump version in package.json
# 3. Generate changelog entry
# 4. Create git commit + tag
# 5. Push to remote
```

### Example 4: Parallel Feature Development

```bash
# Create worktrees
/worktree create feature/new-auth
/worktree create feature/new-ui

# Work in parallel
cd .worktrees/feature-new-auth
# ... changes ...

# Cleanup when done
/worktree cleanup
```

---

## Best Practices

### 1. Use Auto-Optimized MCP
The kit automatically optimizes context usage — no configuration needed:
- MCP tools load on-demand via ToolSearch
- ~85% context reduction compared to loading all tools upfront

### 2. Run Health Checks Weekly
```bash
/health-bugs      # Monday
/health-security  # Tuesday
/health-deps      # Wednesday
/health-cleanup   # Thursday
/health-metrics   # Monthly
```

### 3. Use Library-First Approach
Before writing code >20 lines, search for existing libraries:
- Check npm/PyPI for packages with >1k weekly downloads
- Evaluate maintenance status and types support
- Use library if it covers >70% of functionality

### 4. Follow Orchestration Rules
1. **GATHER CONTEXT FIRST** - Read code, search patterns
2. **DELEGATE TO SUBAGENTS** - Provide complete context
3. **VERIFY RESULTS** - Never skip verification
4. **ACCEPT/REJECT LOOP** - Re-delegate if needed

### 5. Keep Credentials Secure
```bash
# Never commit .env.local
echo ".env.local" >> .gitignore
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [FAQ](docs/FAQ.md) | Frequently asked questions |
| [Architecture](docs/ARCHITECTURE.md) | System design diagrams |
| [Tutorial: Custom Agents](docs/TUTORIAL-CUSTOM-AGENTS.md) | Create your own agents |
| [Use Cases](docs/USE-CASES.md) | Real-world examples |
| [Performance](docs/PERFORMANCE-OPTIMIZATION.md) | Token optimization |
| [Migration Guide](docs/MIGRATION-GUIDE.md) | Add to existing projects |
| [Commands Guide](docs/COMMANDS-GUIDE.md) | Detailed command reference |

---

## Contributing

### Adding New Agents

1. Create file in `.claude/agents/{category}/workers/`
2. Follow agent template structure
3. Add to this README

### Adding New Skills

1. Create directory `.claude/skills/{skill-name}/`
2. Add `SKILL.md` following format
3. Add to this README

### Adding MCP Servers

1. Add server to `.mcp.json`
2. Document in README under MCP Configuration section

---

## Attribution

### SpecKit by GitHub
Commands `/speckit.*` adapted from [GitHub's SpecKit](https://github.com/github/spec-kit).
- **License**: MIT License
- **Copyright**: GitHub, Inc.

### Beads by Steve Yegge
Beads issue tracking integration adapted from [Steve Yegge's Beads](https://github.com/steveyegge/beads).
- **Description**: Distributed, git-backed graph issue tracker for AI agents
- **License**: MIT License
- **Copyright**: Steve Yegge
- **Commands**: `/beads-init`, `/speckit.tobeads`
- **Templates**: `.beads-templates/` directory with 8 workflow formulas

---

## Acknowledgments

Built with:
- **[Claude Code](https://claude.com/claude-code)** by Anthropic
- **[Context7](https://upstash.com/context7)** by Upstash
- **[Supabase MCP](https://github.com/supabase/mcp-server-supabase)**
- **[Smithery Sequential Thinking](https://smithery.ai/)**
- **[Playwright](https://playwright.dev/)**
- **[shadcn/ui](https://ui.shadcn.com/)**

---

## Stats

- **39** AI Agents
- **39** Reusable Skills
- **21** Slash Commands
- **6** MCP Servers (auto-optimized)
- **v1.4.19** Current Version

---

## Author

**Igor Maslennikov**
- GitHub: [@maslennikov-ig](https://github.com/maslennikov-ig)
- Website: [aidevteam.ru](https://aidevteam.ru/)

---

## License

MIT License - see [LICENSE](LICENSE) file.

---

**Star this repo if you find it useful!**
