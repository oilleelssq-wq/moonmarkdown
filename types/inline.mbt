///|
/// CommonMark Inline-level AST node types.
///
/// Inline nodes represent formatted content within leaf blocks
/// (paragraphs, headings). The inline parser converts raw text
/// into a tree of these nodes.
///
/// # Node Types
///
/// ## Text and Code
/// - `Text` — plain text content (always HTML-escaped during rendering)
/// - `CodeSpan` — inline code (backtick-delimited)
///
/// ## Emphasis
/// - `Emphasis` — italic (`*text*` or `_text_`)
/// - `Strong` — bold (`**text**` or `__text__`)
/// - `Strikethrough` — deleted text (`~~text~~`, GFM extension)
///
/// ## Links and Media
/// - `Link` — hyperlink (`[text](url "title")`)
/// - `Image` — embedded image (`![alt](url "title")`)
/// - `Autolink` — bare URL/email (`<https://...>`)
///
/// ## Line Breaks
/// - `HardBreak` — explicit line break (backslash-newline)
/// - `SoftBreak` — implicit line break (newline in paragraph)
///
/// ## Raw Content
/// - `RawHTML` — inline HTML passed through unchanged
/// - `HtmlEntity` — decoded HTML entity reference
pub(all) enum Inline {
  /// Plain text. Always HTML-escaped during rendering.
  Text(String)
  /// Inline code span: `` `code` ``
  CodeSpan(String)
  /// Italic/emphasis: `*text*` or `_text_`
  Emphasis(Array[Inline])
  /// Bold/strong: `**text**` or `__text__`
  Strong(Array[Inline])
  /// Hyperlink: `[text](url "title")`
  /// Fields: children, url, optional title
  Link(Array[Inline], String, String?)
  /// Image: `![alt](url "title")`
  /// Fields: alt text, url, optional title
  Image(Array[Inline], String, String?)
  /// Explicit line break (backslash at end of line)
  HardBreak
  /// Implicit line break (newline within paragraph)
  SoftBreak
  /// Raw HTML tag passed through to output unchanged
  RawHTML(String)
  /// Decoded HTML entity (e.g. `&amp;` → `&`)
  HtmlEntity(String)
  /// Autolink: `<url>` or `<email>`
  Autolink(String)
  /// GFM strikethrough: `~~text~~`
  Strikethrough(Array[Inline])
}
