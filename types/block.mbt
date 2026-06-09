// CommonMark Block-level AST node types.

pub(all) enum Block {
  Document(Array[Block])
  BlockQuote(Array[Block])
  ListItem(Array[Block])
  // start=None is unordered; start=Some(n) is ordered; marker: - * + or . )
  List(Int?, Bool, UInt16, Array[Block])
  Paragraph(Array[Inline])
  // level, inline children
  Heading(Int, Array[Inline])
  // info string, raw content
  FencedCodeBlock(String, String)
  IndentedCodeBlock(String)
  ThematicBreak
  HTMLBlock(String)
  // normalized label, url, optional title
  LinkReferenceDefinition(String, String, String?)
}
