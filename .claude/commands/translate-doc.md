---
description: Translate documentation file from English to Russian
allowed-tools: Read, Write
---

# /translate-doc command

## Syntax

/translate-doc {file_path}

## Your task

You are translating technical documentation from English to Russian for developers.

### Step 1: Read Source File

Read the English documentation file specified by the user:
- Use Read tool with the provided file_path
- Verify file exists and is readable
- If file not found, report error and stop

### Step 2: Translate to Russian

Translate the content while preserving structure and accuracy:

**Preserve**:
- Markdown formatting (headers, lists, tables, code blocks)
- Code blocks UNCHANGED (do not translate code)
- Technical terms accuracy (orchestrator, worker, quality gate)
- Links and URLs UNCHANGED
- File paths and commands UNCHANGED
- YAML frontmatter (if present)
- JSON examples UNCHANGED

**Translate**:
- All text content (paragraphs, descriptions)
- Headers and titles
- List items (except code)
- Table content (except code columns)

**Translation Guidelines**:
- Use professional technical Russian
- Maintain consistency with existing Russian docs
- Keep Claude Code terminology: agent, orchestrator, worker, quality gate
- Preserve tone and style (formal technical documentation)

### Step 3: Add Translation Header

At the top of the translated document (after YAML frontmatter if present), add:

> Warning: Automatic translation
> Translated from English: {source_file_path}
> Translation date: {YYYY-MM-DD}
> The original may contain more up-to-date information. In case of discrepancies, use the English version.

### Step 4: Save Translated File

Save the translated content:
- Generate filename: {original_filename}.ru.md
- Save in the same directory as the source file
- Use Write tool with full path

Example:
- Source: docs/Agents Ecosystem/ARCHITECTURE.md
- Output: docs/Agents Ecosystem/ARCHITECTURE.ru.md

### Step 5: Report Completion

Inform the user:

Translation complete

Source: {source_file_path}
Output: {output_file_path}

Translation includes:
- N sections translated
- M code blocks preserved
- Translation header added

Note: Review the translation for technical accuracy, especially domain-specific terms.

## Examples

### Example 1: Basic usage

User: /translate-doc docs/Agents Ecosystem/ARCHITECTURE.md
Assistant: Translating document...
Output: docs/Agents Ecosystem/ARCHITECTURE.ru.md created

### Example 2: Error handling

User: /translate-doc docs/nonexistent.md
Assistant: Error: File not found at docs/nonexistent.md
