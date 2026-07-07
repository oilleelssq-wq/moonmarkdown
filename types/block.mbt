///|
/// CommonMark Block-level AST node types.
///
/// This enum represents all block-level constructs defined by the
/// CommonMark specification (0.31.2). Block nodes form the
/// structural skeleton of a parsed Markdown document.
///
/// # Variant Groups
///
/// ## Container Blocks
/// These blocks can contain other blocks as children:
/// - `Document` — the root node, contains all top-level blocks
/// - `BlockQuote` — quoted content, recursively contains blocks
/// - `ListItem` — a single list item, contains child blocks
/// - `List` — ordered or unordered list, contains list items
///
/// ## Leaf Blocks
/// These blocks contain inline content or raw text:
/// - `Paragraph` — regular text paragraph
/// - `Heading` — ATX or Setext heading
/// - `FencedCodeBlock` — code delimited by ``` or ~~~
/// - `IndentedCodeBlock` — code indented by 4+ spaces
/// - `ThematicBreak` — horizontal rule (`---`, `***`, `___`)
/// - `HTMLBlock` — raw HTML content
///
/// ## Meta Blocks
/// - `LinkReferenceDefinition` — parsed but not rendered directly
pub(all) enum Block {
  /// Root of the document tree.
  Document(Array[Block])
  /// Blockquote: `> content`
  BlockQuote(Array[Block])
  /// A single list item.
  ListItem(Array[Block])
  /// Ordered or unordered list.
  /// - `start`: None for unordered, Some(n) for ordered starting at n
  /// - `tight`: whether items are tightly spaced
  /// - `marker`: the bullet or delimiter character used
  List(Int?, Bool, UInt16, Array[Block])
  /// Paragraph containing inline content.
  Paragraph(Array[Inline])
  /// ATX or Setext heading.
  /// - `level`: 1-6
  Heading(Int, Array[Inline])
  /// Fenced code block (``` or ~~~).
  /// - `info`: info string after opening fence (e.g. "moonbit")
  /// - `content`: raw code content
  FencedCodeBlock(String, String)
  /// Indented code block (4+ spaces).
  IndentedCodeBlock(String)
  /// Horizontal rule / thematic break.
  ThematicBreak
  /// Raw HTML block content.
  HTMLBlock(String)
  /// Link reference definition: `[label]: url "title"`.
  /// Parsed during block phase, not rendered as HTML.
  LinkReferenceDefinition(String, String, String?)
}
