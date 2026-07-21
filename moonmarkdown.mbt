/// MoonMarkdown — CommonMark spec-compliant Markdown to HTML parser.
///
/// # Quick Start
///
/// ```moonbit
/// let html = @moonmarkdown.md_to_html("# Hello\n\n**bold** text")
/// ```
///
/// # API Overview
///
/// - `parse(input)` — Parse Markdown source into an AST
/// - `render(ast)` — Render an AST to HTML
/// - `md_to_html(input)` — Convenience: parse + render in one call
///
/// # Features
///
/// - CommonMark block elements: headings, paragraphs, code blocks,
///   thematic breaks, blockquotes, lists, HTML blocks
/// - CommonMark inline elements: emphasis, strong, code spans,
///   links, images, autolinks, backslash escapes, line breaks
/// - GFM extensions: tables, task lists, strikethrough
/// - Syntax highlighting: MoonBit, JavaScript, Python, Rust
/// - Zero external dependencies, compiles to Native/Wasm/JS

///|
/// Parse Markdown source text into an AST.
///
/// Returns a `Block::Document` containing the top-level block nodes.
pub fn parse(input : String) -> @types.Block {
  parse_with_options(input, @types.MarkdownOptions::default())
}

///|
/// Parse Markdown source text into an AST with explicit options.
pub fn parse_with_options(
  input : String,
  options : @types.MarkdownOptions,
) -> @types.Block {
  let lines = @util.scan_lines(input)
  @block.parse_blocks_with_options(lines, options)
}

///|
/// Render an AST to HTML string.
///
/// Performs depth-first traversal of block and inline nodes
/// with automatic HTML entity escaping.
pub fn render(ast : @types.Block) -> String {
  render_with_options(ast, @types.MarkdownOptions::default())
}

///|
/// Render an AST to HTML string with explicit options.
pub fn render_with_options(
  ast : @types.Block,
  options : @types.MarkdownOptions,
) -> String {
  @render.render_block_with_options(ast, options)
}

///|
/// Parse Markdown and render to HTML in one call.
///
/// This is the simplest API for most use cases:
///
/// ```moonbit nocheck
/// let html = @moonmarkdown.md_to_html("*Hello* World")
/// // html == "<p><em>Hello</em> World</p>\n"
/// ```
pub fn md_to_html(input : String) -> String {
  md_to_html_with_options(input, @types.MarkdownOptions::default())
}

///|
/// Parse Markdown and render to HTML in one call with explicit options.
pub fn md_to_html_with_options(
  input : String,
  options : @types.MarkdownOptions,
) -> String {
  let ast = parse_with_options(input, options)
  render_with_options(ast, options)
}
