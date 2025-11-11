---
description: List all git worktrees with status information
---

# List Git Worktrees

Показывает список всех git worktrees с подробной информацией.

**Что делает команда:**
- Выводит все активные worktrees
- Показывает текущие ветки
- Отображает пути к директориям
- Указывает статус (main/linked/locked)
- Показывает последние коммиты

**Примеры:**
```bash
/worktree-list
```

---

## Your Task

### Step 1: Получение списка worktrees

1. **Получить список worktrees**
   ```bash
   git worktree list
   ```

2. **Получить подробную информацию**
   ```bash
   git worktree list --porcelain
   ```

---

### Step 2: Анализ worktrees

Для каждого worktree извлеки:
- Путь к директории
- Название ветки
- HEAD commit hash
- Статус (bare/detached/locked/prunable)

---

### Step 3: Форматирование вывода

Выведи красиво отформатированную таблицу:

```markdown
# Git Worktrees

## Активные worktrees: N

| Имя | Ветка | Путь | Статус | Последний коммит |
|-----|-------|------|--------|------------------|
| main (основной) | main | /home/me/code/megacampus2 | ✅ Active | abc1234 feat: ... |
| admin-panel | feature/admin-panel | /home/me/code/megacampus2-worktrees/admin-panel | ✅ Active | def5678 feat: ... |
| payment-system | feature/payment | /home/me/code/megacampus2-worktrees/payment-system | 🔒 Locked | ghi9012 fix: ... |

---

## Детали worktrees

### 1. main (основной worktree)
- **Путь:** `/home/me/code/megacampus2`
- **Ветка:** `main`
- **HEAD:** `abc1234`
- **Статус:** Main worktree (не может быть удален)
- **Последний коммит:**
  ```
  abc1234 (HEAD -> main, origin/main) feat: add user authentication
  Author: User Name <email>
  Date: 2025-01-07
  ```

### 2. admin-panel
- **Путь:** `/home/me/code/megacampus2-worktrees/admin-panel`
- **Ветка:** `feature/admin-panel`
- **HEAD:** `def5678`
- **Статус:** ✅ Active (linked worktree)
- **Последний коммит:**
  ```
  def5678 (HEAD -> feature/admin-panel) feat: add admin dashboard
  Author: User Name <email>
  Date: 2025-01-07
  ```
- **Как открыть:**
  ```bash
  cd ../megacampus2-worktrees/admin-panel
  code .
  ```

[... для каждого worktree ...]

---

## Статистика

- **Всего worktrees:** N
- **Основной:** 1
- **Linked worktrees:** N-1
- **Locked:** 0
- **Prunable:** 0

---

## Полезные команды

**Переключиться на worktree:**
```bash
cd /путь/к/worktree
```

**Удалить worktree:**
```bash
/worktree-remove <feature-name>
```

**Создать новый worktree:**
```bash
/worktree-create <feature-name>
```

**Очистить устаревшие worktrees:**
```bash
/worktree-cleanup
```

**Git команды:**
```bash
# Подробная информация
git worktree list --porcelain

# Заблокировать worktree
git worktree lock /путь/к/worktree --reason "Причина"

# Разблокировать worktree
git worktree unlock /путь/к/worktree
```
```

---

### Step 4: Дополнительная информация

Если найдены worktrees с проблемами:

**Locked worktrees:**
```markdown
⚠️ **Заблокированные worktrees:** N

- `feature-name` - причина блокировки

Разблокировать:
```bash
git worktree unlock ../megacampus2-worktrees/feature-name
```

**Prunable worktrees:**
```markdown
⚠️ **Устаревшие worktrees:** N

Эти worktrees были удалены, но административные файлы остались.

Очистить:
```bash
/worktree-cleanup
# или
git worktree prune
```

**Нет worktrees:**
```markdown
# Git Worktrees

📭 **Нет дополнительных worktrees**

У вас есть только основной worktree:
- Путь: `/home/me/code/megacampus2`
- Ветка: `current-branch`

**Создать новый worktree:**
```bash
/worktree-create <feature-name>
```

Примеры:
```bash
/worktree-create admin-panel
/worktree-create payment-system
/worktree-create user-profile
```

**Преимущества worktrees:**
- Работа над несколькими фичами параллельно
- Нет необходимости в stash/commit WIP
- Экономия места (общий .git)
- Быстрое переключение между задачами
```

---

## Обработка ошибок

**Если git worktree не доступен:**
```
❌ Команда git worktree недоступна

Проверьте версию Git:
```bash
git --version
# Требуется Git 2.5+
```

Обновите Git, если нужно.
```

**Если нет прав доступа:**
```
❌ Нет доступа к worktree директории

Проверьте права доступа:
```bash
ls -la ../megacampus2-worktrees/
```
```

---

## Примечания

- Основной worktree всегда первый в списке
- Locked worktrees нельзя удалить без unlock
- Prunable worktrees - это директории, которые были удалены вручную
- Каждый worktree на своей уникальной ветке
