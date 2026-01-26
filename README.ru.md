# Claude Code Orchestrator Kit

> **Профессиональная система автоматизации и оркестрации для Claude Code**

Полный набор инструментов с **39 ИИ-агентами**, **38 скиллами**, **21 слэш-командой**, **авто-оптимизированным MCP**, **Beads issue tracking** и **Quality Gates** для создания production-ready проектов с Claude Code.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/claude-code-orchestrator-kit.svg)](https://www.npmjs.com/package/claude-code-orchestrator-kit)
[![Agents](https://img.shields.io/badge/Agents-39-green.svg)](#экосистема-агентов)
[![Skills](https://img.shields.io/badge/Skills-39-blue.svg)](#библиотека-скиллов)
[![Commands](https://img.shields.io/badge/Commands-21-orange.svg)](#слэш-команды)

**[English](README.md)** | **[Русский](#обзор)**

---

## Содержание

- [Обзор](#обзор)
- [Ключевые инновации](#ключевые-инновации)
- [Быстрый старт](#быстрый-старт)
- [Установка](#установка)
- [Архитектура](#архитектура)
- [Экосистема агентов](#экосистема-агентов)
- [Библиотека скиллов](#библиотека-скиллов)
- [Слэш-команды](#слэш-команды)
- [MCP-конфигурация](#mcp-конфигурация)
- [Настройки Claude Code](#настройки-claude-code)
- [Структура проекта](#структура-проекта)
- [Примеры использования](#примеры-использования)
- [Лучшие практики](#лучшие-практики)
- [Участие в разработке](#участие-в-разработке)
- [Лицензия](#лицензия)

---

## Обзор

**Claude Code Orchestrator Kit** трансформирует Claude Code из простого ассистента в интеллектуальную систему оркестрации. Вместо выполнения всего напрямую, Claude Code выступает оркестратором, делегирующим сложные задачи специализированным суб-агентам, сохраняя контекст и обеспечивая бесконечные рабочие сессии.

### Что вы получаете

| Категория | Количество | Описание |
|-----------|------------|----------|
| **ИИ-агенты** | 39 | Специализированные воркеры для багов, безопасности, тестирования, БД, фронтенда, DevOps |
| **Скиллы** | 39 | Переиспользуемые утилиты для валидации, отчётов, автоматизации, экспертизы |
| **Команды** | 21 | Health-проверки, SpecKit, Beads, process-logs, worktree, релизы |
| **MCP-серверы** | 6 | Авто-оптимизация: Context7, Sequential Thinking, Supabase, Playwright, shadcn, Serena |

### Ключевые преимущества

- **Сохранение контекста**: Основная сессия остаётся лёгкой (~10-15K токенов vs 50K+ при обычном использовании)
- **Специализация**: Каждый агент — эксперт в своей области
- **Бесконечная работа**: Можно работать над проектом неограниченно без исчерпания контекста
- **Контроль качества**: Обязательная верификация после каждого делегирования
- **Экспертиза уровня Senior**: Скиллы `code-reviewer`, `senior-devops`, `senior-prompt-engineer`

---

## Ключевые инновации

### 1. Паттерн оркестратора

**Основная парадигма**: Claude Code выступает оркестратором, делегируя задачи специализированным суб-агентам.

```
┌─────────────────────────────────────────────────────────────────┐
│                     MAIN CLAUDE CODE                             │
│                   (Роль оркестратора)                            │
├─────────────────────────────────────────────────────────────────┤
│  1. СОБРАТЬ КОНТЕКСТ  │  2. ДЕЛЕГИРОВАТЬ    │  3. ВЕРИФИЦИРОВАТЬ│
│  - Прочитать код      │  - Вызвать агента   │  - Прочитать      │
│  - Найти паттерны     │  - Передать контекст│    результаты     │
│  - Проверить коммиты  │  - Задать критерии  │  - Запустить      │
│                       │                     │    type-check     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                 СПЕЦИАЛИЗИРОВАННЫЕ АГЕНТЫ                        │
├──────────────┬──────────────┬──────────────┬───────────────────┤
│  bug-hunter  │  security-   │  database-   │  performance-     │
│  bug-fixer   │  scanner     │  architect   │  optimizer        │
│  dead-code-  │  vuln-fixer  │  api-builder │  accessibility-   │
│  hunter      │              │  supabase-   │  tester           │
│              │              │  auditor     │                   │
└──────────────┴──────────────┴──────────────┴───────────────────┘
```

### 2. Inline-скиллы (новая архитектура)

**Эволюция от оркестраторов**: Мы заменили тяжёлые агенты-оркестраторы на лёгкие inline-скиллы.

| Старый подход | Новый подход |
|---------------|--------------|
| Отдельный агент-оркестратор на workflow | Inline-скилл выполняется напрямую |
| ~1400 строк на workflow | ~150 строк на скилл |
| 9+ вызовов оркестратора | 0 вызовов оркестратора |
| ~10,000+ токенов overhead | ~500 токенов |
| Перезагрузка контекста при каждом вызове | Единый контекст сессии |

**Пример**: `/health-bugs` теперь использует `bug-health-inline` скилл:
```
Детекция → Валидация → Исправление по приоритетам → Верификация → Повтор если нужно
```

### 3. Senior-level скиллы

Профессиональные скиллы для сложных задач:

| Скилл | Экспертиза |
|-------|------------|
| `code-reviewer` | TypeScript, Python, Go, Swift, Kotlin code review |
| `senior-devops` | CI/CD, Docker, Kubernetes, Terraform, Cloud |
| `senior-prompt-engineer` | LLM оптимизация, RAG, дизайн агентов |
| `ux-researcher-designer` | Исследование пользователей, персоны, CJM |
| `systematic-debugging` | Анализ корневых причин, дебаггинг |

### 4. Авто-оптимизированная MCP-конфигурация

**Никакого ручного переключения!** Claude Code автоматически оптимизирует использование контекста:

- **Единый `.mcp.json`** со всеми серверами — не нужно переключать вручную
- **Автоматическая отложенная загрузка** через `ENABLE_TOOL_SEARCH=auto:5`
- **85% экономии контекста** для MCP-инструментов (загружаются по требованию через ToolSearch)
- **Прозрачно для пользователя** — просто работает без настройки

### 5. Beads Issue Tracking (опционально)

[Beads](https://github.com/steveyegge/beads) от Steve Yegge — git-backed трекер задач для AI-агентов:
- **Персистентные задачи**: Переживают рестарты сессий, отслеживаются в git
- **Граф зависимостей**: `blocks`, `blocked-by`, `discovered-from`
- **Мульти-сессии**: Работа в нескольких сессиях Claude без потери контекста
- **8 формул workflow**: `bigfeature`, `bugfix`, `hotfix`, `healthcheck` и др.
- **Инициализация**: Запустите `/beads-init` в вашем проекте

### 5. Интеграция SpecKit

Specification-driven workflow с Phase 0 Planning:
- Назначение исполнителей (MAIN vs специализированный агент)
- Параллельное создание агентов через meta-agent
- Атомарность: 1 Задача = 1 Вызов агента

---

## Быстрый старт

### Вариант 1: npm установка

```bash
npm install -g claude-code-orchestrator-kit
cd your-project
claude-orchestrator  # Интерактивная настройка
```

### Вариант 2: Клонирование репозитория

```bash
git clone https://github.com/maslennikov-ig/claude-code-orchestrator-kit.git
cd claude-code-orchestrator-kit

# Настройка окружения (опционально, для Supabase)
cp .env.example .env.local
# Отредактируйте .env.local с вашими credentials

# Перезапустите Claude Code — готово!
```

### Вариант 3: Копирование в существующий проект

```bash
# Скопируйте систему оркестрации в ваш проект
cp -r claude-code-orchestrator-kit/.claude /path/to/your/project/
cp claude-code-orchestrator-kit/.mcp.json /path/to/your/project/
cp claude-code-orchestrator-kit/CLAUDE.md /path/to/your/project/
```

---

## Установка

### Требования

- **Claude Code** CLI установлен
- **Node.js** 18+ (для MCP-серверов)
- **Git** (для функций контроля версий)

### Переменные окружения

Создайте `.env.local` (игнорируется git) с вашими credentials:

```bash
# Supabase (опционально)
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_ACCESS_TOKEN=your-token

# Sequential Thinking (опционально)
SEQUENTIAL_THINKING_KEY=your-smithery-key
SEQUENTIAL_THINKING_PROFILE=your-profile
```

### Проверка установки

```bash
# Проверьте что .mcp.json и .claude/settings.json существуют
ls -la .mcp.json .claude/settings.json

# Попробуйте health-команду в Claude Code
/health-bugs
```

---

## Архитектура

### Обзор компонентов

```
┌────────────────────────────────────────────────────────────────┐
│                        CLAUDE.md                                │
│              (Поведенческая операционная система)               │
│                                                                 │
│  Определяет: правила оркестрации, паттерны делегирования,      │
│              верификацию                                        │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                         АГЕНТЫ                                  │
│            (39 специализированных воркеров)                     │
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
│                         СКИЛЛЫ                                  │
│            (39 переиспользуемых утилит)                         │
├────────────────────────────────────────────────────────────────┤
│  Inline-оркестрация:          Senior-экспертиза:               │
│  ├─bug-health-inline          ├─code-reviewer                  │
│  ├─security-health-inline     ├─senior-devops                  │
│  ├─deps-health-inline         ├─senior-prompt-engineer         │
│  ├─cleanup-health-inline      ├─ux-researcher-designer         │
│  └─reuse-health-inline        └─systematic-debugging           │
│                                                                 │
│  Утилиты:                     Креатив:                          │
│  ├─validate-plan-file         ├─algorithmic-art                │
│  ├─run-quality-gate           ├─canvas-design                  │
│  ├─rollback-changes           ├─theme-factory                  │
│  ├─parse-git-status           └─artifacts-builder              │
│  └─generate-report-header                                       │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                        КОМАНДЫ                                  │
│            (21 слэш-команда)                                    │
├────────────────────────────────────────────────────────────────┤
│  /health-bugs      /speckit.specify    /worktree              │
│  /health-security  /speckit.plan       /push                  │
│  /health-deps      /speckit.implement  /translate-doc          │
│  /health-cleanup   /speckit.clarify    /process-logs          │
│  /health-reuse     /speckit.constitution   /beads-init        │
│  /health-metrics   /speckit.taskstoissues  /speckit.tobeads   │
└────────────────────────────────────────────────────────────────┘
```

---

## Экосистема агентов

### 39 специализированных агентов

#### Health (10 агентов)
| Агент | Назначение |
|-------|------------|
| `bug-hunter` | Обнаружение багов, категоризация по приоритету |
| `bug-fixer` | Исправление багов из отчётов |
| `security-scanner` | Поиск уязвимостей безопасности |
| `vulnerability-fixer` | Исправление проблем безопасности |
| `dead-code-hunter` | Обнаружение неиспользуемого кода |
| `dead-code-remover` | Безопасное удаление мёртвого кода |
| `dependency-auditor` | Аудит зависимостей пакетов |
| `dependency-updater` | Безопасное обновление зависимостей |
| `reuse-hunter` | Поиск дублирования кода |
| `reuse-fixer` | Консолидация дублированного кода |

#### Development (6 агентов)
| Агент | Назначение |
|-------|------------|
| `llm-service-specialist` | LLM-интеграция, промпты |
| `typescript-types-specialist` | Типы, дженерики |
| `cost-calculator-specialist` | Оценка стоимости токенов/API |
| `utility-builder` | Создание утилит |
| `skill-builder-v2` | Создание новых скиллов |
| `code-reviewer` | Комплексный code review |

#### Testing (6 агентов)
| Агент | Назначение |
|-------|------------|
| `integration-tester` | Тесты БД, API, async |
| `test-writer` | Написание unit/contract тестов |
| `performance-optimizer` | Core Web Vitals, PageSpeed |
| `mobile-responsiveness-tester` | Тестирование мобильных viewport |
| `mobile-fixes-implementer` | Исправление мобильных проблем |
| `accessibility-tester` | Соответствие WCAG |

#### Database (3 агента)
| Агент | Назначение |
|-------|------------|
| `database-architect` | Проектирование PostgreSQL схем |
| `api-builder` | tRPC роутеры, auth middleware |
| `supabase-auditor` | RLS политики, безопасность |

#### Infrastructure (5 агентов)
| Агент | Назначение |
|-------|------------|
| `infrastructure-specialist` | Supabase, Qdrant, Redis |
| `qdrant-specialist` | Операции с векторной БД |
| `quality-validator-specialist` | Валидация Quality Gates |
| `orchestration-logic-specialist` | State machines для workflows |
| `deployment-engineer` | CI/CD, Docker, DevOps |

#### Frontend (3 агента)
| Агент | Назначение |
|-------|------------|
| `nextjs-ui-designer` | Современный UI/UX дизайн |
| `fullstack-nextjs-specialist` | Full-stack Next.js |
| `visual-effects-creator` | Анимации, визуальные эффекты |

#### Прочие (6 агентов)
| Агент | Назначение |
|-------|------------|
| `meta-agent-v3` | Создание новых агентов |
| `technical-writer` | Документация |
| `problem-investigator` | Глубокий анализ проблем |
| `research-specialist` | Техническое исследование |
| `article-writer-multi-platform` | Мультиплатформенный контент |
| `lead-research-assistant` | Квалификация лидов |

---

## Библиотека скиллов

### 39 переиспользуемых скиллов

#### Inline-оркестрация (5 скиллов)
Выполнение health-workflows напрямую без порождения агентов-оркестраторов. Все скиллы включают **интеграцию с Beads** для отслеживания задач.

| Скилл | Вызов | Назначение | Версия |
|-------|-------|------------|--------|
| `health-bugs` | `/health-bugs` | Обнаружение и исправление багов с обогащением истории | 3.1.0 |
| `security-health-inline` | `/health-security` | Сканирование и исправление уязвимостей | 3.0.0 |
| `deps-health-inline` | `/health-deps` | Аудит и обновление зависимостей | 3.0.0 |
| `cleanup-health-inline` | `/health-cleanup` | Обнаружение и удаление мёртвого кода | 3.0.0 |
| `reuse-health-inline` | `/health-reuse` | Консолидация дублирования кода | 3.0.0 |

#### Senior-экспертиза (6 скиллов)
Профессиональная доменная экспертиза:

| Скилл | Экспертиза |
|-------|------------|
| `code-reviewer` | TypeScript, Python, Go, Swift, Kotlin review |
| `senior-devops` | CI/CD, контейнеры, cloud, инфраструктура |
| `senior-prompt-engineer` | LLM оптимизация, RAG, агенты |
| `ux-researcher-designer` | Исследование пользователей, персоны |
| `ui-design-system` | Дизайн-токены, компоненты |
| `systematic-debugging` | Анализ корневых причин |

#### Валидация и качество (6 скиллов)
| Скилл | Назначение |
|-------|------------|
| `validate-plan-file` | Валидация JSON-схемы |
| `validate-report-file` | Полнота отчёта |
| `run-quality-gate` | Type-check/build/tests |
| `calculate-priority-score` | Приоритизация багов/задач |
| `setup-knip` | Настройка обнаружения мёртвого кода |
| `rollback-changes` | Откат из лога изменений |

#### Отчёты и форматирование (6 скиллов)
| Скилл | Назначение |
|-------|------------|
| `generate-report-header` | Стандартизированные заголовки отчётов |
| `generate-changelog` | Changelog из коммитов |
| `format-markdown-table` | Хорошо отформатированные таблицы |
| `format-commit-message` | Conventional commits |
| `format-todo-list` | TodoWrite-совместимые списки |
| `render-template` | Подстановка переменных |

#### Парсинг и извлечение (4 скилла)
| Скилл | Назначение |
|-------|------------|
| `parse-git-status` | Парсинг вывода git status |
| `parse-package-json` | Извлечение версии, зависимостей |
| `parse-error-logs` | Парсинг ошибок build/test |
| `extract-version` | Парсинг семантических версий |

#### Креатив и UI (6 скиллов)
| Скилл | Назначение |
|-------|------------|
| `algorithmic-art` | Генеративное искусство с p5.js |
| `canvas-design` | Визуальное искусство в PNG/PDF |
| `theme-factory` | Стилизация тем для артефактов |
| `artifacts-builder` | Многокомпонентные HTML-артефакты |
| `webapp-testing` | Playwright-тестирование |
| `frontend-aesthetics` | Уникальный UI-дизайн |

#### Автоматизация workflows (2 скилла)
| Скилл | Назначение | Версия |
|-------|------------|--------|
| `process-logs` | Автоматизированная обработка логов ошибок с интеграцией Beads | 1.8.0 |
| `process-issues` | Обработка GitHub Issues с поиском похожих проблем | 1.1.0 |

#### Прочие (4 скилла)
| Скилл | Назначение |
|-------|------------|
| `git-commit-helper` | Сообщение коммита из diff |
| `changelog-generator` | User-facing changelogs |
| `content-research-writer` | Контент с исследованием |
| `lead-research-assistant` | Идентификация лидов |

---

## Слэш-команды

### 21 команда

#### Health-мониторинг (6 команд)

| Команда | Назначение |
|---------|------------|
| `/health-bugs` | Workflow обнаружения и исправления багов |
| `/health-security` | Сканирование уязвимостей безопасности |
| `/health-deps` | Аудит и обновление зависимостей |
| `/health-cleanup` | Обнаружение и удаление мёртвого кода |
| `/health-reuse` | Устранение дублирования кода |
| `/health-metrics` | Ежемесячный отчёт о здоровье экосистемы |

**Пример:**
```bash
/health-bugs
# Сканирует → Категоризирует → Исправляет по приоритетам → Валидирует → Отчитывается
```

#### SpecKit (9 команд)

| Команда | Назначение |
|---------|------------|
| `/speckit.analyze` | Анализ требований |
| `/speckit.specify` | Генерация спецификаций |
| `/speckit.clarify` | Уточняющие вопросы |
| `/speckit.plan` | Создание плана реализации |
| `/speckit.implement` | Выполнение реализации |
| `/speckit.checklist` | Генерация QA-чеклиста |
| `/speckit.tasks` | Разбиение на задачи |
| `/speckit.constitution` | Определение конституции проекта |
| `/speckit.taskstoissues` | Конвертация задач в GitHub issues |

#### Beads (2 команды)

| Команда | Назначение |
|---------|------------|
| `/beads-init` | Инициализация Beads в проекте |
| `/speckit.tobeads` | Импорт tasks.md в Beads |

#### Прочие (4 команды)

| Команда | Назначение |
|---------|------------|
| `/process-logs` | Автоматическая обработка и исправление логов ошибок |
| `/push [patch\|minor\|major]` | Автоматический релиз с changelog |
| `/worktree` | Управление git worktree |
| `/translate-doc` | Перевод документации (EN↔RU) |

---

## MCP-конфигурация

### Единая авто-оптимизированная настройка

**Больше не нужно переключать вручную!** Kit использует единый `.mcp.json` с автоматической оптимизацией.

#### Как это работает

1. **Один файл конфигурации** (`.mcp.json`) содержит все MCP-серверы
2. **Авто-отложенная загрузка** через `.claude/settings.json`:
   ```json
   {
     "env": { "ENABLE_TOOL_SEARCH": "auto:5" }
   }
   ```
3. **Загрузка по требованию** — Claude загружает инструменты только когда они нужны через ToolSearch
4. **85% экономии контекста** по сравнению с загрузкой всех инструментов сразу

#### Включённые MCP-серверы

| Сервер | Назначение | Инструменты |
|--------|------------|-------------|
| **Context7** | Актуальная документация библиотек | `resolve-library-id`, `query-docs` |
| **Sequential Thinking** | Структурированное рассуждение для сложных задач | `sequentialthinking` |
| **Supabase** | Операции с БД, миграции, RLS | Таблицы, SQL, миграции, edge functions |
| **Playwright** | Автоматизация браузера и тестирование | Скриншоты, навигация, заполнение форм |
| **shadcn/ui** | Интеграция библиотеки UI-компонентов | Поиск в реестре, примеры компонентов |
| **Serena** | Семантический анализ кода (LSP) | Поиск символов, ссылки, рефакторинг |

#### Переменные окружения

Установите в `.env.local` для интеграции с Supabase:
```bash
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_ACCESS_TOKEN=your-token
```

---

## Настройки Claude Code

### `.claude/settings.json`

Конфигурация Claude Code на уровне проекта для улучшенного workflow:

```json
{
  "plansDirectory": "./docs/plans",
  "env": {
    "ENABLE_TOOL_SEARCH": "auto:5"
  }
}
```

#### Описание настроек

| Настройка | Значение | Назначение |
|-----------|----------|------------|
| `plansDirectory` | `./docs/plans` | Куда Claude сохраняет планы реализации при использовании Plan Mode |
| `ENABLE_TOOL_SEARCH` | `auto:5` | Авто-включение отложенной загрузки MCP-инструментов для серверов с >5 инструментами |

#### Преимущества

- **Интеграция с Plan Mode**: Планы сохраняются в `docs/plans/` для контроля версий и ревью
- **Автоматическая оптимизация контекста**: MCP-инструменты загружаются по требованию
- **Без ручной настройки**: Работает прозрачно — просто установите и используйте

---

## Промпты

Готовые промпты для настройки различных функций в вашем проекте. Скопируйте, вставьте в Claude Code — и он всё настроит.

| Промпт | Описание |
|--------|----------|
| [`setup-health-workflows.md`](prompts/setup-health-workflows.md) | Health-воркфлоу с интеграцией Beads (`/health-bugs`, `/health-security` и др.) |
| [`setup-error-logging.md`](prompts/setup-error-logging.md) | Система логирования ошибок с БД-таблицей, логгер-сервисом и авто-мутом |

### Быстрый старт: Health Workflows

```bash
# 1. Установите Beads CLI
npm install -g @anthropic/beads-cli

# 2. Инициализируйте в вашем проекте
bd init

# 3. Запустите в Claude Code
/health-bugs
```

**Как использовать:**

1. Скопируйте содержимое промпта в чат с Claude Code
2. Ответьте на вопросы Claude о специфике вашего проекта
3. Проверьте сгенерированный код перед коммитом

Подробности в [`prompts/README.md`](prompts/README.md).

---

## Структура проекта

```
claude-code-orchestrator-kit/
├── .claude/
│   ├── agents/                 # 39 ИИ-агентов
│   │   ├── health/             # Баги, безопасность, зависимости, cleanup
│   │   ├── development/        # LLM, TypeScript, утилиты
│   │   ├── testing/            # Интеграция, performance, mobile
│   │   ├── database/           # Supabase, API, архитектура
│   │   ├── infrastructure/     # Qdrant, deployment, оркестрация
│   │   ├── frontend/           # Next.js, визуальные эффекты
│   │   ├── meta/               # Создатели агентов/скиллов
│   │   ├── research/           # Исследование проблем
│   │   ├── documentation/      # Техническое написание
│   │   ├── content/            # Написание статей
│   │   └── business/           # Исследование лидов
│   │
│   ├── skills/                 # 37 переиспользуемых скиллов
│   │   ├── bug-health-inline/  # Inline-оркестрация
│   │   ├── code-reviewer/      # Senior-экспертиза
│   │   ├── validate-plan-file/ # Утилиты валидации
│   │   └── ...
│   │
│   ├── commands/               # 21 слэш-команда
│   │   ├── health-*.md         # Health-мониторинг
│   │   ├── speckit.*.md        # SpecKit workflow
│   │   └── ...
│   │
│   ├── schemas/                # JSON-схемы
│   └── scripts/                # Скрипты Quality Gates
│
├── mcp/                        # Legacy MCP-конфигурации (только для справки)
│   └── ...
│
├── docs/                       # Документация
│   ├── FAQ.md
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL-CUSTOM-AGENTS.md
│   └── ...
│
├── .mcp.json                   # Единая MCP-конфигурация
├── CLAUDE.md                   # Поведенческая ОС
└── package.json                # npm package config
```

---

## Примеры использования

### Пример 1: Workflow исправления багов

```bash
# Запустить полное обнаружение и исправление багов
/health-bugs

# Что происходит:
# 1. Pre-flight валидация
# 2. Обнаружение багов (агент bug-hunter)
# 3. Валидация Quality Gate
# 4. Исправление по приоритетам (critical → low)
# 5. Quality Gates после каждого приоритета
# 6. Верификационное сканирование
# 7. Финальный отчёт
```

### Пример 2: Code Review

```bash
# Вызвать скилл code-reviewer
/code-reviewer

# Предоставляет:
# - Автоматический анализ кода
# - Проверка лучших практик
# - Сканирование безопасности
# - Чеклист review
```

### Пример 3: Автоматизация релизов

```bash
# Автоопределение типа версии
/push

# Или указать тип
/push minor

# Действия:
# 1. Анализ коммитов с последнего релиза
# 2. Увеличение версии в package.json
# 3. Генерация записи в changelog
# 4. Создание git commit + tag
# 5. Push в remote
```

### Пример 4: Параллельная разработка фич

```bash
# Создать worktrees
/worktree create feature/new-auth
/worktree create feature/new-ui

# Работать параллельно
cd .worktrees/feature-new-auth
# ... изменения ...

# Очистка по завершении
/worktree cleanup
```

---

## Лучшие практики

### 1. Используйте авто-оптимизированный MCP
Kit автоматически оптимизирует использование контекста — настройка не требуется:
- MCP-инструменты загружаются по требованию через ToolSearch
- ~85% экономии контекста по сравнению с загрузкой всех инструментов сразу

### 2. Запускайте Health-проверки еженедельно
```bash
/health-bugs      # Понедельник
/health-security  # Вторник
/health-deps      # Среда
/health-cleanup   # Четверг
/health-metrics   # Ежемесячно
```

### 3. Используйте Library-First подход
Перед написанием кода >20 строк ищите существующие библиотеки:
- Проверьте npm/PyPI на пакеты с >1k загрузок в неделю
- Оцените статус поддержки и наличие типов
- Используйте библиотеку если она покрывает >70% функциональности

### 4. Следуйте правилам оркестрации
1. **СНАЧАЛА СОБРАТЬ КОНТЕКСТ** - Прочитать код, найти паттерны
2. **ДЕЛЕГИРОВАТЬ СУБАГЕНТАМ** - Передать полный контекст
3. **ВЕРИФИЦИРОВАТЬ РЕЗУЛЬТАТЫ** - Никогда не пропускать проверку
4. **ЦИКЛ ACCEPT/REJECT** - Переделегировать если нужно

### 5. Храните credentials в безопасности
```bash
# Никогда не коммитьте .env.local
echo ".env.local" >> .gitignore
```

---

## Документация

| Документ | Описание |
|----------|----------|
| [FAQ](docs/FAQ.md) | Часто задаваемые вопросы |
| [Architecture](docs/ARCHITECTURE.md) | Диаграммы проектирования системы |
| [Tutorial: Custom Agents](docs/TUTORIAL-CUSTOM-AGENTS.md) | Создание собственных агентов |
| [Use Cases](docs/USE-CASES.md) | Реальные примеры |
| [Performance](docs/PERFORMANCE-OPTIMIZATION.md) | Оптимизация токенов |
| [Migration Guide](docs/MIGRATION-GUIDE.md) | Добавление в существующие проекты |
| [Commands Guide](docs/COMMANDS-GUIDE.md) | Подробный справочник команд |

---

## Участие в разработке

### Добавление новых агентов

1. Создайте файл в `.claude/agents/{category}/workers/`
2. Следуйте структуре шаблона агента
3. Добавьте в этот README

### Добавление новых скиллов

1. Создайте директорию `.claude/skills/{skill-name}/`
2. Добавьте `SKILL.md` по формату
3. Добавьте в этот README

### Добавление MCP-серверов

1. Добавьте сервер в `.mcp.json`
2. Задокументируйте в README в секции MCP-конфигурация

---

## Атрибуция

### SpecKit от GitHub
Команды `/speckit.*` адаптированы из [GitHub's SpecKit](https://github.com/github/spec-kit).
- **Лицензия**: MIT License
- **Copyright**: GitHub, Inc.

### Beads от Steve Yegge
Интеграция Beads issue tracking адаптирована из [Steve Yegge's Beads](https://github.com/steveyegge/beads).
- **Описание**: Распределённый, git-backed граф-трекер задач для AI-агентов
- **Лицензия**: MIT License
- **Copyright**: Steve Yegge
- **Команды**: `/beads-init`, `/speckit.tobeads`
- **Шаблоны**: директория `.beads-templates/` с 8 формулами workflow

---

## Благодарности

Построено с использованием:
- **[Claude Code](https://claude.com/claude-code)** от Anthropic
- **[Context7](https://upstash.com/context7)** от Upstash
- **[Supabase MCP](https://github.com/supabase/mcp-server-supabase)**
- **[Smithery Sequential Thinking](https://smithery.ai/)**
- **[Playwright](https://playwright.dev/)**
- **[shadcn/ui](https://ui.shadcn.com/)**

---

## Статистика

- **39** ИИ-агентов
- **39** Переиспользуемых скиллов
- **21** Слэш-команда
- **6** MCP-серверов (авто-оптимизация)
- **v1.4.19** Текущая версия

---

## Автор

**Игорь Масленников**
- GitHub: [@maslennikov-ig](https://github.com/maslennikov-ig)
- Сайт: [aidevteam.ru](https://aidevteam.ru/)

---

## Лицензия

MIT License — см. файл [LICENSE](LICENSE).

---

**Поставьте звезду репозиторию, если он вам полезен!**
