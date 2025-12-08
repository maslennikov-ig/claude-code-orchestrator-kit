# Claude Code Orchestrator Kit: Руководство по командам

> Версия: v1.4.0

Полный набор slash-команд для разработки с Claude Code: от спецификации до релиза.

---

## Обзор команд

| Группа | Команды | Назначение |
|--------|---------|------------|
| **Spec-Kit** | `/speckit.*` (9 команд) | Спецификационно-ориентированная разработка |
| **Health** | `/health-*` (6 команд) | Анализ и исправление качества кода |
| **Worktree** | `/worktree-*` (4 команды) | Параллельная разработка в git worktrees |
| **Release** | `/push` | Автоматизация релизов |
| **Utility** | `/translate-doc` | Перевод документации |

---

# Spec-Kit

Spec-Kit — набор команд для **спецификационно-ориентированной разработки** (Spec-Driven Development). Позволяет структурированно описывать требования, планировать реализацию и выполнять задачи через агентов.

---

## Быстрый старт

```bash
# 1. Создать спецификацию фичи
/speckit.specify Добавить систему аутентификации через OAuth2

# 2. Уточнить требования (опционально)
/speckit.clarify

# 3. Создать технический план
/speckit.plan

# 4. Сгенерировать задачи
/speckit.tasks

# 5. Проверить консистентность (опционально)
/speckit.analyze

# 6. Реализовать
/speckit.implement
```

---

## Команды

### `/speckit.specify` — Создание спецификации

**Что делает**: Создаёт ветку, директорию и файл `spec.md` с требованиями.

**Использование**:
```bash
/speckit.specify Описание фичи на естественном языке
```

**Пример**:
```bash
/speckit.specify Добавить дашборд аналитики с графиками посещаемости
```

**Результат**:
- Создаётся ветка `1-analytics-dashboard`
- Создаётся `specs/1-analytics-dashboard/spec.md`
- Создаётся чеклист `specs/1-analytics-dashboard/checklists/requirements.md`

**Особенности**:
- Автоматически генерирует короткое имя ветки
- Проверяет существующие ветки для уникального номера
- Максимум 3 маркера `[NEEDS CLARIFICATION]`
- Задаёт уточняющие вопросы если нужно

---

### `/speckit.clarify` — Уточнение требований

**Что делает**: Анализирует спецификацию на неясности и задаёт до 5 вопросов.

**Использование**:
```bash
/speckit.clarify
/speckit.clarify область безопасности
```

**Когда использовать**:
- Перед `/speckit.plan` если spec.md содержит неясности
- Для глубокой проработки конкретной области

**Особенности**:
- Анализирует по 11 категориям (Scope, Data Model, UX, Security и др.)
- Предлагает рекомендованные ответы
- Обновляет spec.md после каждого ответа
- Сложные вопросы помечает для research phase

---

### `/speckit.plan` — Техническое планирование

**Что делает**: Создаёт технический план с архитектурой, моделями данных и контрактами.

**Использование**:
```bash
/speckit.plan
/speckit.plan Next.js 15, Supabase, tRPC
```

**Результат** (в директории фичи):
- `plan.md` — основной план
- `research.md` — результаты исследований
- `research/` — сложные исследования (если есть)
- `data-model.md` — модели данных
- `contracts/` — API контракты
- `quickstart.md` — быстрый старт

**Особенности**:
- **Library-First**: Сначала ищет существующие библиотеки
- Проверяет соответствие Constitution
- Классифицирует research: simple (решается сразу) / complex (в research/)

---

### `/speckit.tasks` — Генерация задач

**Что делает**: Создаёт `tasks.md` с пошаговым планом реализации.

**Использование**:
```bash
/speckit.tasks
```

**Структура tasks.md**:
```
Phase 0: Planning (назначение executor'ов)
Phase 1: Setup (инициализация проекта)
Phase 2: Foundational (базовая инфраструктура)
Phase 3+: User Stories (по приоритетам P1, P2, P3...)
Phase N: Polish (финальные улучшения)
```

**Формат задач**:
```markdown
- [ ] T001 Create project structure per implementation plan
- [ ] T005 [P] [US1] Create User model in src/models/user.py
```

- `T001` — ID задачи
- `[P]` — можно выполнять параллельно
- `[US1]` — относится к User Story 1

---

### `/speckit.analyze` — Анализ консистентности

**Что делает**: Проверяет spec.md, plan.md и tasks.md на противоречия.

**Использование**:
```bash
/speckit.analyze
```

**Что проверяет**:
- Дублирование требований
- Неясные формулировки
- Покрытие требований задачами
- Соответствие Constitution
- Терминологическую консистентность

**Результат**: Отчёт с severity (CRITICAL/HIGH/MEDIUM/LOW) и рекомендациями.

---

### `/speckit.implement` — Реализация

**Что делает**: Выполняет задачи из tasks.md через агентов.

**Использование**:
```bash
/speckit.implement
/speckit.implement начать с Phase 2
```

**Workflow**:

```
┌─────────────────────────────────────────────────────────┐
│  PLANNING PHASE (один раз в начале)                    │
├─────────────────────────────────────────────────────────┤
│  P001: Анализ задач → какие агенты нужны               │
│  P002: Создание агентов через meta-agent-v3            │
│  P003: Назначение executor'ов для каждой задачи        │
│  P004: Решение research задач                          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  EXECUTION (для каждой задачи)                         │
├─────────────────────────────────────────────────────────┤
│  1. TodoWrite: in_progress                             │
│  2. Gather context (код, паттерны, документация)       │
│  3. Library search (если >20 строк нового кода)        │
│  4. Context7: получить docs библиотек                  │
│  5. Execute: делегировать агенту или выполнить         │
│  6. Verify: прочитать файлы, type-check                │
│  7. Accept/Reject: повторить если ошибка               │
│  8. TodoWrite: completed                               │
│  9. Mark [X] в tasks.md + artifacts                    │
│  10. /push patch                                       │
└─────────────────────────────────────────────────────────┘
```

**Ключевые правила**:
- **1 Task = 1 Agent** — атомарность
- **Parallel = N calls in single message** — параллельные задачи запускаются одним сообщением
- **Library-first** — сначала ищем библиотеку, потом пишем код
- **Commit after each task** — `/push patch` после каждой задачи

---

### `/speckit.checklist` — Создание чеклиста

**Что делает**: Генерирует чеклист для проверки качества требований.

**Использование**:
```bash
/speckit.checklist ux
/speckit.checklist security
/speckit.checklist api
```

**Важно**: Чеклисты проверяют **качество требований**, не реализацию!

```markdown
# Правильно (проверка требований):
- [ ] Are error handling requirements defined for all API failure modes?

# Неправильно (проверка реализации):
- [ ] Verify API returns 200 on success
```

---

### `/speckit.constitution` — Управление принципами

**Что делает**: Создаёт/обновляет файл принципов проекта.

**Использование**:
```bash
/speckit.constitution
/speckit.constitution добавить принцип "No ORM, raw SQL only"
```

**Файл**: `.specify/memory/constitution.md`

Constitution определяет:
- Обязательные технологии
- Запрещённые подходы
- Quality gates
- Архитектурные ограничения

---

### `/speckit.taskstoissues` — Экспорт в GitHub Issues

**Что делает**: Конвертирует tasks.md в GitHub Issues.

**Использование**:
```bash
/speckit.taskstoissues                # все задачи
/speckit.taskstoissues --dry-run      # только показать
/speckit.taskstoissues --phase 1      # только Phase 1
/speckit.taskstoissues --limit 5      # первые 5 задач
```

**Требования**:
- `gh` CLI установлен (`brew install gh` / `apt install gh`)
- Авторизация: `gh auth login`
- Remote должен быть GitHub URL

**Что создаёт**:
- Issue для каждой задачи из tasks.md
- Labels: `speckit`, `setup`, `user-story`
- Форматированное описание с metadata

---

## Структура проекта

```
project/
├── .specify/
│   ├── memory/
│   │   └── constitution.md      # Принципы проекта
│   ├── templates/
│   │   ├── spec-template.md
│   │   ├── plan-template.md
│   │   ├── tasks-template.md
│   │   └── checklist-template.md
│   └── scripts/bash/
│       ├── create-new-feature.sh
│       ├── check-prerequisites.sh
│       ├── setup-plan.sh
│       └── update-agent-context.sh
├── .claude/commands/
│   ├── speckit.specify.md
│   ├── speckit.clarify.md
│   ├── speckit.plan.md
│   ├── speckit.tasks.md
│   ├── speckit.analyze.md
│   ├── speckit.implement.md
│   ├── speckit.checklist.md
│   ├── speckit.constitution.md
│   └── speckit.taskstoissues.md
└── specs/
    └── 1-feature-name/
        ├── spec.md
        ├── plan.md
        ├── research.md
        ├── research/           # Сложные исследования
        ├── data-model.md
        ├── contracts/
        ├── quickstart.md
        ├── tasks.md
        └── checklists/
            └── requirements.md
```

---

## Phase 0: Planning — Детали

Phase 0 — критическая фаза перед реализацией:

| Шаг | Действие | Результат |
|-----|----------|-----------|
| P001 | Анализ задач | Список необходимых агентов |
| P002 | Создание агентов | `.claude/agents/` + restart |
| P003 | Назначение executor'ов | Аннотации `[EXECUTOR: name]` |
| P004 | Research resolution | Решённые вопросы или prompts |

**Executor'ы**:
- `MAIN` — только тривиальные задачи (1-2 строки)
- `existing-agent` — если 100% совпадение возможностей
- `new-agent` — создаётся через meta-agent-v3

**Пример аннотированной задачи**:
```markdown
- [ ] T012 [P] [US1] [EXECUTOR: fullstack-nextjs-specialist] [PARALLEL-GROUP-1]
      Create User model in src/models/user.ts
```

---

## Интеграция с библиотеками

Перед написанием кода >20 строк:

1. **WebSearch**: `npm {functionality} library 2025`
2. **Context7**: Получить документацию
3. **Проверить**: downloads >1000/week, commits <6 months, TypeScript support
4. **Решить**: использовать библиотеку или писать своё

```bash
# В implement фазе автоматически:
mcp__context7__resolve-library-id → получить ID
mcp__context7__get-library-docs → получить docs по теме
```

---

## DeksdenFlow (Session Management)

При длинных сессиях `/speckit.implement`:

- **resume-session** — проверка существующей сессии
- **save-session-context** — сохранение после каждой фазы
- **load-project-context** — загрузка структуры проекта

Позволяет:
- Возобновить работу после перезапуска
- Не терять контекст при ошибках
- Логировать решения в session-log.md

---

## Типичные сценарии

### Новая фича с нуля
```bash
/speckit.specify Добавить систему уведомлений
/speckit.clarify
/speckit.plan Next.js, Supabase
/speckit.tasks
/speckit.implement
```

### Быстрый прототип (skip clarify)
```bash
/speckit.specify Простая форма обратной связи
/speckit.plan
/speckit.tasks
/speckit.implement
```

### Только планирование (без реализации)
```bash
/speckit.specify Миграция на новую архитектуру
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze
# Передать tasks.md команде
```

### Проверка существующей спеки
```bash
/speckit.analyze
/speckit.checklist security
/speckit.checklist ux
```

---

## Troubleshooting

| Проблема | Решение |
|----------|---------|
| `No feature branch` | Сначала запустите `/speckit.specify` |
| `spec.md not found` | Переключитесь на feature ветку |
| `tasks.md missing` | Запустите `/speckit.tasks` |
| Агент не найден | После P002 перезапустите Claude Code |
| Library not found | Проверьте Context7 MCP connection |

---

# Health Commands

Команды для автоматического анализа и исправления качества кода.

## `/health-bugs` — Поиск и исправление багов

**Что делает**: Полный цикл обнаружения и исправления багов.

```bash
/health-bugs
```

**Workflow**:
1. Сканирование кода на баги (все приоритеты)
2. Исправление по стадиям: critical → high → medium → low
3. Quality gates после каждой стадии
4. Верификация
5. До 3 итераций если проблемы остаются

---

## `/health-security` — Анализ безопасности

**Что делает**: Обнаружение и исправление уязвимостей.

```bash
/health-security
```

**Что проверяет**:
- SQL injection, XSS
- Проблемы аутентификации
- Hardcoded secrets
- RLS policies (Supabase)
- OWASP Top 10

---

## `/health-deps` — Управление зависимостями

**Что делает**: Аудит и обновление зависимостей.

```bash
/health-deps
```

**Что делает**:
- Поиск устаревших пакетов
- Обнаружение уязвимостей (npm audit)
- Обновление по одному пакету с валидацией
- Откат при ошибках

---

## `/health-cleanup` — Очистка dead code

**Что делает**: Поиск и удаление неиспользуемого кода.

```bash
/health-cleanup
```

**Что ищет**:
- Неиспользуемые функции и переменные
- Закомментированный код
- Debug артефакты (console.log)
- Недостижимый код

---

## `/health-reuse` — Дедупликация кода

**Что делает**: Поиск и консолидация дублирующегося кода.

```bash
/health-reuse
```

**Что ищет**:
- Дублирующиеся типы и интерфейсы
- Повторяющиеся Zod схемы
- Копипаст констант
- Похожие утилиты

---

## `/health-metrics` — Метрики качества

**Что делает**: Сбор метрик качества кода.

```bash
/health-metrics
```

**Метрики**:
- Покрытие тестами
- Сложность кода
- Количество TODO/FIXME
- Размер бандла

---

# Worktree Commands

Команды для параллельной разработки через git worktrees.

## `/worktree-create` — Создать worktree

**Что делает**: Создаёт изолированную директорию для параллельной работы.

```bash
/worktree-create feature-name
/worktree-create payment-system main
```

**Результат**:
- Создаёт `../project-worktrees/feature-name/`
- Создаёт ветку `feature-name`
- Копирует конфиги из `.worktree-sync.json`

---

## `/worktree-list` — Список worktrees

**Что делает**: Показывает все активные worktrees.

```bash
/worktree-list
```

---

## `/worktree-remove` — Удалить worktree

**Что делает**: Удаляет worktree и опционально ветку.

```bash
/worktree-remove feature-name
```

---

## `/worktree-cleanup` — Очистка worktrees

**Что делает**: Удаляет устаревшие worktrees.

```bash
/worktree-cleanup
```

---

# Release & Utility

## `/push` — Автоматизация релизов

**Что делает**: Бампит версию, обновляет CHANGELOG, создаёт тег и пушит.

```bash
/push patch    # 1.0.0 → 1.0.1 (багфиксы)
/push minor    # 1.0.0 → 1.1.0 (новые фичи)
/push major    # 1.0.0 → 2.0.0 (breaking changes)
/push          # автоопределение по коммитам
```

**Особенности**:
- Синхронизирует версию с последним тегом
- Анализирует conventional commits
- Генерирует CHANGELOG
- Откат при ошибках

---

## `/translate-doc` — Перевод документации

**Что делает**: Переводит документацию с английского на русский.

```bash
/translate-doc docs/README.md
```

**Сохраняет**:
- Markdown форматирование
- Код без изменений
- Технические термины

---

# Полная структура проекта

```
project/
├── .claude/
│   ├── commands/              # Slash команды
│   │   ├── speckit.*.md       # Spec-Kit (9 файлов)
│   │   ├── health-*.md        # Health (6 файлов)
│   │   ├── worktree-*.md      # Worktree (4 файла)
│   │   ├── push.md            # Release
│   │   └── translate-doc.md   # Utility
│   ├── agents/                # Субагенты
│   │   ├── workers/
│   │   └── orchestrators/
│   ├── skills/                # Навыки (reusable)
│   └── scripts/               # Bash скрипты
│       └── release.sh
├── .specify/
│   ├── memory/
│   │   └── constitution.md
│   ├── templates/
│   └── scripts/bash/
├── specs/                     # Спецификации фич
│   └── 1-feature-name/
├── docs/
│   └── SPECKIT-GUIDE.md       # Это руководство
└── .worktree-sync.json        # Конфиг для worktrees
```

---

## Ссылки

- [GitHub Spec-Kit](https://github.com/github/spec-kit)
- [Spec-Driven Development Guide](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [Claude Code Orchestrator Kit](https://github.com/maslennikov-ig/claude-code-orchestrator-kit)
