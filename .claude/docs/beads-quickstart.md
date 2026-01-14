# Beads — Краткий справочник

> **Attribution**: [Beads](https://github.com/steveyegge/beads) — методология [Steve Yegge](https://github.com/steveyegge)

---

## SESSION CLOSE PROTOCOL (ОБЯЗАТЕЛЬНО!)

**НИКОГДА не говори "готово" без выполнения этих шагов:**

```bash
git status              # 1. Что изменилось?
git add <files>         # 2. Добавить код
bd sync                 # 3. Sync beads
git commit -m "... (PREFIX-xxx)"  # 4. Коммит с ID issue
bd sync                 # 5. Sync новые изменения
git push                # 6. Push в remote
```

**Работа НЕ завершена пока не сделан push!**

---

## Когда что использовать

| Сценарий | Инструмент | Команда |
|----------|------------|---------|
| Большая фича (>1 день) | Spec-kit → Beads | `/speckit.specify` → `/speckit.tobeads` |
| Маленькая фича (<1 день) | Beads | `bd create -t feature` |
| Баг | Beads | `bd create -t bug` |
| Tech debt | Beads | `bd create -t chore` |
| Исследование/spike | Beads formula | `bd mol wisp exploration` |
| Hotfix (срочно!) | Beads formula | `bd mol wisp hotfix` |
| Health check | Workflow | `bd mol wisp healthcheck` |
| Релиз | Workflow | `bd mol wisp release` |

---

## Сессия работы

```bash
# === СТАРТ ===
bd prime                    # Восстановить контекст
bd ready                    # Что доступно для работы?

# === РАБОТА ===
bd update ID --status in_progress   # Взять задачу
# ... делаем работу ...
bd close ID --reason "Описание"     # Закрыть задачу
/push patch                         # Коммит

# === КОНЕЦ (ОБЯЗАТЕЛЬНО) ===
bd sync                     # Синхронизация перед выходом
```

---

## Создание задач

### Базовая команда
```bash
bd create "Заголовок" -t тип -p приоритет -d "описание"
```

### Типы (-t)
| Тип | Когда |
|-----|-------|
| `feature` | Новая функциональность |
| `bug` | Исправление бага |
| `chore` | Tech debt, рефакторинг |
| `docs` | Документация |
| `test` | Тесты |
| `epic` | Группа связанных задач |

### Приоритеты (-p)
| P | Значение |
|---|----------|
| 0 | Критический — блокирует релиз |
| 1 | Критический |
| 2 | Высокий |
| 3 | Средний (по умолчанию) |
| 4 | Низкий / бэклог |

### Примеры
```bash
# Простая задача
bd create "Добавить кнопку logout" -t feature -p 3

# С описанием
bd create "DEBT-001: Рефакторинг" -t chore -p 2 -d "Подробнее..."

# Баг с ссылкой на источник
bd create "Кнопка не работает" -t bug -p 1 --deps discovered-from:PREFIX-abc
```

---

## Зависимости

```bash
# При создании
bd create "Задача" -t feature --deps ТИП:ID

# Добавить к существующей
bd dep add ISSUE DEPENDS_ON
```

| Тип зависимости | Значение |
|-----------------|----------|
| `blocks:X` | Эта задача блокирует X |
| `blocked-by:X` | Эта задача заблокирована X |
| `discovered-from:X` | Найдена при работе над X |
| `parent:X` | Дочерняя задача для epic X |

---

## Epic и иерархия

```bash
# Создать epic
bd create "User Authentication" -t epic -p 2

# Добавить дочерние задачи
bd create "Login form" -t feature --deps parent:PREFIX-epic-id
bd create "JWT tokens" -t feature --deps parent:PREFIX-epic-id

# Посмотреть структуру
bd show PREFIX-epic-id --tree
```

---

## Формулы (Workflows)

### Доступные формулы
```bash
bd formula list
```

| Formula | Назначение |
|---------|------------|
| `bigfeature` | Spec-kit → Beads для больших фич |
| `bugfix` | Стандартный процесс исправления |
| `hotfix` | Экстренное исправление |
| `techdebt` | Работа с техническим долгом |
| `healthcheck` | Аудит здоровья кодовой базы |
| `codereview` | Код-ревью с созданием issues |
| `release` | Процесс релиза версии |
| `exploration` | Исследование/spike |

### Запуск
```bash
# Эфемерный (wisp)
bd mol wisp exploration --vars "question=Как сделать X?"

# Постоянный (pour)
bd mol pour bigfeature --vars "feature_name=auth"
```

### Завершение wisp
```bash
bd mol squash WISP_ID  # Сохранить результат
bd mol burn WISP_ID    # Удалить без следа
```

---

## Exclusive Lock (multi-session)

```bash
# Терминал 1: захватил lock
bd update PREFIX-abc --status in_progress

# Терминал 2: найти незалоченные
bd list --unlocked
```

---

## Emergent work

```bash
# Нашёл баг во время работы
bd create "Найден баг: ..." -t bug --deps discovered-from:PREFIX-current

# Понял что нужна ещё одна задача
bd create "Также нужно..." -t feature --deps blocks:PREFIX-current
```

---

## Поиск и фильтрация

```bash
bd ready                    # Готовые к работе
bd list                     # Все открытые
bd list --all               # Включая закрытые
bd list -t bug              # Только баги
bd list -p 1                # Только P1
bd show ID                  # Детали задачи
bd show ID --tree           # С иерархией
```

---

## Управление задачами

```bash
# Изменить статус
bd update ID --status in_progress
bd update ID --status blocked
bd update ID --status open

# Изменить приоритет
bd update ID --priority 1

# Добавить метку
bd update ID --add-label security

# Закрыть
bd close ID --reason "Готово"
bd close ID1 ID2 ID3 --reason "Batch done"
```

---

## Диагностика

```bash
bd doctor     # Проверка здоровья
bd info       # Статус проекта
bd prime      # Контекст workflow
```

---

## Шпаргалка

```
┌──────────────────────────────────────────────────┐
│ СТАРТ     bd prime / bd ready                    │
│ ВЗЯТЬ     bd update ID --status in_progress      │
│ СОЗДАТЬ   bd create "..." -t type -p N           │
│ ЗАКРЫТЬ   bd close ID --reason "..."             │
├──────────────────────────────────────────────────┤
│ КОНЕЦ СЕССИИ (ВСЕ 6 ШАГОВ!)                      │
│   1. git status                                  │
│   2. git add <files>                             │
│   3. bd sync                                     │
│   4. git commit -m "... (PREFIX-xxx)"            │
│   5. bd sync                                     │
│   6. git push                                    │
├──────────────────────────────────────────────────┤
│ WORKFLOWS bd formula list                        │
│           bd mol wisp NAME --vars "k=v"          │
│           bd mol squash/burn WISP_ID             │
└──────────────────────────────────────────────────┘
```

---

## Ссылки

- [Beads GitHub](https://github.com/steveyegge/beads)
- [CLI Reference](https://github.com/steveyegge/beads/blob/main/docs/CLI_REFERENCE.md)
- [Molecules Guide](https://github.com/steveyegge/beads/blob/main/docs/MOLECULES.md)

---

*Beads — методология Steve Yegge. Адаптировано для Claude Code Orchestrator Kit.*
