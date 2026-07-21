/// HTML renderer: walks the parsed AST and produces HTML output.

///|
pub fn render_block(block : @types.Block) -> String {
  render_block_with_options(block, @types.MarkdownOptions::default())
}

///|
pub fn render_block_with_options(
  block : @types.Block,
  options : @types.MarkdownOptions,
) -> String {
  let css = css_for_options(options)
  match block {
    @types.Block::Document(children) => render_blocks(children, options)
    @types.Block::Paragraph(inlines) =>
      "<p" +
      class_attr(css.paragraph) +
      ">" +
      render_inlines_with_options(inlines, options) +
      "</p>\n"
    @types.Block::Heading(level, inlines) => {
      let tag = "h" + level.to_string()
      "<" +
      tag +
      class_attr(heading_class(css, level)) +
      ">" +
      render_inlines_with_options(inlines, options) +
      "</" +
      tag +
      ">\n"
    }
    @types.Block::FencedCodeBlock(info, content) => {
      let rendered = if options.highlight && info != "" {
        highlight(content, first_info_word(info))
      } else {
        @util.escape_html(content)
      }
      "<pre" +
      class_attr(css.pre) +
      "><code" +
      code_class_attr(css.code, info) +
      ">" +
      rendered +
      "</code></pre>\n"
    }
    @types.Block::IndentedCodeBlock(content) =>
      "<pre" +
      class_attr(css.pre) +
      "><code" +
      class_attr(css.code) +
      ">" +
      @util.escape_html(content) +
      "</code></pre>\n"
    @types.Block::BlockQuote(children) =>
      "<blockquote" +
      class_attr(css.blockquote) +
      ">\n" +
      render_blocks(children, options) +
      "</blockquote>\n"
    @types.Block::List(start, _tight, _marker, items) => {
      let tag = if start is Some(_) { "ol" } else { "ul" }
      let start_attr = match start {
        Some(n) => " start=\"" + n.to_string() + "\""
        _ => ""
      }
      let list_class = if start is Some(_) {
        css.list_ordered
      } else {
        css.list_unordered
      }
      let mut html = "<" + tag + start_attr + class_attr(list_class) + ">\n"
      let mut i = 0
      while i < items.length() {
        html = html + render_block_with_options(items[i], options)
        i = i + 1
      }
      html = html + "</" + tag + ">\n"
      html
    }
    @types.Block::ListItem(children) =>
      "<li" +
      class_attr(css.list_item) +
      ">" +
      render_blocks_inline(children, options) +
      "</li>\n"
    @types.Block::ThematicBreak => "<hr />\n"
    @types.Block::HTMLBlock(content) =>
      if options.html {
        content + "\n"
      } else {
        @util.escape_html(content) + "\n"
      }
    @types.Block::LinkReferenceDefinition(_, _, _) => ""
  }
}

///|
fn render_blocks(
  blocks : Array[@types.Block],
  options : @types.MarkdownOptions,
) -> String {
  let mut html = ""
  let mut i = 0
  while i < blocks.length() {
    html = html + render_block_with_options(blocks[i], options)
    i = i + 1
  }
  html
}

///|
fn render_blocks_inline(
  blocks : Array[@types.Block],
  options : @types.MarkdownOptions,
) -> String {
  let mut html = ""
  let mut i = 0
  while i < blocks.length() {
    let block_html = render_block_with_options(blocks[i], options)
    if block_html != "" {
      if block_html[block_html.length() - 1] == '\n' {
        html = html + block_html[0:block_html.length() - 1].to_owned()
      } else {
        html = html + block_html
      }
    }
    i = i + 1
  }
  html
}

///|
pub fn render_inlines(inlines : Array[@types.Inline]) -> String {
  render_inlines_with_options(inlines, @types.MarkdownOptions::default())
}

///|
pub fn render_inlines_with_options(
  inlines : Array[@types.Inline],
  options : @types.MarkdownOptions,
) -> String {
  let mut html = ""
  let mut i = 0
  while i < inlines.length() {
    html = html + render_inline(inlines[i], options)
    i = i + 1
  }
  html
}

///|
fn render_inline(
  inline : @types.Inline,
  options : @types.MarkdownOptions,
) -> String {
  let css = css_for_options(options)
  match inline {
    @types.Inline::Text(content) => @util.escape_html(content)
    @types.Inline::CodeSpan(content) =>
      "<code" +
      class_attr(css.code) +
      ">" +
      @util.escape_html(content) +
      "</code>"
    @types.Inline::Emphasis(children) =>
      "<em" +
      class_attr(css.emphasis) +
      ">" +
      render_inlines_with_options(children, options) +
      "</em>"
    @types.Inline::Strong(children) =>
      "<strong" +
      class_attr(css.strong) +
      ">" +
      render_inlines_with_options(children, options) +
      "</strong>"
    @types.Inline::Link(children, url, title) => {
      let title_attr = match title {
        Some(t) => " title=\"" + @util.escape_html(t) + "\""
        _ => ""
      }
      "<a href=\"" +
      @util.escape_html(url) +
      "\"" +
      title_attr +
      class_attr(css.link) +
      ">" +
      render_inlines_with_options(children, options) +
      "</a>"
    }
    @types.Inline::Image(alt, url, title) => {
      let title_attr = match title {
        Some(t) => " title=\"" + @util.escape_html(t) + "\""
        _ => ""
      }
      "<img src=\"" +
      @util.escape_html(url) +
      "\" alt=\"" +
      render_inlines_with_options(alt, options) +
      "\"" +
      title_attr +
      class_attr(css.image) +
      " />"
    }
    @types.Inline::HardBreak => "<br />\n"
    @types.Inline::SoftBreak => "\n"
    @types.Inline::RawHTML(content) =>
      if options.html {
        content
      } else {
        @util.escape_html(content)
      }
    @types.Inline::HtmlEntity(content) => @util.escape_html(content)
    @types.Inline::Autolink(url) =>
      "<a href=\"" +
      @util.escape_html(url) +
      "\"" +
      class_attr(css.link) +
      ">" +
      @util.escape_html(url) +
      "</a>"
    @types.Inline::Strikethrough(children) =>
      "<del" +
      class_attr(css.strikethrough) +
      ">" +
      render_inlines_with_options(children, options) +
      "</del>"
  }
}

///|
fn css_for_options(options : @types.MarkdownOptions) -> CssClasses {
  match options.css {
    @types.CssPreset::None => CssClasses::default()
    @types.CssPreset::Default => CssClasses::semantic()
    @types.CssPreset::Bootstrap => CssClasses::bootstrap()
  }
}

///|
fn heading_class(css : CssClasses, level : Int) -> String {
  match level {
    1 => css.heading1
    2 => css.heading2
    3 => css.heading3
    4 => css.heading4
    5 => css.heading5
    _ => css.heading6
  }
}

///|
fn code_class_attr(css_class : String, info : String) -> String {
  let language = first_info_word(info)
  let classes = if language == "" {
    css_class
  } else if css_class == "" {
    "language-" + language
  } else {
    "language-" + language + " " + css_class
  }
  class_attr(classes)
}

///|
fn first_info_word(info : String) -> String {
  let trimmed = info.trim().to_owned()
  let mut i = 0
  while i < trimmed.length() && trimmed[i] != ' ' && trimmed[i] != '\t' {
    i = i + 1
  }
  trimmed[0:i].to_owned()
}

///|
pub fn md_to_html(input : String) -> String {
  let lines = @util.scan_lines(input)
  let ast = @block.parse_blocks(lines)
  render_block(ast)
}
