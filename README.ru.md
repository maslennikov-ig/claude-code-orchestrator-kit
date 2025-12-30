# Claude Code Orchestrator Kit

> **Профессиональная система автоматизации и оркестрации для Claude Code**

Полный набор инструментов с **39 ИИ-агентами**, **37 скиллами**, **18 слэш-командами**, **7 MCP-конфигурациями** и **Quality Gates** для создания production-ready проектов с Claude Code.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/claude-code-orchestrator-kit.svg)](https://www.npmjs.com/package/claude-code-orchestrator-kit)
[![Agents](https://img.shields.io/badge/Agents-39-green.svg)](#экосистема-агентов)
[![Skills](https://img.shields.io/badge/Skills-37-blue.svg)](#библиотека-скиллов)
[![Commands](https://img.shields.io/badge/Commands-18-orange.svg)](#слэш-команды)

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
- [MCP-конфигурации](#mcp-конфигурации)
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
| **Скиллы** | 37 | Переиспользуемые утилиты для валидации, отчётов, автоматизации, экспертизы |
| **Команды** | 18 | Health-проверки, SpecKit, управление worktree, релизы |
| **MCP-конфиги** | 7 | Готовые настройки от минимальных (600 токенов) до полных (6500 токенов) |

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

### 4. Динамическое переключение MCP

Экономьте 500-4500 токенов контекста, загружая только нужное:

```bash
./switch-mcp.sh
# Выберите конфигурацию под вашу задачу
```

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
claude-orchestrator  # Интерактивная настройка MCP
```

### Вариант 2: Клонирование репозитория

```bash
git clone https://github.com/maslennikov-ig/claude-code-orchestrator-kit.git
cd claude-code-orchestrator-kit

# Настройка окружения
cp .env.example .env.local
# Отредактируйте .env.local с вашими credentials

# Выбор MCP-конфигурации
./switch-mcp.sh

# Перезапустите Claude Code — готово!
```

### Вариант 3: Копирование в существующий проект

```bash
# Скопируйте систему оркестрации в ваш проект
cp -r claude-code-orchestrator-kit/.claude /path/to/your/project/
cp claude-code-orchestrator-kit/CLAUDE.md /path/to/your/project/
cp claude-code-orchestrator-kit/switch-mcp.sh /path/to/your/project/
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
# Проверить MCP-конфигурацию
./switch-mcp.sh  # Выберите опцию 0 для просмотра активных серверов

# Попробуйте health-команду
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
│            (37 переиспользуемых утилит)                         │
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
│            (18 слэш-команд)                                     │
├────────────────────────────────────────────────────────────────┤
│  /health-bugs      /speckit.specify    /worktree              │
│  /health-security  /speckit.plan       /push                  │
│  /health-deps      /speckit.implement  /translate-doc          │
│  /health-cleanup   /speckit.clarify                            │
│  /health-reuse     /speckit.constitution                       │
│  /health-metrics   /speckit.taskstoissues                      │
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

### 37 переиспользуемых скиллов

#### Inline-оркестрация (5 скиллов)
Выполнение health-workflows напрямую без порождения агентов-оркестраторов:

| Скилл | Команда | Назначение |
|-------|---------|------------|
| `bug-health-inline` | `/health-bugs` | Обнаружение и исправление багов |
| `security-health-inline` | `/health-security` | Сканирование и исправление безопасности |
| `deps-health-inline` | `/health-deps` | Аудит и обновление зависимостей |
| `cleanup-health-inline` | `/health-cleanup` | Удаление мёртвого кода |
| `reuse-health-inline` | `/health-reuse` | Устранение дублирования кода |

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

#### Прочие (4 скилла)
| Скилл | Назначение |
|-------|------------|
| `git-commit-helper` | Сообщение коммита из diff |
| `changelog-generator` | User-facing changelogs |
| `content-research-writer` | Контент с исследованием |
| `lead-research-assistant` | Идентификация лидов |

---

## Слэш-команды

### 18 команд

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

#### Прочие (3 команды)

| Команда | Назначение |
|---------|------------|
| `/push [patch\|minor\|major]` | Автоматический релиз с changelog |
| `/worktree` | Управление git worktree |
| `/translate-doc` | Перевод документации (EN↔RU) |

---

## MCP-конфигурации

### 7 готовых настроек

Переключайте конфигурации в зависимости от задачи для экономии токенов:

```bash
./switch-mcp.sh
```

| Конфигурация | Серверы | Токенов | Сценарий |
|--------------|---------|---------|----------|
| **BASE** | Context7 + Sequential Thinking | ~600 | Ежедневная разработка |
| **SUPABASE** | Base + Supabase | ~2500 | Работа с БД |
| **SUPABASE-FULL** | Base + Supabase (dual) | ~3000 | Мульти-проект БД |
| **N8N** | Base + n8n automation | ~2500 | Автоматизация workflows |
| **FRONTEND** | Base + Playwright + ShadCN | ~2000 | UI-разработка |
| **SERENA** | Base + Serena LSP | ~2500 | Семантический поиск кода |
| **FULL** | Все серверы | ~6500 | Максимальные возможности |

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
│   ├── commands/               # 18 слэш-команд
│   │   ├── health-*.md         # Health-мониторинг
│   │   ├── speckit.*.md        # SpecKit workflow
│   │   └── ...
│   │
│   ├── schemas/                # JSON-схемы
│   └── scripts/                # Скрипты Quality Gates
│
├── mcp/                        # 7 MCP-конфигураций
│   ├── .mcp.base.json
│   ├── .mcp.supabase-only.json
│   ├── .mcp.frontend.json
│   └── ...
│
├── docs/                       # Документация
│   ├── FAQ.md
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL-CUSTOM-AGENTS.md
│   └── ...
│
├── CLAUDE.md                   # Поведенческая ОС
├── switch-mcp.sh               # Переключатель MCP
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

### 1. Начинайте с BASE-конфигурации
Используйте минимальный MCP-конфиг для ежедневной работы (~600 токенов):
```bash
./switch-mcp.sh  # Выберите BASE
```

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

### Добавление MCP-конфигураций

1. Создайте `mcp/.mcp.{name}.json`
2. Обновите `switch-mcp.sh`
3. Задокументируйте в README

---

## Атрибуция

### SpecKit от GitHub
Команды `/speckit.*` адаптированы из [GitHub's SpecKit](https://github.com/github/spec-kit).
- **Лицензия**: MIT License
- **Copyright**: GitHub, Inc.

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
- **37** Переиспользуемых скиллов
- **18** Слэш-команд
- **7** MCP-конфигураций
- **v1.4.13** Текущая версия

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
