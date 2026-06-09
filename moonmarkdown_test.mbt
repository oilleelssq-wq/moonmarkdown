// Blackbox tests for MoonMarkdown public API

// --- Headings ---

test "ATX heading level 1" {
  let result = @moonmarkdown.md_to_html("# Hello World")
  assert_eq!(result, "<h1>Hello World</h1>\n")
}

test "ATX heading level 2" {
  let result = @moonmarkdown.md_to_html("## Section")
  assert_eq!(result, "<h2>Section</h2>\n")
}

test "ATX heading level 6" {
  let result = @moonmarkdown.md_to_html("###### Deep")
  assert_eq!(result, "<h6>Deep</h6>\n")
}

test "ATX heading with trailing # stripped" {
  let result = @moonmarkdown.md_to_html("## Heading ##")
  assert_eq!(result, "<h2>Heading</h2>\n")
}

test "not a heading (no space after #)" {
  let result = @moonmarkdown.md_to_html("#not-heading")
  assert_eq!(result, "<p>#not-heading</p>\n")
}

test "heading then paragraph" {
  let result = @moonmarkdown.md_to_html("# Title\n\ntext")
  assert_eq!(result, "<h1>Title</h1>\n<p>text</p>\n")
}

// --- Paragraphs ---

test "paragraph simple" {
  let result = @moonmarkdown.md_to_html("Hello World")
  assert_eq!(result, "<p>Hello World</p>\n")
}

test "paragraph with soft break" {
  let result = @moonmarkdown.md_to_html("line1\nline2")
  assert_eq!(result, "<p>line1\nline2</p>\n")
}

test "two paragraphs separated by blank" {
  let result = @moonmarkdown.md_to_html("first\n\nsecond")
  assert_eq!(result, "<p>first</p>\n<p>second</p>\n")
}

test "three paragraphs" {
  let result = @moonmarkdown.md_to_html("a\n\nb\n\nc")
  assert_eq!(result, "<p>a</p>\n<p>b</p>\n<p>c</p>\n")
}

// --- Thematic Break ---

test "thematic break with ---" {
  let result = @moonmarkdown.md_to_html("---")
  assert_eq!(result, "<hr />\n")
}

test "thematic break with ***" {
  let result = @moonmarkdown.md_to_html("***")
  assert_eq!(result, "<hr />\n")
}

test "thematic break with ___" {
  let result = @moonmarkdown.md_to_html("___")
  assert_eq!(result, "<hr />\n")
}

test "thematic break with spaces" {
  let result = @moonmarkdown.md_to_html("- - -")
  assert_eq!(result, "<hr />\n")
}

// --- Code Blocks ---

test "fenced code block backtick" {
  let src = "```\nlet x = 1\n```"
  let result = @moonmarkdown.md_to_html(src)
  assert_eq!(result, "<pre><code>let x = 1</code></pre>\n")
}

test "fenced code block with info" {
  let src = "```moonbit\nlet x = 1\n```"
  let result = @moonmarkdown.md_to_html(src)
  assert_eq!(result, "<pre><code class=\"language-moonbit\">let x = 1</code></pre>\n")
}

test "fenced code block tilde" {
  let src = "~~~\ncode block\n~~~"
  let result = @moonmarkdown.md_to_html(src)
  assert_eq!(result, "<pre><code>code block</code></pre>\n")
}

test "indented code block" {
  let result = @moonmarkdown.md_to_html("    indented")
  assert_eq!(result, "<pre><code>indented</code></pre>\n")
}

// --- Blockquote ---

test "blockquote single line" {
  let result = @moonmarkdown.md_to_html("> quoted")
  assert_eq!(result, "<blockquote>\n<p>quoted</p>\n</blockquote>\n")
}

test "blockquote multiline" {
  let result = @moonmarkdown.md_to_html("> line1\n> line2")
  assert_eq!(result, "<blockquote>\n<p>line1\nline2</p>\n</blockquote>\n")
}

test "blockquote with nested content" {
  let result = @moonmarkdown.md_to_html("> # heading in quote\n> text")
  assert_eq!(result, "<blockquote>\n<h1>heading in quote</h1>\n<p>text</p>\n</blockquote>\n")
}

// --- Lists ---

test "unordered list" {
  let result = @moonmarkdown.md_to_html("- a\n- b\n- c")
  assert_eq!(result, "<ul>\n<li><p>a</p></li>\n<li><p>b</p></li>\n<li><p>c</p></li>\n</ul>\n")
}

test "ordered list" {
  let result = @moonmarkdown.md_to_html("1. first\n2. second")
  assert_eq!(result, "<ol start=\"1\">\n<li><p>first</p></li>\n<li><p>second</p></li>\n</ol>\n")
}

test "ordered list with different start" {
  let result = @moonmarkdown.md_to_html("3. third\n4. fourth")
  assert_eq!(result, "<ol start=\"3\">\n<li><p>third</p></li>\n<li><p>fourth</p></li>\n</ol>\n")
}

test "asterisk list" {
  let result = @moonmarkdown.md_to_html("* apple\n* banana\n* cherry")
  assert_eq!(result, "<ul>\n<li><p>apple</p></li>\n<li><p>banana</p></li>\n<li><p>cherry</p></li>\n</ul>\n")
}

// --- Inline: Emphasis ---

test "italic with asterisk" {
  let result = @moonmarkdown.md_to_html("*italic text*")
  assert_eq!(result, "<p><em>italic text</em></p>\n")
}

test "italic with underscore" {
  let result = @moonmarkdown.md_to_html("_italic text_")
  assert_eq!(result, "<p><em>italic text</em></p>\n")
}

test "bold with double asterisk" {
  let result = @moonmarkdown.md_to_html("**bold text**")
  assert_eq!(result, "<p><strong>bold text</strong></p>\n")
}

test "bold with double underscore" {
  let result = @moonmarkdown.md_to_html("__bold text__")
  assert_eq!(result, "<p><strong>bold text</strong></p>\n")
}

test "bold italic triple asterisk" {
  let result = @moonmarkdown.md_to_html("***bold italic***")
  assert_eq!(result, "<p><strong><em>bold italic</em></strong></p>\n")
}

test "italic in middle of word" {
  let result = @moonmarkdown.md_to_html("un*frigging*believable")
  assert_eq!(result, "<p>un<em>frigging</em>believable</p>\n")
}

test "multiple emphasis spans" {
  let result = @moonmarkdown.md_to_html("**bold** and *italic*")
  assert_eq!(result, "<p><strong>bold</strong> and <em>italic</em></p>\n")
}

// --- Inline: Backslash Escape ---

test "backslash escape asterisk" {
  let result = @moonmarkdown.md_to_html("\\*not italic\\*")
  assert_eq!(result, "<p>*not italic*</p>\n")
}

test "backslash escape backtick" {
  let result = @moonmarkdown.md_to_html("\\`not code\\`")
  assert_eq!(result, "<p>`not code`</p>\n")
}

test "backslash escape backslash" {
  let result = @moonmarkdown.md_to_html("\\\\")
  assert_eq!(result, "<p>\\</p>\n")
}

test "backslash escape underscore" {
  let result = @moonmarkdown.md_to_html("\\_not italic\\_")
  assert_eq!(result, "<p>_not italic_</p>\n")
}

// --- Inline: Code Span ---

test "code span simple" {
  let result = @moonmarkdown.md_to_html("use `moon test` command")
  assert_eq!(result, "<p>use <code>moon test</code> command</p>\n")
}

test "code span with backticks inside" {
  let result = @moonmarkdown.md_to_html("`` `backtick` ``")
  assert_eq!(result, "<p><code>`backtick`</code></p>\n")
}

test "code span adjacent backticks" {
  let result = @moonmarkdown.md_to_html("`` `code` ``")
  assert_eq!(result, "<p><code>`code`</code></p>\n")
}

// --- Inline: Links ---

test "inline link" {
  let result = @moonmarkdown.md_to_html("[MoonBit](https://moonbitlang.com)")
  assert_eq!(result, "<p><a href=\"https://moonbitlang.com\">MoonBit</a></p>\n")
}

test "inline link with title" {
  let result = @moonmarkdown.md_to_html("[MoonBit](https://moonbitlang.com \"MoonBit Language\")")
  assert_eq!(result, "<p><a href=\"https://moonbitlang.com\" title=\"MoonBit Language\">MoonBit</a></p>\n")
}

test "inline link with angle brackets URL" {
  let result = @moonmarkdown.md_to_html("[link](<https://example.com>)")
  assert_eq!(result, "<p><a href=\"https://example.com\">link</a></p>\n")
}

// --- Inline: Images ---

test "image" {
  let result = @moonmarkdown.md_to_html("![alt text](/image.png)")
  assert_eq!(result, "<p><img src=\"/image.png\" alt=\"alt text\" /></p>\n")
}

test "image with title" {
  let result = @moonmarkdown.md_to_html("![alt](/img.png \"title\")")
  assert_eq!(result, "<p><img src=\"/img.png\" alt=\"alt\" title=\"title\" /></p>\n")
}

// --- Inline: Autolinks ---

test "autolink" {
  let result = @moonmarkdown.md_to_html("<https://example.com>")
  assert_eq!(result, "<p><a href=\"https://example.com\">https://example.com</a></p>\n")
}

test "autolink email" {
  let result = @moonmarkdown.md_to_html("<user@example.com>")
  assert_eq!(result, "<p><a href=\"user@example.com\">user@example.com</a></p>\n")
}

// --- HTML Escaping ---

test "HTML escaping ampersand" {
  let result = @moonmarkdown.md_to_html("a & b")
  assert_eq!(result, "<p>a &amp; b</p>\n")
}

test "HTML escaping less than" {
  let result = @moonmarkdown.md_to_html("a < b")
  assert_eq!(result, "<p>a &lt; b</p>\n")
}

test "HTML escaping greater than" {
  let result = @moonmarkdown.md_to_html("a > b")
  assert_eq!(result, "<p>a &gt; b</p>\n")
}

test "HTML escaping double quote" {
  let result = @moonmarkdown.md_to_html("\"quoted\"")
  assert_eq!(result, "<p>&quot;quoted&quot;</p>\n")
}

// --- Edge Cases ---

test "empty input" {
  let result = @moonmarkdown.md_to_html("")
  assert_eq!(result, "")
}

test "only blank lines" {
  let result = @moonmarkdown.md_to_html("\n\n\n")
  assert_eq!(result, "")
}

test "heading then code block" {
  let src = "# Title\n\n```\ncode\n```"
  let result = @moonmarkdown.md_to_html(src)
  assert_eq!(result, "<h1>Title</h1>\n<pre><code>code</code></pre>\n")
}

test "code block before paragraph" {
  let src = "```\ncode\n```\n\ntext"
  let result = @moonmarkdown.md_to_html(src)
  assert_eq!(result, "<pre><code>code</code></pre>\n<p>text</p>\n")
}

test "list with inline formatting" {
  let result = @moonmarkdown.md_to_html("- **bold** item\n- *italic* item")
  assert_eq!(result, "<ul>\n<li><p><strong>bold</strong> item</p></li>\n<li><p><em>italic</em> item</p></li>\n</ul>\n")
}
