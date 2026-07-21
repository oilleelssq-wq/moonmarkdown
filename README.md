# MoonMarkdown

A **CommonMark spec-compliant** Markdown to HTML parser written in pure MoonBit.

## Why MoonMarkdown?

MoonBit ecosystem has `@mizchi/markdown` (fast but 38% spec-compatible) and `Cmark.mbt` (C FFI wrapper). MoonMarkdown is the **first pure MoonBit implementation** targeting full CommonMark compliance.

## Features

- **Block elements**: ATX/Setext headings, paragraphs, fenced/indented code blocks, thematic breaks, blockquotes, ordered/unordered lists, HTML blocks, link reference definitions
- **Inline elements**: backslash escapes, code spans, emphasis (italic/bold/bold-italic), links, images, autolinks, HTML entities, hard/soft line breaks
- **GFM extensions**: tables (with alignment), task lists, strikethrough, bare URL autolinks
- **HTML rendering**: with entity escaping and customizable CSS classes
- **CLI tool**: convert Markdown files to HTML from command line
- **Zero dependencies**: pure MoonBit, compiles to Native/Wasm/JS

## Installation

```bash
moon add oilleelssq-wq/moonmarkdown
```

## Usage

### Library API

```moonbit
// One-liner: parse + render (default options)
let html = @moonmarkdown.md_to_html("# Hello\n\n**bold** text")

// Two-step: parse then render
let ast = @moonmarkdown.parse(input)
let html = @moonmarkdown.render(ast)

// With custom options
let options = @types.MarkdownOptions::gfm()
  .with_highlight(true)
  .with_css(@types.CssPreset::Default)

let ast = @moonmarkdown.parse_with_options(input, options)
let html = @moonmarkdown.render_with_options(ast, options)
// Or one step:
let html = @moonmarkdown.md_to_html_with_options(input, options)
```

### CLI

```bash
# Convert file to stdout
moon run cmd/main -- input.md

# Convert file and save to output
moon run cmd/main -- input.md -o output.html

# Enable GFM extensions (tables, strikethrough)
moon run cmd/main -- input.md --gfm

# Enable syntax highlighting in fenced code blocks
moon run cmd/main -- input.md --highlight

# Disable raw HTML passthrough
moon run cmd/main -- input.md --no-html

# Add CSS classes using a preset (none|default|bootstrap)
moon run cmd/main -- input.md --css default
```

## Examples

| Markdown | HTML Output |
|----------|-------------|
| `*italic*` | `<em>italic</em>` |
| `**bold**` | `<strong>bold</strong>` |
| `` `code` `` | `<code>code</code>` |
| `[link](url)` | `<a href="url">link</a>` |
| `\| a \| b \|` | `<table>...</table>` |

## Project Structure

```
moonmarkdown/
├── types/       # AST type definitions (Block, Inline)
├── util/        # Line scanner, character classification, HTML escape
├── block/       # Block-level parser
├── inline/      # Inline parser (emphasis, links, code spans)
├── render/      # HTML renderer
├── ext/         # GFM extensions (tables, task lists, strikethrough)
├── cmd/main/    # CLI entry point
├── tests/       # Test suite
└── docs/        # Competition materials
```

## License

MIT
