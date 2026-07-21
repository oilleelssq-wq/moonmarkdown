/// Shared types and configuration options for the Markdown parser.

///|
/// CSS class preset used by the HTML renderer.
pub(all) enum CssPreset {
  None
  Default
  Bootstrap
}

///|
/// Controls parsing and rendering behavior.
pub(all) struct MarkdownOptions {
  /// Enable GFM extensions (tables, task lists, strikethrough)
  gfm : Bool
  /// Enable smart punctuation (quotes, dashes)
  smart : Bool
  /// Allow raw HTML blocks and inline HTML passthrough
  html : Bool
  /// Decode HTML entities in inline text
  entities : Bool
  /// Resolve reference-style links
  reference_links : Bool
  /// Enable syntax highlighting for fenced code blocks
  highlight : Bool
  /// CSS class preset for rendered HTML elements
  css : CssPreset
}

///|
/// Create a MarkdownOptions with all extensions disabled.
pub fn MarkdownOptions::default() -> MarkdownOptions {
  {
    gfm: false,
    smart: false,
    html: true,
    entities: true,
    reference_links: true,
    highlight: false,
    css: CssPreset::None,
  }
}

///|
/// Create a MarkdownOptions with GFM extensions enabled.
pub fn MarkdownOptions::gfm() -> MarkdownOptions {
  { ..MarkdownOptions::default(), gfm: true }
}

///|
/// Return a copy with syntax highlighting enabled or disabled.
pub fn MarkdownOptions::with_highlight(
  self : MarkdownOptions,
  highlight : Bool,
) -> MarkdownOptions {
  { ..self, highlight, }
}

///|
/// Return a copy with raw HTML passthrough enabled or disabled.
pub fn MarkdownOptions::with_html(
  self : MarkdownOptions,
  html : Bool,
) -> MarkdownOptions {
  { ..self, html, }
}

///|
/// Return a copy with a CSS class preset.
pub fn MarkdownOptions::with_css(
  self : MarkdownOptions,
  css : CssPreset,
) -> MarkdownOptions {
  { ..self, css, }
}

///|
/// Create a MarkdownOptions with the default CSS class preset.
pub fn MarkdownOptions::with_default_css(
  self : MarkdownOptions,
) -> MarkdownOptions {
  self.with_css(CssPreset::Default)
}

///|
/// Create a MarkdownOptions with the Bootstrap CSS class preset.
pub fn MarkdownOptions::with_bootstrap_css(
  self : MarkdownOptions,
) -> MarkdownOptions {
  self.with_css(CssPreset::Bootstrap)
}
