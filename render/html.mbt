// HTML renderer: walks the AST and produces HTML output.

pub fn render_block(block : @types.Block) -> String {
  match block {
    @types.Block::Document(children) => render_blocks(children)
    @types.Block::Paragraph(inlines) => {
      "<p>" + render_inlines(inlines) + "</p>\n"
    }
    @types.Block::Heading(level, inlines) => {
      let tag = "h" + level.to_string()
      "<" + tag + ">" + render_inlines(inlines) + "</" + tag + ">\n"
    }
    @types.Block::FencedCodeBlock(info, content) => {
      let escaped = @util.escape_html(content)
      if info == "" {
        "<pre><code>" + escaped + "</code></pre>\n"
      } else {
        "<pre><code class=\"language-" + info + "\">" + escaped + "</code></pre>\n"
      }
    }
    @types.Block::IndentedCodeBlock(content) => {
      "<pre><code>" + @util.escape_html(content) + "</code></pre>\n"
    }
    @types.Block::BlockQuote(children) => {
      "<blockquote>\n" + render_blocks(children) + "</blockquote>\n"
    }
    @types.Block::List(start, tight, _marker, items) => {
      let tag = if start.is_some() { "ol" } else { "ul" }
      let start_attr = match start {
        Some(n) => " start=\"" + n.to_string() + "\""
        _ => ""
      }
      let mut html = "<" + tag + start_attr + ">\n"
      let mut i = 0
      while i < items.length() {
        html = html + render_block(items[i])
        i = i + 1
      }
      html = html + "</" + tag + ">\n"
      html
    }
    @types.Block::ListItem(children) => {
      "<li>" + render_blocks_inline(children) + "</li>\n"
    }
    @types.Block::ThematicBreak => "<hr />\n"
    @types.Block::HTMLBlock(content) => content + "\n"
    @types.Block::LinkReferenceDefinition(_, _, _) => ""
  }
}

fn render_blocks(blocks : Array[@types.Block]) -> String {
  let mut html = ""
  let mut i = 0
  while i < blocks.length() {
    html = html + render_block(blocks[i])
    i = i + 1
  }
  html
}

fn render_blocks_inline(blocks : Array[@types.Block]) -> String {
  let mut html = ""
  let mut i = 0
  while i < blocks.length() {
    let block_html = render_block(blocks[i])
    // Strip trailing newline for inline context
    if block_html != "" {
      if block_html[block_html.length() - 1] == '\n' {
        html = html + block_html.substring(start=0, end=block_html.length() - 1)
      } else {
        html = html + block_html
      }
    }
    i = i + 1
  }
  html
}

pub fn render_inlines(inlines : Array[@types.Inline]) -> String {
  let mut html = ""
  let mut i = 0
  while i < inlines.length() {
    html = html + render_inline(inlines[i])
    i = i + 1
  }
  html
}

fn render_inline(inline : @types.Inline) -> String {
  match inline {
    @types.Inline::Text(content) => @util.escape_html(content)
    @types.Inline::CodeSpan(content) => "<code>" + @util.escape_html(content) + "</code>"
    @types.Inline::Emphasis(children) => "<em>" + render_inlines(children) + "</em>"
    @types.Inline::Strong(children) => "<strong>" + render_inlines(children) + "</strong>"
    @types.Inline::Link(children, url, title) => {
      let title_attr = match title {
        Some(t) => " title=\"" + @util.escape_html(t) + "\""
        _ => ""
      }
      "<a href=\"" + @util.escape_html(url) + "\"" + title_attr + ">" + render_inlines(children) + "</a>"
    }
    @types.Inline::Image(alt, url, title) => {
      let title_attr = match title {
        Some(t) => " title=\"" + @util.escape_html(t) + "\""
        _ => ""
      }
      "<img src=\"" + @util.escape_html(url) + "\" alt=\"" + render_inlines(alt) + "\"" + title_attr + " />"
    }
    @types.Inline::HardBreak => "<br />\n"
    @types.Inline::SoftBreak => "\n"
    @types.Inline::RawHTML(content) => content
    @types.Inline::HtmlEntity(content) => content
    @types.Inline::Autolink(url) => "<a href=\"" + @util.escape_html(url) + "\">" + @util.escape_html(url) + "</a>"
    @types.Inline::Strikethrough(children) => "<del>" + render_inlines(children) + "</del>"
  }
}

// Convenience: parse + render in one call.
pub fn md_to_html(input : String) -> String {
  let lines = @util.scan_lines(input)
  let ast = @block.parse_blocks(lines)
  render_block(ast)
}
