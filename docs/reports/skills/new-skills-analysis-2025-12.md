# Анализ новых скиллов (Декабрь 2025)

> Дата анализа: 2025-12-26
> Всего новых скиллов: 14

## Краткая сводка

| Категория | Кол-во | Полезность для проекта |
|-----------|--------|------------------------|
| Разработка и качество кода | 4 | Высокая |
| DevOps и инфраструктура | 2 | Высокая |
| UI/UX и дизайн | 4 | Средняя |
| Контент и исследования | 3 | Низкая |
| Нишевые (Move, Leads) | 2 | Не применимо |

---

## Детальный анализ

### 1. systematic-debugging

**Назначение:** Методология систематического дебага вместо "угадывания" фиксов.

**Ключевые особенности:**
- 4 фазы: Root Cause → Pattern Analysis → Hypothesis → Implementation
- Правило "3 фикса = пересмотр архитектуры"
- Трассировка данных в многокомпонентных системах

**Полезность: КРИТИЧЕСКИ ВЫСОКАЯ**

**Интеграция в проект:**
- **Заменяет/дополняет:** `problem-investigator` агент
- **Рекомендация:** Интегрировать как обязательный скилл для `bug-fixer` воркера
- **Как использовать:** Добавить ссылку в промпт bug-fixer: "Before fixing, apply systematic-debugging skill"

---

### 2. code-reviewer

**Назначение:** Автоматизированный code review с чек-листами и best practices.

**Ключевые особенности:**
- PR Analyzer, Code Quality Checker, Review Report Generator
- Референсы: checklist, coding standards, antipatterns

**Полезность: ВЫСОКАЯ**

**Интеграция в проект:**
- **Дублирует:** Существующий `code-reviewer` агент
- **Рекомендация:** ОБЪЕДИНИТЬ с агентом code-reviewer
- **Как:** Скилл содержит knowledge base, агент содержит execution logic. Агент должен ссылаться на скилл.

---

### 3. senior-devops

**Назначение:** CI/CD pipelines, Terraform, Kubernetes, deployment strategies.

**Ключевые особенности:**
- Pipeline Generator, Terraform Scaffolder, Deployment Manager
- Референсы по IaC, deployment strategies

**Полезность: ВЫСОКАЯ**

**Интеграция в проект:**
- **Дополняет:** `deployment-engineer` агент
- **Рекомендация:** Использовать как knowledge base для deployment-engineer
- **Как:** Добавить ссылку в агент: "Refer to senior-devops skill for CI/CD patterns"

---

### 4. senior-prompt-engineer

**Назначение:** LLM optimization, prompt patterns, RAG, agent design.

**Ключевые особенности:**
- Prompt optimization, RAG evaluation, agent orchestration
- Референсы: prompt patterns, LLM evaluation, agentic system design

**Полезность: ВЫСОКАЯ**

**Интеграция в проект:**
- **Дополняет:** `meta-agent-v3` (создание агентов)
- **Рекомендация:** Использовать при создании новых агентов и улучшении промптов
- **Как:** Ссылаться при написании/оптимизации agent prompts

---

### 5. webapp-testing

**Назначение:** Тестирование веб-приложений через Playwright.

**Ключевые особенности:**
- `with_server.py` - управление серверами
- Reconnaissance-then-action pattern
- Decision tree для выбора подхода

**Полезность: ВЫСОКАЯ**

**Интеграция в проект:**
- **Дополняет:** `integration-tester`, `mobile-responsiveness-tester`
- **Рекомендация:** Использовать для E2E тестирования
- **Как:** Добавить в workflow тестирования после `test-writer`

---

### 6. ui-design-system

**Назначение:** Генерация дизайн-токенов, responsive calculations.

**Ключевые особенности:**
- Design token generator (colors, typography, spacing)
- Component documentation
- Developer handoff

**Полезность: СРЕДНЯЯ**

**Интеграция в проект:**
- **Дополняет:** `nextjs-ui-designer`, `frontend-aesthetics`
- **Рекомендация:** Использовать для создания design system в новых проектах
- **Когда:** При старте нового frontend проекта

---

### 7. ux-researcher-designer

**Назначение:** UX research - personas, journey mapping, usability testing.

**Ключевые особенности:**
- Data-driven persona generation
- Customer journey mapping
- Research synthesis

**Полезность: НИЗКАЯ для текущего проекта**

**Интеграция в проект:**
- Не релевантен для CLI toolkit
- **Рекомендация:** Оставить для user-facing продуктов
- **Когда использовать:** При разработке пользовательских интерфейсов

---

### 8. content-research-writer

**Назначение:** Помощь в написании статей с research и citations.

**Ключевые особенности:**
- Collaborative outlining
- Research с citations
- Hook improvement
- Section-by-section feedback

**Полезность: НИЗКАЯ для текущего проекта**

**Интеграция в проект:**
- Не связан с разработкой
- **Рекомендация:** Использовать для документации и блог-постов
- **Дублирует:** Частично `article-writer-multi-platform`

---

### 9. lead-research-assistant

**Назначение:** Поиск лидов для продаж и business development.

**Полезность: НЕ ПРИМЕНИМО**

**Рекомендация:** УДАЛИТЬ из проекта
- Не связан с разработкой
- Не связан с agent orchestration
- Засоряет список скиллов

---

### 10. move-code-quality

**Назначение:** Code review для Move language (Sui blockchain).

**Полезность: НЕ ПРИМЕНИМО**

**Рекомендация:** УДАЛИТЬ из проекта
- Move - нишевый язык для blockchain
- Не связан с текущим tech stack (TypeScript, Next.js, Supabase)
- Очень специфичный use case

---

### 11. algorithmic-art

**Назначение:** Создание generative art через p5.js.

**Ключевые особенности:**
- Algorithmic philosophy creation
- p5.js implementation
- Seeded randomness (Art Blocks pattern)
- Interactive HTML artifacts

**Полезность: НИЗКАЯ**

**Интеграция в проект:**
- Не связан с разработкой tooling
- **Рекомендация:** Оставить для creative проектов
- **Пересечение:** С `visual-effects-creator` агентом (но разные цели)

---

### 12. theme-factory

**Назначение:** Применение готовых тем к артефактам (slides, docs, landing pages).

**Ключевые особенности:**
- 10 pre-set themes
- Color/font pairings
- Custom theme generation

**Полезность: НИЗКАЯ**

**Рекомендация:** Оставить для presentation/marketing задач

---

### 13. artifacts-builder

**Назначение:** Создание сложных HTML артефактов для claude.ai.

**Ключевые особенности:**
- React + TypeScript + Vite + Tailwind + shadcn/ui
- `init-artifact.sh` и `bundle-artifact.sh` скрипты
- Bundling в single HTML

**Полезность: СРЕДНЯЯ**

**Интеграция в проект:**
- Полезен для создания интерактивных демо
- **Рекомендация:** Использовать для документации и showcases
- **Когда:** При создании demo artifacts для README

---

### 14. canvas-design

**Назначение:** Создание визуального арта (.png, .pdf) через design philosophy.

**Ключевые особенности:**
- Design philosophy creation
- Canvas creation с typography
- Multi-page support

**Полезность: НИЗКАЯ**

**Рекомендация:** Оставить для creative/marketing задач

---

## Рекомендации по действиям

### Высокий приоритет: ИНТЕГРИРОВАТЬ

| Скилл | Действие | Целевой агент/место |
|-------|----------|---------------------|
| `systematic-debugging` | Добавить как обязательный reference | `bug-fixer`, `problem-investigator` |
| `senior-devops` | Объединить knowledge base | `deployment-engineer` |
| `senior-prompt-engineer` | Использовать при создании агентов | `meta-agent-v3` |
| `webapp-testing` | Добавить в test workflow | После `test-writer` |
| `code-reviewer` (skill) | Объединить с агентом | `code-reviewer` (agent) |

### Средний приоритет: ОСТАВИТЬ

| Скилл | Причина |
|-------|---------|
| `ui-design-system` | Полезен для frontend проектов |
| `artifacts-builder` | Полезен для демо и документации |
| `algorithmic-art` | Creative проекты |
| `theme-factory` | Presentations |
| `canvas-design` | Creative проекты |

### Низкий приоритет: РАССМОТРЕТЬ УДАЛЕНИЕ

| Скилл | Причина удаления |
|-------|------------------|
| `move-code-quality` | Нишевый blockchain язык, не наш stack |
| `lead-research-assistant` | Sales/BD, не связан с разработкой |
| `ux-researcher-designer` | UX research, не CLI toolkit |
| `content-research-writer` | Дублирует article-writer-multi-platform |

---

## План интеграции

### Фаза 1: Связать скиллы с агентами

```
bug-fixer agent
  └── references: systematic-debugging skill

deployment-engineer agent
  └── references: senior-devops skill

code-reviewer agent
  └── references: code-reviewer skill (merge knowledge)

meta-agent-v3 agent
  └── references: senior-prompt-engineer skill
```

### Фаза 2: Добавить в workflows

```
/health-bugs workflow:
  bug-hunter → bug-fixer (+ systematic-debugging) → verify

Test workflow:
  test-writer → webapp-testing → verify
```

### Фаза 3: Cleanup

Рассмотреть удаление:
- `move-code-quality` (нишевый)
- `lead-research-assistant` (не dev)

---

## Выводы

1. **5 скиллов** критически полезны и должны быть интегрированы с существующими агентами
2. **5 скиллов** полезны для специфических задач (creative, presentations)
3. **2 скилла** не релевантны проекту и могут быть удалены
4. **2 скилла** имеют частичное дублирование с существующими агентами

Главная ценность новых скиллов - **knowledge base** (best practices, checklists, patterns), который дополняет **execution logic** существующих агентов.
