///|
/// Whitebox tests for HTML renderer.
test "render_block document empty" {
  let doc = @types.Block::Document([])
  assert_eq(render_block(doc), "")
}

///|
test "render_block thematic break" {
  let block = @types.Block::ThematicBreak
  assert_eq(render_block(block), "<hr />\n")
}

///|
test "render_block heading 1" {
  let inlines = [@types.Inline::Text("Title")]
  let block = @types.Block::Heading(1, inlines)
  assert_eq(render_block(block), "<h1>Title</h1>\n")
}

///|
test "render_block heading 3" {
  let inlines = [@types.Inline::Text("Section")]
  let block = @types.Block::Heading(3, inlines)
  assert_eq(render_block(block), "<h3>Section</h3>\n")
}

///|
test "render_block paragraph" {
  let inlines = [@types.Inline::Text("Hello")]
  let block = @types.Block::Paragraph(inlines)
  assert_eq(render_block(block), "<p>Hello</p>\n")
}

///|
test "render_block paragraph empty" {
  let block = @types.Block::Paragraph([])
  assert_eq(render_block(block), "<p></p>\n")
}

///|
test "render_block fenced code" {
  let block = @types.Block::FencedCodeBlock("", "let x = 1")
  assert_eq(render_block(block), "<pre><code>let x = 1</code></pre>\n")
}

///|
test "render_block fenced code with info" {
  let block = @types.Block::FencedCodeBlock("moonbit", "fn main {}")
  assert_eq(
    render_block(block),
    "<pre><code class=\"language-moonbit\">fn main {}</code></pre>\n",
  )
}

///|
test "render_block indented code" {
  let block = @types.Block::IndentedCodeBlock("code")
  assert_eq(render_block(block), "<pre><code>code</code></pre>\n")
}

///|
test "render_block blockquote" {
  let inner = [@types.Block::Paragraph([@types.Inline::Text("q")])]
  let block = @types.Block::BlockQuote(inner)
  assert_eq(render_block(block), "<blockquote>\n<p>q</p>\n</blockquote>\n")
}

///|
test "render_block unordered list" {
  let items = [
    @types.Block::ListItem([@types.Block::Paragraph([@types.Inline::Text("a")])]),
    @types.Block::ListItem([@types.Block::Paragraph([@types.Inline::Text("b")])]),
  ]
  let block = @types.Block::List(None, true, '-', items)
  let html = render_block(block)
  assert_eq(html.contains("<ul>"), true)
  assert_eq(html.contains("<li>"), true)
  assert_eq(html.contains("</ul>"), true)
}

///|
test "render_block ordered list" {
  let items = [
    @types.Block::ListItem([@types.Block::Paragraph([@types.Inline::Text("1")])]),
  ]
  let block = @types.Block::List(Some(1), true, '.', items)
  let html = render_block(block)
  assert_eq(html.contains("<ol start=\"1\">"), true)
}

///|
test "render_block HTML block" {
  let block = @types.Block::HTMLBlock("<div>raw</div>")
  assert_eq(render_block(block), "<div>raw</div>\n")
}

///|
test "render_block LRD (not rendered)" {
  let block = @types.Block::LinkReferenceDefinition("lbl", "url", None)
  assert_eq(render_block(block), "")
}

///|
test "render_inlines text (escaped)" {
  let inlines = [@types.Inline::Text("<>&\"")]
  let html = render_inlines(inlines)
  assert_eq(html.contains("&lt;"), true)
  assert_eq(html.contains("&gt;"), true)
  assert_eq(html.contains("&amp;"), true)
  assert_eq(html.contains("&quot;"), true)
}

///|
test "render_inlines emphasis" {
  let inlines = [@types.Inline::Emphasis([@types.Inline::Text("hi")])]
  assert_eq(render_inlines(inlines), "<em>hi</em>")
}

///|
test "render_inlines strong" {
  let inlines = [@types.Inline::Strong([@types.Inline::Text("hi")])]
  assert_eq(render_inlines(inlines), "<strong>hi</strong>")
}

///|
test "render_inlines code span" {
  let inlines = [@types.Inline::CodeSpan("x < 1")]
  let html = render_inlines(inlines)
  assert_eq(html, "<code>x &lt; 1</code>")
}

///|
test "render_inlines link" {
  let inlines = [
    @types.Inline::Link([@types.Inline::Text("click")], "https://x.com", None),
  ]
  assert_eq(render_inlines(inlines), "<a href=\"https://x.com\">click</a>")
}

///|
test "render_inlines link with title" {
  let inlines = [
    @types.Inline::Link([@types.Inline::Text("x")], "/", Some("tip")),
  ]
  assert_eq(render_inlines(inlines), "<a href=\"/\" title=\"tip\">x</a>")
}

///|
test "render_inlines image" {
  let alt = [@types.Inline::Text("photo")]
  let inlines = [@types.Inline::Image(alt, "/a.png", None)]
  assert_eq(render_inlines(inlines), "<img src=\"/a.png\" alt=\"photo\" />")
}

///|
test "render_inlines hard break" {
  let inlines = [@types.Inline::HardBreak]
  assert_eq(render_inlines(inlines), "<br />\n")
}

///|
test "render_inlines soft break" {
  let inlines = [@types.Inline::SoftBreak]
  assert_eq(render_inlines(inlines), "\n")
}

///|
test "render_inlines autolink" {
  let inlines = [@types.Inline::Autolink("https://x.com")]
  assert_eq(
    render_inlines(inlines),
    "<a href=\"https://x.com\">https://x.com</a>",
  )
}

///|
test "render_inlines raw HTML" {
  let inlines = [@types.Inline::RawHTML("<br>")]
  assert_eq(render_inlines(inlines), "<br>")
}

///|
test "render_inlines strikethrough" {
  let inlines = [@types.Inline::Strikethrough([@types.Inline::Text("old")])]
  assert_eq(render_inlines(inlines), "<del>old</del>")
}

///|
test "md_to_html simple" {
  assert_eq(md_to_html("hi"), "<p>hi</p>\n")
}

///|
test "md_to_html heading" {
  assert_eq(md_to_html("# T"), "<h1>T</h1>\n")
}
