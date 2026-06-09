// Blackbox tests for MoonMarkdown public API

test "ATX heading" {
  let result = @moonmarkdown.md_to_html("# Hello World")
  assert_eq!(result, "<h1>Hello World</h1>\n")
}

test "paragraph" {
  let result = @moonmarkdown.md_to_html("Hello World")
  assert_eq!(result, "<p>Hello World</p>\n")
}

test "thematic break" {
  let result = @moonmarkdown.md_to_html("---")
  assert_eq!(result, "<hr />\n")
}

test "fenced code block" {
  let src = "```\nlet x = 1\n```"
  let result = @moonmarkdown.md_to_html(src)
  assert_eq!(result, "<pre><code>let x = 1</code></pre>\n")
}

test "blockquote" {
  let result = @moonmarkdown.md_to_html("> quoted")
  assert_eq!(result, "<blockquote>\n<p>quoted</p>\n</blockquote>\n")
}

test "backslash escape" {
  let result = @moonmarkdown.md_to_html("\\*not italic\\*")
  assert_eq!(result, "<p>*not italic*</p>\n")
}

test "code span" {
  let result = @moonmarkdown.md_to_html("use `moon test` command")
  assert_eq!(result, "<p>use <code>moon test</code> command</p>\n")
}

test "HTML escaping" {
  let result = @moonmarkdown.md_to_html("a < b & c")
  assert_eq!(result, "<p>a &lt; b &amp; c</p>\n")
}

test "italic" {
  let result = @moonmarkdown.md_to_html("*italic text*")
  assert_eq!(result, "<p><em>italic text</em></p>\n")
}

test "bold" {
  let result = @moonmarkdown.md_to_html("**bold text**")
  assert_eq!(result, "<p><strong>bold text</strong></p>\n")
}

test "bold italic" {
  let result = @moonmarkdown.md_to_html("***bold italic***")
  assert_eq!(result, "<p><strong><em>bold italic</em></strong></p>\n")
}

test "link" {
  let result = @moonmarkdown.md_to_html("[MoonBit](https://moonbitlang.com)")
  assert_eq!(result, "<p><a href=\"https://moonbitlang.com\">MoonBit</a></p>\n")
}

test "autolink" {
  let result = @moonmarkdown.md_to_html("<https://example.com>")
  assert_eq!(result, "<p><a href=\"https://example.com\">https://example.com</a></p>\n")
}
