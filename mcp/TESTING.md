# Testing MCP Configuration

## Quick Test

1. **Restart Claude Code** to load new `.mcp.json`

2. **Test all servers** (should work automatically):
```bash
# Context7 - documentation search
"Найди документацию по React hooks"

# Sequential Thinking - deep analysis
"Проанализируй сложную проблему step-by-step"

# Supabase - database operations
"Покажи таблицы в Supabase проекте"

# Playwright - UI testing
"Открой браузер и протестируй UI"

# Shadcn - UI components
"Добавь компонент Button с shadcn"
```

## Expected Behavior

### ✅ Success Indicators
- All servers load without errors
- Tools available when needed (may have 1-2s delay on first use)
- No "tool not found" errors
- No "invalid settings" warnings

### ⚠️ Warning Signs
- "Unknown tool" errors (check server names)
- "Invalid settings" warnings (check JSON syntax)
- Servers fail to start (check environment variables)

## Measuring Auto-Optimization

Claude Code automatically optimizes when tools exceed 10K tokens:

1. Start new conversation
2. Note initial context usage
3. Use different tools throughout session
4. Observe on-demand loading (1-2s delay on first tool use)

**Expected**: Optimization activates automatically when threshold exceeded

## Troubleshooting

### Issue: "Unknown tool" error
**Fix**: Check server name in `.mcp.json` matches tool prefix

### Issue: "Invalid settings" warnings
**Fix**: Validate JSON syntax:
```bash
cat .mcp.json | jq .
```

### Issue: Supabase tools not loading
**Fix**: Check environment variables:
```bash
echo $SUPABASE_PROJECT_REF
echo $SUPABASE_ACCESS_TOKEN
```

### Issue: Docker-based n8n not starting
**Fix**: Verify Docker is running:
```bash
docker ps
```

### Issue: Context7 not available
**Fix**: Ensure network access for npx downloads

## Rollback

If issues occur, revert to minimal config:
```bash
cp mcp/.mcp.base.json .mcp.json
```

Then restart Claude Code.

## Performance Notes

| Configuration | All Servers | Auto-Optimization |
|--------------|-------------|-------------------|
| `.mcp.base.json` | 2 servers | Not triggered |
| `.mcp.json` (unified) | 8 servers | Triggers when >10K tokens |

**Result**: Same startup speed, full functionality, automatic optimization.

## Verification Checklist

After restart, verify:
- [ ] No "invalid settings" errors
- [ ] Context7 responds to documentation queries
- [ ] Sequential-thinking available for analysis
- [ ] Other tools load on first use
- [ ] No JSON syntax errors in config
