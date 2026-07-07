/// Shared types and configuration options for the Markdown parser.

///|
/// Controls parsing and rendering behavior.
pub struct MarkdownOptions {
  /// Enable GFM extensions (tables, task lists, strikethrough)
  gfm : Bool
  /// Enable smart punctuation (quotes, dashes)
  smart : Bool
}

///|
/// Create a MarkdownOptions with all extensions disabled.
pub fn MarkdownOptions::default() -> MarkdownOptions {
  { gfm: false, smart: false }
}

///|
/// Create a MarkdownOptions with GFM extensions enabled.
pub fn MarkdownOptions::gfm() -> MarkdownOptions {
  { gfm: true, smart: false }
}
