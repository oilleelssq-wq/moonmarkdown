// CommonMark Inline-level AST node types.

pub(all) enum Inline {
  Text(String)
  CodeSpan(String)
  Emphasis(Array[Inline])
  Strong(Array[Inline])
  // children, url, optional title
  Link(Array[Inline], String, String?)
  // alt text, url, optional title
  Image(Array[Inline], String, String?)
  HardBreak
  SoftBreak
  RawHTML(String)
  HtmlEntity(String)
  Autolink(String)
  // GFM extension
  Strikethrough(Array[Inline])
}
