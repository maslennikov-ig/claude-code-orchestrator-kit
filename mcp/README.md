# MCP Configuration

## Текущая конфигурация

**File**: `/.mcp.json` (root directory)

Унифицированная конфигурация со всеми MCP серверами и креденшалами.

### ✅ Конфигурация

- **`.mcp.json` в git** - базовая конфигурация с env vars
- **Использует переменные окружения** - `${SUPABASE_PROJECT_REF}`, `${SUPABASE_ACCESS_TOKEN}`
- **`.mcp.local.json`** - для локальных креденшалов (в .gitignore)

### Included Servers (6 серверов)
- **context7**: Documentation and code examples
- **sequential-thinking**: Deep problem analysis
- **supabase**: Database operations (с креденшалами)
- **playwright**: UI testing and automation
- **shadcn**: UI component generation
- **serena**: IDE assistant

## Auto-Optimization

Claude Code автоматически оптимизирует загрузку:
- Активация при >10K tokens
- 85% сокращение контекста
- On-demand загрузка серверов

## Использование

Просто запустите Claude Code в проекте:
```bash
cd /home/me/code/claude-code-orchestrator-kit
claude
```

Все креденшалы уже в конфигурации, дополнительная настройка не требуется.

## Legacy Configurations

Эта директория содержит старые конфигурации для reference:
- `.mcp.base.json` - минимальная конфигурация
- `.mcp.full.json` - все серверы
- `.mcp.frontend.json` - frontend subset
- `.mcp.supabase-*.json` - database configs

**Note**: Используйте `/.mcp.json` как основную конфигурацию.

## References

- [MCP Tool Search](https://www.anthropic.com/engineering/advanced-tool-use)
- [Claude Code MCP Docs](https://code.claude.com/docs/en/mcp)
