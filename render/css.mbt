/// CSS class name customization for HTML rendering.
///
/// Allows users to inject custom CSS class names into rendered HTML
/// elements. This is useful for integrating with CSS frameworks like
/// Bootstrap or Tailwind.

///|
/// Map of HTML element names to CSS class strings.
pub(all) struct CssClasses {
  heading1 : String
  heading2 : String
  heading3 : String
  heading4 : String
  heading5 : String
  heading6 : String
  paragraph : String
  code : String
  pre : String
  blockquote : String
  list_ordered : String
  list_unordered : String
  list_item : String
  link : String
  image : String
  emphasis : String
  strong : String
  table : String
  table_header : String
  table_cell : String
  strikethrough : String
}

///|
/// Create a CssClasses with all empty values (no custom classes).
pub fn CssClasses::default() -> CssClasses {
  {
    heading1: "",
    heading2: "",
    heading3: "",
    heading4: "",
    heading5: "",
    heading6: "",
    paragraph: "",
    code: "",
    pre: "",
    blockquote: "",
    list_ordered: "",
    list_unordered: "",
    list_item: "",
    link: "",
    image: "",
    emphasis: "",
    strong: "",
    table: "",
    table_header: "",
    table_cell: "",
    strikethrough: "",
  }
}

///|
/// Create a CssClasses with semantic MoonMarkdown class names.
pub fn CssClasses::semantic() -> CssClasses {
  {
    heading1: "markdown-h1",
    heading2: "markdown-h2",
    heading3: "markdown-h3",
    heading4: "markdown-h4",
    heading5: "markdown-h5",
    heading6: "markdown-h6",
    paragraph: "markdown-paragraph",
    code: "markdown-code",
    pre: "markdown-pre",
    blockquote: "markdown-blockquote",
    list_ordered: "markdown-list-ordered",
    list_unordered: "markdown-list-unordered",
    list_item: "markdown-list-item",
    link: "markdown-link",
    image: "markdown-image",
    emphasis: "markdown-emphasis",
    strong: "markdown-strong",
    table: "markdown-table",
    table_header: "markdown-table-header",
    table_cell: "markdown-table-cell",
    strikethrough: "markdown-strikethrough",
  }
}

///|
/// Create a CssClasses preset for Bootstrap 5 compatibility.
pub fn CssClasses::bootstrap() -> CssClasses {
  {
    heading1: "display-4",
    heading2: "display-5",
    heading3: "display-6",
    heading4: "h4",
    heading5: "h5",
    heading6: "h6",
    paragraph: "",
    code: "code",
    pre: "",
    blockquote: "blockquote",
    list_ordered: "list-group list-group-numbered",
    list_unordered: "list-group",
    list_item: "list-group-item",
    link: "link-primary",
    image: "img-fluid",
    emphasis: "",
    strong: "fw-bold",
    table: "table table-striped",
    table_header: "",
    table_cell: "",
    strikethrough: "text-decoration-line-through",
  }
}

///|
/// Build a class attribute string from a CSS class name.
pub fn class_attr(name : String) -> String {
  if name == "" {
    ""
  } else {
    " class=\"" + name + "\""
  }
}
