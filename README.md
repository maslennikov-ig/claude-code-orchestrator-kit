# 🎼 Claude Code Orchestrator Kit

> **Professional automation and orchestration system for Claude Code**

Complete toolkit with **33+ AI agents**, **quality gates**, **health monitoring**, and **workflow automation** for building robust, production-ready projects with Claude Code.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![MCP Servers](https://img.shields.io/badge/MCP-6%20Configs-blue.svg)](#mcp-configurations)
[![Agents](https://img.shields.io/badge/Agents-33%2B-green.svg)](#agents-ecosystem)
[![Commands](https://img.shields.io/badge/Commands-19%2B-orange.svg)](#slash-commands)
[![Author](https://img.shields.io/badge/Author-maslennikov--ig-blue.svg)](https://github.com/maslennikov-ig)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Key Innovations](#key-innovations)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Documentation](#documentation)
- [MCP Server Configurations](#mcp-server-configurations)
- [Project Structure](#project-structure)
- [Slash Commands](#slash-commands)
- [Agents Ecosystem](#agents-ecosystem)
- [Skills Library](#skills-library)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

**Claude Code Orchestrator Kit** is a comprehensive automation framework designed to supercharge your development workflow with Claude Code. It provides:

- **🤖 33+ Specialized AI Agents** — Orchestrators and workers for bugs, security, dependencies, dead code cleanup, and more
- **⚡ MCP Server Management** — 6 pre-configured MCP setups for different use cases (600-5000 tokens)
- **🔧 20+ Slash Commands** — Health checks, SpecKit, worktree management, releases
- **📊 Quality Gates** — Automated type-checking, builds, tests, coverage, security audits
- **🎯 Skills Library** — 15+ reusable utilities for validation, reporting, and automation
- **📈 Health Monitoring** — Track agent performance, success rates, and ecosystem health

---

## ✨ Features

### 🤖 **AI Agents Ecosystem**

- **Health Orchestrators** — Complete workflows for bugs, security, dependencies, dead code
- **Development Workers** — LLM services, TypeScript types, cost calculation specialists
- **Testing Workers** — Integration tests, performance optimization, mobile responsiveness
- **Database Workers** — Supabase audits, API builders, database architecture
- **Infrastructure Workers** — Qdrant, quality validators, orchestration logic
- **Meta Workers** — Agent creators, skill builders

### ⚙️ **MCP Server Configurations**

Switch between 6 optimized MCP configurations based on your needs:

| Configuration | Servers | Token Usage | Use Case |
|---------------|---------|-------------|----------|
| **BASE** | Context7 + Sequential Thinking | ~600 | Minimal, everyday use |
| **SUPABASE** | Base + Supabase (single) | ~2500 | Database work |
| **SUPABASE-FULL** | Base + Supabase (dual) | ~3000 | Multi-project database |
| **N8N** | Base + n8n automation | ~2500 | Workflow automation |
| **FRONTEND** | Base + Playwright + ShadCN | ~2000 | UI/UX development |
| **FULL** | All servers enabled | ~5000 | Maximum capabilities |

### 🚀 **Slash Commands**

- **Health Checks** — `/health-bugs`, `/health-security`, `/health-deps`, `/health-cleanup`, `/health-metrics`
- **SpecKit** — `/speckit.analyze`, `/speckit.specify`, `/speckit.implement`, `/speckit.checklist`
- **Worktree Management** — `/worktree-create`, `/worktree-list`, `/worktree-cleanup`, `/worktree-remove`
- **Release Management** — `/push` (automated version bumping and changelog)
- **Translation** — `/translate-doc` (English ↔ Russian)

### 📊 **Quality Gates**

Automated validation scripts:
- **Bundle Size Check** — Ensure production bundles stay within limits
- **Security Audit** — Scan for high/critical npm vulnerabilities
- **Code Coverage** — Validate test coverage meets thresholds

### 🎯 **Skills Library**

Reusable utilities for:
- Plan validation, report generation, changelog creation
- Git operations, error parsing, template rendering
- Quality gates execution, rollback management
- Priority scoring, version extraction

---

## 🔑 Key Innovations

### 🎯 **Orchestrator Pattern**

**The Paradigm Shift**: Transform Claude Code from doing everything directly to acting as an orchestrator that delegates complex tasks to specialized sub-agents.

**Why It Matters**:
- **Context Preservation**: Main Claude Code stays lean (~10-15K tokens vs 50K+ in standard usage)
- **Specialization**: Each sub-agent is expert in its domain (bug fixing, security scanning, database architecture)
- **Quality Assurance**: Mandatory verification after every delegation (read files + run type-check)
- **Indefinite Work**: Can work on project indefinitely without context exhaustion

**Core Rules** (from `CLAUDE.md`):
1. **GATHER FULL CONTEXT FIRST** - Read code, search patterns, check commits before delegation
2. **DELEGATE TO SUBAGENTS** - Provide complete context + validation criteria
3. **VERIFY RESULTS** - Never skip verification (read modified files, run type-check)
4. **ACCEPT/REJECT LOOP** - Re-delegate with corrections if verification fails
5. **PER-TASK COMMITS** - Run `/push patch` after each completed task

### 📋 **SpecKit Enhancement: Phase 0 Planning**

**SpecKit** (by GitHub) provides structured development workflow. We enhanced it with **Phase 0: Planning**.

**Phase 0 Responsibilities**:
1. **Executor Assignment**:
   - `[EXECUTOR: MAIN]` - Only trivial tasks (1-2 line fixes, simple imports)
   - `[EXECUTOR: existing-agent]` - If 100% match with existing sub-agent
   - `[EXECUTOR: FUTURE-agent-name]` - If no match (agent needs creation)

2. **Meta-Agent Creation**:
   - Launch N `meta-agent-v3` calls in **single message** for parallel agent creation
   - **Atomicity Rule**: 1 Task = 1 Agent Invocation
   - After creation: Ask user to restart Claude Code

3. **Research Resolution**:
   - Simple research: Agent solves with available tools
   - Complex research: Create prompt in `research/` directory

**Why It Matters**: Ensures all necessary agents exist before implementation starts, enables parallel task execution, prevents context overflow.

### 🤖 **Meta-Agent: The Agent Factory**

**meta-agent-v3** creates new specialized agents in 2-3 minutes following project patterns:
- **Workers** - Execute tasks from plan files (5-phase structure)
- **Orchestrators** - Coordinate multi-phase workflows (return control pattern)
- **Simple Agents** - Standalone tools

**How It Works**:
1. Loads architecture docs (`ARCHITECTURE.md` + `CLAUDE.md`)
2. Determines agent type and requirements
3. Generates YAML frontmatter + structure + validation + error handling
4. Writes to appropriate location
5. Validates against project patterns

### 🔄 **Return Control Pattern**

**Orchestrators** coordinate workflows without invoking workers directly:

```
Orchestrator → Create plan file → Signal readiness → EXIT
↓
Main Session → Invoke worker via Task tool
↓
Worker → Execute → Validate → Report → EXIT
↓
Orchestrator → Resume → Verify → Next phase
```

**Why Not Task Tool?**: Using Task tool would create nested contexts, defeating isolation purpose.

### ⚙️ **MCP Dynamic Switching**

**Problem**: Each MCP server consumes 500-1500 tokens from context budget.

**Solution**: `switch-mcp.sh` script dynamically switches between 6 configurations:
- **BASE** (~600 tokens): Context7 + Sequential Thinking (daily use)
- **SUPABASE** (~2500): + Supabase (database work)
- **FRONTEND** (~2000): + Playwright + ShadCN (UI work)
- **FULL** (~5000): All servers (when needed)

**Benefit**: Save 500-4500 context tokens by loading only what you need.

### 🌳 **Worktree + VS Code Integration**

**Parallel Feature Development**:
1. Create worktrees for different features: `/worktree-create feature/new-auth`
2. Add `.worktrees/*` to VS Code workspace folders (see `.claude/settings.local.json.example`)
3. Switch between features via folder selector
4. Run multiple Claude Code sessions in parallel

**Benefit**: 3-5 features in parallel, no context pollution, isolated testing.

### 🔔 **Webhook Integration**

**Task Completion Notifications** (`.claude/settings.local.json.example`):
```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "notify-send 'Claude Code' 'Task completed!'"
      }
    ]
  }
}
```

**Use Cases**: Slack notifications, system alerts, Telegram bots, log files.

**Benefit**: Start task, switch to other project, get notified when done.

### 🎯 **Skills vs Agents**

**Skills** (15+): Reusable utilities (<100 lines), stateless, invoked via `Skill` tool
- Examples: `run-quality-gate`, `validate-plan-file`, `generate-report-header`
- No context isolation, runs in caller's context

**Agents** (33+): Stateful workflows, context-isolated, invoked via `Task` tool
- Examples: `bug-hunter`, `security-scanner`, `database-architect`
- Full context isolation, multi-step processes

### 📐 **Non-Traditional CLAUDE.md**

**Standard Practice**: Store entire project history in `CLAUDE.md`
- Problem: Wastes context tokens on historical data

**Our Innovation**: `CLAUDE.md` as **Behavioral Operating System**
- Contains ONLY orchestration rules (no project history)
- Defines how to gather context BEFORE delegation
- Specifies verification rules AFTER delegation
- Forces context preservation

**Result**: Main Claude Code stays lean, all context gathered on-demand.

---

## 🚀 Quick Start

```bash
# 1. Clone or download this repository
git clone https://github.com/maslennikov-ig/claude-code-orchestrator-kit.git
cd claude-code-orchestrator-kit

# 2. Set up environment variables
cp .env.example .env.local
# Edit .env.local with your credentials

# 3. Choose MCP configuration
./switch-mcp.sh
# Select option 1-6 based on your needs

# 4. Restart Claude Code
# Your orchestration system is ready!
```

---

## 📦 Installation

### Prerequisites

- **Claude Code** installed
- **Node.js** 18+ (for MCP servers)
- **Docker** (optional, for n8n MCP server)
- **Git** (for version control features)

### Setup Steps

#### 1️⃣ **Copy to Your Project**

```bash
# Option A: Copy entire .claude directory to your project
cp -r claude-code-orchestrator-kit/.claude /path/to/your/project/

# Option B: Clone and use as template
git clone https://github.com/maslennikov-ig/claude-code-orchestrator-kit.git my-project
cd my-project
rm -rf .git
git init
```

#### 2️⃣ **Configure Environment Variables**

```bash
# Copy example to local
cp .env.example .env.local

# Edit with your credentials
# Required for Supabase:
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_ACCESS_TOKEN=your-token
SUPABASE_DB_PASSWORD=your-password

# Required for Sequential Thinking:
SEQUENTIAL_THINKING_KEY=your-smithery-key
SEQUENTIAL_THINKING_PROFILE=your-profile

# Optional for n8n:
N8N_API_URL=https://your-n8n.com
N8N_API_KEY=your-n8n-key
```

**Important:** Never commit `.env.local` to git! It's already in `.gitignore`.

#### 3️⃣ **Select MCP Configuration**

```bash
./switch-mcp.sh
```

Choose configuration based on your workflow:
- **Option 1** — BASE (minimal, ~600 tokens)
- **Option 2** — SUPABASE (database work)
- **Option 3** — SUPABASE-FULL (multi-project)
- **Option 4** — N8N (automation workflows)
- **Option 5** — FRONTEND (UI/UX development)
- **Option 6** — FULL (all features)

#### 4️⃣ **Restart Claude Code**

After switching MCP config, restart Claude Code to apply changes.

#### 5️⃣ **Configure Local Settings (Optional)**

```bash
# Copy settings example to local
cp .claude/settings.local.json.example .claude/settings.local.json

# Edit with your preferences
# - Choose which MCP servers to enable
# - Configure hooks for task completion
# - Customize for your workflow
```

#### 6️⃣ **Verify Installation**

```bash
# Check current MCP config
./switch-mcp.sh
# Select option 0 to see active servers

# Try a health command in Claude Code
/health-bugs
```

---

## 📚 Documentation

### Comprehensive Guides

| Document | Description |
|----------|-------------|
| **[FAQ](docs/FAQ.md)** | Frequently asked questions about agents, MCP configs, and workflows |
| **[Architecture](docs/ARCHITECTURE.md)** | System design with Mermaid diagrams and workflow patterns |
| **[Tutorial: Custom Agents](docs/TUTORIAL-CUSTOM-AGENTS.md)** | Step-by-step guide to creating workers, orchestrators, and skills |
| **[Use Cases](docs/USE-CASES.md)** | Real-world case studies with metrics and lessons learned |
| **[Performance Optimization](docs/PERFORMANCE-OPTIMIZATION.md)** | Token usage optimization and cost reduction strategies |
| **[Migration Guide](docs/MIGRATION-GUIDE.md)** | Add Orchestrator Kit to existing projects |
| **[Roadmap](docs/ROADMAP.md)** | Future plans and community-driven feature requests |

### Deep Dive Documentation

Located in `docs/Agents Ecosystem/`:

- **[AGENT-ORCHESTRATION.md](docs/Agents%20Ecosystem/AGENT-ORCHESTRATION.md)** — Working with orchestrators
- **[QUALITY-GATES-SPECIFICATION.md](docs/Agents%20Ecosystem/QUALITY-GATES-SPECIFICATION.md)** — Quality gates specification
- **[REPORT-TEMPLATE-STANDARD.md](docs/Agents%20Ecosystem/REPORT-TEMPLATE-STANDARD.md)** — Standard report format for workers
- **[spec-kit-comprehensive-updates.md](docs/Agents%20Ecosystem/spec-kit-comprehensive-updates.md)** — SpecKit customization guide

### Quick Links

- **New to the kit?** Start with [Quick Start](#quick-start) → [Tutorial](docs/TUTORIAL-CUSTOM-AGENTS.md)
- **Want examples?** See [Use Cases](docs/USE-CASES.md) and [Usage Examples](#usage-examples)
- **Need help?** Check [FAQ](docs/FAQ.md) → [Troubleshooting](#troubleshooting)
- **Optimizing costs?** Read [Performance Optimization](docs/PERFORMANCE-OPTIMIZATION.md)
- **Migrating?** Follow [Migration Guide](docs/MIGRATION-GUIDE.md)

---

## 🔌 MCP Server Configurations

All MCP configurations are stored in `./mcp/` directory.

### Available Configurations

#### **BASE** (`mcp/.mcp.base.json`)
```json
{
  "mcpServers": {
    "context7": { ... },              // Library documentation
    "server-sequential-thinking": { ... }  // Enhanced reasoning
  }
}
```
**Use for:** Daily development, minimal token usage

---

#### **SUPABASE** (`mcp/.mcp.supabase-only.json`)
```json
{
  "mcpServers": {
    "context7": { ... },
    "server-sequential-thinking": { ... },
    "supabase": { ... }               // Main Supabase project
  }
}
```
**Use for:** Database design, RLS policies, SQL queries

---

#### **FULL** (`mcp/.mcp.full.json`)
```json
{
  "mcpServers": {
    "context7": { ... },
    "server-sequential-thinking": { ... },
    "supabase": { ... },
    "supabase-legacy": { ... },       // Secondary project
    "n8n-workflows": { ... },         // Workflow automation
    "n8n-mcp": { ... },               // n8n server control
    "playwright": { ... },            // Browser automation
    "shadcn": { ... }                 // UI components
  }
}
```
**Use for:** Full-featured development, maximum capabilities

---

### Switching Configurations

```bash
# Interactive menu
./switch-mcp.sh

# Or manually
cp mcp/.mcp.base.json .mcp.json
```

**Remember:** Restart Claude Code after switching!

---

## 📁 Project Structure

```
claude-code-orchestrator-kit/
│
├── 📂 .claude/                       # Main orchestration system
│   ├── agents/                       # 33+ AI agents
│   │   ├── health/                   # Bug, security, deps, cleanup orchestrators
│   │   │   ├── orchestrators/        # Multi-phase workflow coordinators
│   │   │   └── workers/              # Specialized execution agents
│   │   ├── development/              # LLM, TypeScript, cost specialists
│   │   ├── testing/                  # Integration, performance, mobile tests
│   │   ├── database/                 # Supabase, API builders
│   │   ├── infrastructure/           # Qdrant, quality validators
│   │   ├── frontend/                 # UI/UX specialists
│   │   ├── documentation/            # Technical writers
│   │   ├── research/                 # Deep-dive investigators
│   │   └── meta/                     # Agent and skill creators
│   │
│   ├── commands/                     # 19+ slash commands
│   │   ├── health-*.md               # Health monitoring workflows
│   │   ├── speckit.*.md              # Specification toolkit
│   │   ├── worktree-*.md             # Git worktree management
│   │   ├── push.md                   # Release automation
│   │   └── translate-doc.md          # Documentation translation
│   │
│   ├── skills/                       # 15+ reusable utilities
│   │   ├── validate-plan-file/       # Schema validation
│   │   ├── run-quality-gate/         # Automated checks
│   │   ├── rollback-changes/         # Restore files
│   │   ├── generate-report-header/   # Standardized reports
│   │   └── ...
│   │
│   ├── schemas/                      # JSON schemas for validation
│   │   ├── base-plan.schema.json
│   │   ├── bug-plan.schema.json
│   │   ├── security-plan.schema.json
│   │   └── ...
│   │
│   └── scripts/                      # Automation scripts
│       ├── release.sh                # Version bumping
│       └── gates/                    # Quality gate checks
│           ├── check-bundle-size.sh
│           ├── check-security.sh
│           └── check-coverage.sh
│
├── 📂 mcp/                           # MCP server configurations
│   ├── .mcp.base.json                # Minimal (~600 tokens)
│   ├── .mcp.supabase-only.json       # Database work (~2500)
│   ├── .mcp.supabase-full.json       # Multi-project (~3000)
│   ├── .mcp.n8n.json                 # Automation (~2500)
│   ├── .mcp.frontend.json            # UI/UX (~2000)
│   └── .mcp.full.json                # All servers (~5000)
│
├── 📂 .github/                       # GitHub Actions (optional)
│   └── workflows/
│
├── 🔧 Configuration Files
│   ├── .env.example                  # Environment template
│   ├── .env.local                    # Your credentials (git-ignored)
│   ├── .gitignore                    # Security exclusions
│   ├── .mcp.json                     # Active MCP config
│   └── CLAUDE.md                     # Behavioral Operating System
│
└── 📜 Scripts
    ├── switch-mcp.sh                 # MCP configuration switcher
    └── README.md                     # This file
```

---

## 🎯 Slash Commands

### Health Monitoring

#### `/health-bugs`
Complete bug detection and fixing workflow.

**What it does:**
- Scans entire codebase for bugs
- Categorizes by priority (critical → high → medium → low)
- Fixes bugs stage by stage
- Runs quality gates after each stage
- Verification scan and iterative refinement

**Usage:**
```
/health-bugs
```

**Output:** `bug-hunting-report.md`, `bug-fixes-implemented.md`

---

#### `/health-security`
Security vulnerability detection and remediation.

**Checks for:**
- SQL injection vulnerabilities
- XSS attack vectors
- Authentication/authorization issues
- RLS policy gaps
- Hardcoded secrets

**Usage:**
```
/health-security
```

---

#### `/health-deps`
Dependency audit and safe updates.

**Features:**
- Detects outdated packages
- Finds security vulnerabilities
- Identifies unused dependencies
- One-at-a-time update strategy
- Validation and rollback support

**Usage:**
```
/health-deps
```

---

#### `/health-cleanup`
Dead code detection and removal.

**Finds:**
- Unused imports
- Commented code blocks
- Unreachable code paths
- Debug artifacts (console.log, debugger)
- Unused variables/functions

**Usage:**
```
/health-cleanup
```

---

#### `/health-metrics`
Monthly ecosystem health reports.

**Analyzes:**
- Agent performance and success rates
- Quality gate pass rates
- Context7 usage and effectiveness
- Complexity distribution
- Behavioral OS health

**Usage:**
```
# Current month
/health-metrics

# Specific month
/health-metrics 2025-10

# Previous month
/health-metrics last-month
```

**Output:** `docs/reports/metrics/YYYY-MM-ecosystem-health.md`

---

### SpecKit Commands

Specification-driven development toolkit.

| Command | Purpose |
|---------|---------|
| `/speckit.analyze` | Analyze requirements and extract key points |
| `/speckit.specify` | Generate detailed specifications |
| `/speckit.clarify` | Ask clarifying questions |
| `/speckit.plan` | Create implementation plan |
| `/speckit.implement` | Execute implementation |
| `/speckit.checklist` | Generate QA checklist |
| `/speckit.tasks` | Break into actionable tasks |
| `/speckit.constitution` | Define project constitution |

---

### Worktree Management

Git worktree automation for parallel work.

| Command | Purpose |
|---------|---------|
| `/worktree-create` | Create new worktree |
| `/worktree-list` | List all worktrees |
| `/worktree-cleanup` | Clean up merged worktrees |
| `/worktree-remove` | Remove specific worktree |

---

### Other Commands

#### `/push [patch|minor|major]`
Automated release management.

**Features:**
- Analyzes commits since last release
- Auto-detects version bump type
- Updates `package.json`
- Generates changelog entry
- Creates git tag
- Pushes to remote

**Usage:**
```
/push patch   # 1.0.0 → 1.0.1
/push minor   # 1.0.0 → 1.1.0
/push major   # 1.0.0 → 2.0.0
```

---

#### `/translate-doc`
Translate documentation between English and Russian.

**Usage:**
```
/translate-doc path/to/doc.md
```

---

## 🤖 Agents Ecosystem

### Architecture

**Orchestrators** → Plan workflows, create tasks, validate outputs, manage iterations
**Workers** → Execute specific tasks, generate reports, return control
**Skills** → Reusable utilities for validation, reporting, automation

### Health Orchestrators

#### `bug-orchestrator`
Manages complete bug fixing workflow.

**Phases:**
1. Pre-flight validation
2. Bug detection (via bug-hunter)
3. Quality gate 1 (validation)
4. Staged fixing by priority
5. Quality gates per priority
6. Verification scan
7. Iterative refinement (up to 3 cycles)
8. Final summary

**Key Features:**
- Priority-based fixing (critical → low)
- Quality gates (type-check, build, tests)
- Rollback on failure
- Iteration tracking
- Comprehensive reporting

---

#### `security-orchestrator`
Security vulnerability workflow.

**Similar to bug-orchestrator but for:**
- Security vulnerabilities
- Authentication issues
- Authorization bypasses
- Data exposure risks
- Secrets management

---

#### `dependency-orchestrator`
Safe dependency update workflow.

**Features:**
- Audit existing dependencies
- One-at-a-time update strategy
- Validation after each update
- Rollback on failure
- Lock file management

---

#### `dead-code-orchestrator`
Dead code cleanup workflow.

**Targets:**
- Unused imports
- Commented code
- Unreachable paths
- Debug leftovers
- Orphaned functions

---

### Worker Agents

#### Development
- **llm-service-specialist** — LLM integration, prompt engineering
- **typescript-types-specialist** — Type definitions, generics
- **cost-calculator-specialist** — Token usage, API cost estimation

#### Testing
- **integration-tester** — Database, API, async job tests
- **performance-optimizer** — Core Web Vitals, PageSpeed
- **mobile-responsiveness-tester** — Viewport testing, mobile UX
- **accessibility-tester** — WCAG compliance, screen readers

#### Database
- **database-architect** — PostgreSQL schema design, migrations
- **api-builder** — tRPC routers, auth middleware
- **supabase-auditor** — RLS policies, security validation

#### Infrastructure
- **infrastructure-specialist** — Supabase, Qdrant, Redis, BullMQ setup
- **qdrant-specialist** — Vector database operations
- **quality-validator-specialist** — Quality gate validation

#### Meta
- **skill-builder-v2** — Create new skills following SKILL.md format
- **agent-creator** — Generate new agents with proper structure

---

## 🎯 Skills Library

Reusable utilities accessible via `Skill` tool.

### Validation Skills

| Skill | Purpose |
|-------|---------|
| `validate-plan-file` | Verify plan JSON schema |
| `validate-report-file` | Check report completeness |
| `validate-context7-availability` | Verify Context7 MCP server status |

### Quality Skills

| Skill | Purpose |
|-------|---------|
| `run-quality-gate` | Execute type-check/build/tests |
| `check-infinite-loop` | Detect agent invocation loops |
| `calculate-complexity-score` | Analyze task complexity (0-10) |
| `calculate-priority-score` | Score bugs/tasks by severity |

### Reporting Skills

| Skill | Purpose |
|-------|---------|
| `generate-report-header` | Create standardized report headers |
| `format-markdown-table` | Generate well-formatted tables |
| `format-todo-list` | Create TodoWrite-compatible lists |
| `generate-changelog` | Generate changelog from commits |

### Utility Skills

| Skill | Purpose |
|-------|---------|
| `parse-git-status` | Parse git status into structured data |
| `parse-package-json` | Extract version, dependencies |
| `parse-error-logs` | Parse build/test errors |
| `extract-version` | Parse semantic version strings |
| `format-commit-message` | Generate conventional commits |
| `render-template` | Variable substitution in templates |
| `rollback-changes` | Restore files from changes log |

---

## 💡 Usage Examples

### Example 1: Complete Bug Fixing Workflow

```bash
# 1. Run bug detection and fixing
/health-bugs

# Agent workflow:
# - Pre-flight validation
# - Scans codebase (bug-hunter)
# - Finds 45 bugs (12 critical, 18 high, 10 medium, 5 low)
# - Fixes critical bugs first
# - Runs type-check ✅, build ✅, tests ✅
# - Fixes high priority bugs
# - Quality gates ✅
# - Verification scan
# - Final report generated

# 2. Review results
cat bug-hunting-report.md
cat bug-fixes-implemented.md

# 3. Review monthly metrics
/health-metrics
```

---

### Example 2: Switching MCP for Frontend Work

```bash
# Switch to frontend config (Playwright + ShadCN)
./switch-mcp.sh
# Select option 5

# Restart Claude Code

# Now you have access to:
# - Playwright for browser automation
# - ShadCN for UI component generation
# - Context7 for library docs
# - Sequential Thinking for complex reasoning
```

---

### Example 3: Worktree Workflow

```bash
# Create worktree for feature development
/worktree-create feature/new-auth-flow

# Work in parallel worktree
cd .worktrees/feature-new-auth-flow
# ... make changes ...

# List all worktrees
/worktree-list

# Cleanup merged worktrees
/worktree-cleanup
```

---

### Example 4: Release Automation

```bash
# Auto-detect version bump and release
/push

# Or specify version bump type
/push minor

# What happens:
# 1. Analyzes commits since last release
# 2. Detects features, fixes, breaking changes
# 3. Bumps version in package.json
# 4. Generates changelog entry
# 5. Creates git commit + tag
# 6. Pushes to remote
```

---

## ⚙️ Configuration

### Environment Variables

All sensitive data is stored in `.env.local` (git-ignored).

**Required for Supabase MCP:**
```bash
SUPABASE_PROJECT_REF=abc123xyz
SUPABASE_ACCESS_TOKEN=sbp_yourtokenhere
SUPABASE_DB_PASSWORD=yourpassword
```

**Required for Sequential Thinking:**
```bash
SEQUENTIAL_THINKING_KEY=your-smithery-key
SEQUENTIAL_THINKING_PROFILE=your-profile-name
```

**Optional for n8n:**
```bash
N8N_API_URL=https://your-n8n.com
N8N_API_KEY=your-api-key
```

### MCP Configuration Template

MCP configs use environment variable interpolation:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest", "--project-ref=${SUPABASE_PROJECT_REF}"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}"
      }
    }
  }
}
```

Variables are automatically resolved from `.env.local`.

---

## 📚 Best Practices

### 1. Start with BASE Configuration

Use minimal MCP config for daily work to conserve tokens:

```bash
./switch-mcp.sh
# Select option 1 (BASE)
```

Switch to specialized configs only when needed.

---

### 2. Run Health Checks Weekly

```bash
# Monday: Bug scan
/health-bugs

# Tuesday: Security audit
/health-security

# Wednesday: Dependency check
/health-deps

# Thursday: Dead code cleanup
/health-cleanup

# End of month: Metrics review
/health-metrics
```

---

### 3. Use Quality Gates

Always enable quality gates in orchestrators:

```json
{
  "validation": {
    "required": ["type-check", "build"],
    "optional": ["tests"]
  }
}
```

---

### 4. Monitor Agent Performance

Check monthly metrics to identify issues:

```bash
/health-metrics

# Look for:
# - Success rate < 85% (needs improvement)
# - Underutilized agents (< 5 invocations/month)
# - Quality gate failures
# - Fallback strategy triggers
```

---

### 5. Keep .env.local Secure

```bash
# Never commit
echo ".env.local" >> .gitignore

# Use strong credentials
# Rotate tokens regularly
# Use environment-specific values
```

---

## 🔧 Troubleshooting

### MCP Server Not Working

**Problem:** MCP server not showing up after switch

**Solution:**
```bash
# 1. Verify config was copied
cat .mcp.json

# 2. Check environment variables
cat .env.local

# 3. Restart Claude Code completely
# (not just reload)

# 4. Check Claude Code logs for errors
```

---

### Quality Gates Failing

**Problem:** Type-check or build keeps failing

**Solution:**
```bash
# 1. Run manually to see full errors
npm run type-check
npm run build

# 2. Check for TypeScript issues
npx tsc --noEmit

# 3. Review validation settings
cat .claude/scripts/gates/check-*.sh
```

---

### Agent Workflow Stuck

**Problem:** Orchestrator workflow not progressing

**Solution:**
```bash
# 1. Check plan file
cat .tmp/current/plans/*.json

# 2. Verify reports generated
ls -la .tmp/current/reports/

# 3. Check for infinite loop
# (check-infinite-loop skill)

# 4. Review changes log
cat .tmp/current/changes/*.json
```

---

### Environment Variables Not Loading

**Problem:** MCP servers show "undefined" for variables

**Solution:**
```bash
# 1. Verify .env.local exists
ls -la .env.local

# 2. Check format (no quotes needed)
cat .env.local
# Correct: SUPABASE_PROJECT_REF=abc123
# Wrong: SUPABASE_PROJECT_REF="abc123"

# 3. Restart Claude Code
# Variables load on startup
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### Adding New Agents

1. Create agent file in appropriate category:
   ```
   .claude/agents/{category}/workers/my-agent.md
   ```

2. Follow agent template structure
3. Include examples and test cases
4. Update this README with agent description

### Adding New Skills

1. Create skill directory:
   ```
   .claude/skills/my-skill/SKILL.md
   ```

2. Follow SKILL.md format
3. Add to Skills Library section in README

### Adding MCP Configurations

1. Create config in `mcp/` directory
2. Follow naming convention: `.mcp.{name}.json`
3. Use environment variables for secrets
4. Update `switch-mcp.sh` menu
5. Document in README

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🏆 Attribution

This project includes components adapted from:

### SpecKit by GitHub
The SpecKit commands (`/speckit.*`) are adapted from [GitHub's SpecKit](https://github.com/github/spec-kit) project.
- **License:** MIT License
- **Copyright:** GitHub, Inc.
- **Components:** speckit.analyze, speckit.specify, speckit.clarify, speckit.plan, speckit.implement, speckit.checklist, speckit.tasks, speckit.constitution

Special thanks to the GitHub team for creating this excellent specification-driven development toolkit.

---

## 🙏 Acknowledgments

Built with and powered by:

- **[Claude Code](https://claude.com/claude-code)** by Anthropic
  The official CLI for Claude that powers this entire orchestration system

- **[Context7](https://upstash.com/context7)** by Upstash
  Real-time library documentation and best practices through MCP

- **[Smithery Sequential Thinking](https://smithery.ai/)**
  Enhanced reasoning capabilities through structured thinking

- **[Supabase MCP Server](https://github.com/supabase/mcp-server-supabase)**
  Database access and management through Model Context Protocol

- **[n8n](https://n8n.io/)**
  Workflow automation platform integration

- **[Playwright](https://playwright.dev/)**
  Browser automation for testing and validation

- **[shadcn/ui](https://ui.shadcn.com/)**
  Beautiful UI component system

Special thanks to the open-source community and all contributors!

---

## 🔗 Links

- **GitHub Repository:** [claude-code-orchestrator-kit](https://github.com/maslennikov-ig/claude-code-orchestrator-kit)
- **Author:** [Igor Maslennikov](https://github.com/maslennikov-ig)
- **Documentation:** [Full Docs](docs/Agents%20Ecosystem/)
- **Issues:** [GitHub Issues](https://github.com/maslennikov-ig/claude-code-orchestrator-kit/issues)
- **Discussions:** [GitHub Discussions](https://github.com/maslennikov-ig/claude-code-orchestrator-kit/discussions)

---

## 📊 Project Stats

- **33+** AI Agents (Orchestrators + Workers)
- **19+** Slash Commands
- **15+** Reusable Skills
- **6** MCP Configurations
- **3** Quality Gate Scripts
- **100%** Environment Variable Security

---

## 👤 Author

**Igor Maslennikov**
- GitHub: [@maslennikov-ig](https://github.com/maslennikov-ig)
- Repository: [claude-code-orchestrator-kit](https://github.com/maslennikov-ig/claude-code-orchestrator-kit)

---

Made with ❤️ for the Claude Code community

**Star ⭐ this repo if you find it useful!**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**TL;DR:** Free to use, modify, and distribute. Just keep the copyright notice.
