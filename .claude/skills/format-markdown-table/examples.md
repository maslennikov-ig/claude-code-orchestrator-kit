# Markdown Table Formatting Examples

## Basic Table

```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

## Alignment Examples

### Left-aligned (default)
```markdown
| Name   | Age | City      |
|--------|-----|-----------|
| Alice  | 30  | New York  |
| Bob    | 25  | Boston    |
```

### Center-aligned
```markdown
| Name   | Age | City      |
|:------:|:---:|:---------:|
| Alice  | 30  | New York  |
| Bob    | 25  | Boston    |
```

### Right-aligned
```markdown
| Name   | Age | City      |
|-------:|----:|----------:|
| Alice  | 30  | New York  |
| Bob    | 25  | Boston    |
```

### Mixed alignment
```markdown
| Name   | Age | City      |
|--------|----:|:---------:|
| Alice  | 30  | New York  |
| Bob    | 25  | Boston    |
```

## Complex Tables

### With Numbers
```markdown
| Metric           | Value | Change |
|------------------|------:|-------:|
| Revenue          | $2.5M |   +15% |
| Users            | 50K   |   +23% |
| Retention        | 85%   |    +3% |
```

### With Code
```markdown
| Function         | Returns | Description           |
|------------------|---------|----------------------|
| `parse()`        | Object  | Parse JSON string    |
| `stringify()`    | String  | Convert to JSON      |
| `validate()`     | Boolean | Check validity       |
```

### With Status Indicators
```markdown
| Task              | Status | Priority |
|-------------------|:------:|:--------:|
| Fix bug #123      |   ✅   |   P0     |
| Update docs       |   🔄   |   P2     |
| Refactor API      |   ❌   |   P1     |
```

## Tips

1. **Consistent Width**: Use spaces to align columns visually in source
2. **Minimum Width**: Each column should be at least 3 characters wide
3. **Padding**: Add 1 space on each side of cell content
4. **Headers**: Keep headers concise and clear
5. **Alignment**: Choose alignment based on content type:
   - Text: left-aligned
   - Numbers: right-aligned
   - Status/Icons: center-aligned
