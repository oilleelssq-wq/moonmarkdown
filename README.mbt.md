# oilleelssq-wq/moonmarkdown

A CommonMark spec-compliant Markdown to HTML parser written in pure MoonBit.

## Quick start

```mbt check
///|
test "md_to_html" {
  let html = @moonmarkdown.md_to_html("# Hello\n\n**bold** text")
  inspect(html, content="<h1>Hello</h1>\n<p><strong>bold</strong> text</p>\n")
}
```
