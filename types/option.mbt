// Shared types and options for the Markdown parser.

pub struct MarkdownOptions {
  gfm : Bool
  smart : Bool
}

pub fn MarkdownOptions::default() -> MarkdownOptions {
  { gfm: false, smart: false }
}

pub fn MarkdownOptions::gfm() -> MarkdownOptions {
  { gfm: true, smart: false }
}
