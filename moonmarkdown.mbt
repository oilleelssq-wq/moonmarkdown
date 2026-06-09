// MoonMarkdown - CommonMark spec-compliant Markdown to HTML parser
//
// Public API

// Parse Markdown source to AST
pub fn parse(input : String) -> @types.Block {
  let lines = @util.scan_lines(input)
  @block.parse_blocks(lines)
}

// Render AST to HTML
pub fn render(ast : @types.Block) -> String {
  @render.render_block(ast)
}

// Convenience: parse and render in one call
pub fn md_to_html(input : String) -> String {
  render(parse(input))
}
