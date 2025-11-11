---
description: Create a new git worktree for parallel feature development
---

# Create Git Worktree

Создает новый git worktree для параллельной разработки фичи в изолированной директории.

**Что делает команда:**
- Создает папку `megacampus2-worktrees` рядом с основным проектом (если не существует)
- Создает новую ветку от текущей (main/develop)
- Создает worktree в отдельной директории
- Копирует файлы из `.gitignore` согласно `.worktree-sync.json` (env, config, vscode и др.)
- Выводит инструкции по работе с worktree

**Аргументы:**
- `<feature-name>` - название фичи (обязательно)
- `[base-branch]` - ветка-основа (опционально, по умолчанию текущая)

**Примеры:**
```bash
/worktree-create admin-panel
/worktree-create payment-system main
/worktree-create user-profile develop
```

---

## Your Task

### Step 1: Получение аргументов

Извлеки аргументы из запроса пользователя:
- `FEATURE_NAME` - название фичи (обязательный)
- `BASE_BRANCH` - ветка-основа (опциональный, по умолчанию текущая)

**Валидация:**
- FEATURE_NAME не должно быть пустым
- FEATURE_NAME должно содержать только буквы, цифры, дефисы
- Запроси подтверждение у пользователя перед созданием

---

### Step 2: Проверка окружения

Выполни проверки:

1. **Проверить текущую директорию**
   ```bash
   pwd
   # Должно быть: /home/me/code/megacampus2
   ```

2. **Проверить git статус**
   ```bash
   git status
   # Убедись, что нет uncommitted changes или предупреди пользователя
   ```

3. **Получить текущую ветку** (если BASE_BRANCH не указан)
   ```bash
   git branch --show-current
   ```

4. **Проверить, существует ли worktrees директория**
   ```bash
   ls -la ../megacampus2-worktrees 2>/dev/null || echo "NOT_EXISTS"
   ```

---

### Step 3: Создание структуры

1. **Создать worktrees директорию** (если не существует)
   ```bash
   mkdir -p ../megacampus2-worktrees
   ```

2. **Проверить, не существует ли уже worktree с таким именем**
   ```bash
   git worktree list
   # Проверь, нет ли уже ../megacampus2-worktrees/FEATURE_NAME
   ```

3. **Создать новый worktree**
   ```bash
   git worktree add ../megacampus2-worktrees/FEATURE_NAME -b feature/FEATURE_NAME BASE_BRANCH
   ```

   Где:
   - `../megacampus2-worktrees/FEATURE_NAME` - путь к новой директории
   - `-b feature/FEATURE_NAME` - создать новую ветку с префиксом `feature/`
   - `BASE_BRANCH` - ветка-основа (main, develop или текущая)

---

### Step 4: Синхронизация файлов из .gitignore

1. **Прочитать конфигурацию синхронизации**
   ```bash
   # Проверить существование .worktree-sync.json
   if [ -f .worktree-sync.json ]; then
     echo "✅ Найден .worktree-sync.json"
   else
     echo "⚠️ .worktree-sync.json не найден, пропускаем синхронизацию"
   fi
   ```

2. **Извлечь списки для синхронизации**

   Используй jq или прямое чтение JSON для получения:
   - `sync.files` - отдельные файлы
   - `sync.directories` - директории целиком
   - `sync.patterns` - glob паттерны

3. **Скопировать файлы из sync.files**
   ```bash
   # Для каждого файла в sync.files
   for file in .env .env.local .env.development .env.test .env.production .mcp.json .mcp.local.json; do
     if [ -f "$file" ]; then
       cp "$file" "../megacampus2-worktrees/FEATURE_NAME/$file"
       echo "✅ Скопирован: $file"
     fi
   done
   ```

4. **Скопировать директории из sync.directories**
   ```bash
   # Для каждой директории в sync.directories
   for dir in .vscode; do
     if [ -d "$dir" ]; then
       cp -r "$dir" "../megacampus2-worktrees/FEATURE_NAME/$dir"
       echo "✅ Скопирована директория: $dir"
     fi
   done
   ```

5. **Скопировать файлы по паттернам из sync.patterns**
   ```bash
   # packages/*/.env
   find packages -maxdepth 2 -name ".env" -o -name ".env.local" | while read file; do
     if [ -f "$file" ]; then
       # Создать директорию если нужно
       mkdir -p "../megacampus2-worktrees/FEATURE_NAME/$(dirname "$file")"
       cp "$file" "../megacampus2-worktrees/FEATURE_NAME/$file"
       echo "✅ Скопирован: $file"
     fi
   done

   # courseai-next/.env.local
   if [ -f courseai-next/.env.local ]; then
     mkdir -p "../megacampus2-worktrees/FEATURE_NAME/courseai-next"
     cp courseai-next/.env.local "../megacampus2-worktrees/FEATURE_NAME/courseai-next/.env.local"
     echo "✅ Скопирован: courseai-next/.env.local"
   fi

   # services/*/.env
   find services -maxdepth 2 -name ".env" | while read file; do
     if [ -f "$file" ]; then
       mkdir -p "../megacampus2-worktrees/FEATURE_NAME/$(dirname "$file")"
       cp "$file" "../megacampus2-worktrees/FEATURE_NAME/$file"
       echo "✅ Скопирован: $file"
     fi
   done
   ```

6. **Вывести отчет о синхронизации**
   ```bash
   echo ""
   echo "📦 Синхронизировано файлов: N"
   echo "📁 Синхронизировано директорий: N"
   ```

2. **Проверить созданный worktree**
   ```bash
   git worktree list
   ```

---

### Step 5: Вывод информации

После успешного создания выведи пользователю:

```markdown
✅ Worktree успешно создан!

📁 **Расположение:**
- Основной проект: `/home/me/code/megacampus2`
- Новый worktree: `/home/me/code/megacampus2-worktrees/FEATURE_NAME`

🌿 **Ветка:**
- Название: `feature/FEATURE_NAME`
- Основа: `BASE_BRANCH`

📦 **Синхронизировано:**
- Файлов: N (.env, .mcp.json и др.)
- Директорий: N (.vscode и др.)
- Конфигурация: `.worktree-sync.json`

📋 **Следующие шаги:**

1. Открой новый worktree в отдельном окне IDE:
   ```bash
   cd ../megacampus2-worktrees/FEATURE_NAME
   code .  # или другой редактор
   ```

2. Начни работу над фичей в новой ветке

3. Когда закончишь:
   ```bash
   git add .
   git commit -m "feat: описание изменений"
   git push -u origin feature/FEATURE_NAME
   ```

4. Создай Pull Request на GitHub

5. После мерджа удали worktree:
   ```bash
   /worktree-remove FEATURE_NAME
   ```

💡 **Полезные команды:**
- `/worktree-list` - список всех worktrees
- `/worktree-remove FEATURE_NAME` - удалить worktree
- `/worktree-cleanup` - очистить устаревшие worktrees

⚠️ **Важно:**
- Каждый worktree должен быть на своей ветке
- Нельзя checkout одну ветку в разных worktrees
- Основной проект остается на своей ветке
```

---

## Обработка ошибок

**Если worktree уже существует:**
```
❌ Worktree с именем "FEATURE_NAME" уже существует!

Существующие worktrees:
[вывод git worktree list]

Варианты:
1. Используй другое имя: /worktree-create FEATURE_NAME-v2
2. Удали существующий: /worktree-remove FEATURE_NAME
3. Используй существующий worktree
```

**Если ветка уже существует:**
```
❌ Ветка "feature/FEATURE_NAME" уже существует!

Варианты:
1. Checkout существующей ветки:
   git worktree add ../megacampus2-worktrees/FEATURE_NAME feature/FEATURE_NAME

2. Используй другое имя ветки
3. Удали старую ветку: git branch -d feature/FEATURE_NAME
```

**Если есть uncommitted changes:**
```
⚠️ У тебя есть незакоммиченные изменения!

git status:
[вывод]

Рекомендация:
1. Commit изменения: git commit -am "WIP"
2. Или stash: git stash
3. Или продолжить создание worktree (безопасно, изменения останутся в основном worktree)

Продолжить? (yes/no)
```

---

## Примечания

- Worktrees используют один `.git` репозиторий → экономия места
- Можно работать над несколькими фичами параллельно
- Идеально подходит для AI-разработки с Claude Code
- После создания worktree можно открыть новое окно Claude Code в новой директории
