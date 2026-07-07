// Auto-generated from CommonMark spec.txt (0.31.2)
// DO NOT EDIT

pub struct SpecCase {
  section : String
  number : Int
  markdown : String
  html : String
}

pub let spec_cases : Array[SpecCase] = [
  { section: "Tabs", number: 1, markdown: "→foo→baz→→bim", html: "<pre><code>foo→baz→→bim\n</code></pre>" },
  { section: "Tabs", number: 2, markdown: "  →foo→baz→→bim", html: "<pre><code>foo→baz→→bim\n</code></pre>" },
  { section: "Tabs", number: 3, markdown: "    a→a\n    ὐ→a", html: "<pre><code>a→a\nὐ→a\n</code></pre>" },
  { section: "Tabs", number: 4, markdown: "  - foo\n\n→bar", html: "<ul>\n<li>\n<p>foo</p>\n<p>bar</p>\n</li>\n</ul>" },
  { section: "Tabs", number: 5, markdown: "- foo\n\n→→bar", html: "<ul>\n<li>\n<p>foo</p>\n<pre><code>  bar\n</code></pre>\n</li>\n</ul>" },
  { section: "Tabs", number: 6, markdown: ">→→foo", html: "<blockquote>\n<pre><code>  foo\n</code></pre>\n</blockquote>" },
  { section: "Tabs", number: 7, markdown: "-→→foo", html: "<ul>\n<li>\n<pre><code>  foo\n</code></pre>\n</li>\n</ul>" },
  { section: "Tabs", number: 8, markdown: "    foo\n→bar", html: "<pre><code>foo\nbar\n</code></pre>" },
  { section: "Tabs", number: 9, markdown: " - foo\n   - bar\n→ - baz", html: "<ul>\n<li>foo\n<ul>\n<li>bar\n<ul>\n<li>baz</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>" },
  { section: "Tabs", number: 10, markdown: "#→Foo", html: "<h1>Foo</h1>" },
  { section: "Tabs", number: 11, markdown: "*→*→*→", html: "<hr />" },
  { section: "Backslash escapes", number: 12, markdown: "\\!\\\"\\#\\$\\%\\&\\'\\(\\)\\*\\+\\,\\-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\_\\`\\{\\|\\}\\~", html: "<p>!&quot;#$%&amp;'()*+,-./:;&lt;=&gt;?@[\\]^_`{|}~</p>" },
  { section: "Backslash escapes", number: 13, markdown: "\\→\\A\\a\\ \\3\\φ\\«", html: "<p>\\→\\A\\a\\ \\3\\φ\\«</p>" },
  { section: "Backslash escapes", number: 14, markdown: "\\*not emphasized*\n\\<br/> not a tag\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a heading\n\\[foo]: /url \"not a reference\"\n\\&ouml; not a character entity", html: "<p>*not emphasized*\n&lt;br/&gt; not a tag\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a heading\n[foo]: /url &quot;not a reference&quot;\n&amp;ouml; not a character entity</p>" },
  { section: "Backslash escapes", number: 15, markdown: "\\\\*emphasis*", html: "<p>\\<em>emphasis</em></p>" },
  { section: "Backslash escapes", number: 16, markdown: "foo\\\nbar", html: "<p>foo<br />\nbar</p>" },
  { section: "Backslash escapes", number: 17, markdown: "`` \\[\\` ``", html: "<p><code>\\[\\`</code></p>" },
  { section: "Backslash escapes", number: 18, markdown: "    \\[\\]", html: "<pre><code>\\[\\]\n</code></pre>" },
  { section: "Backslash escapes", number: 19, markdown: "~~~\n\\[\\]\n~~~", html: "<pre><code>\\[\\]\n</code></pre>" },
  { section: "Backslash escapes", number: 20, markdown: "<https://example.com?find=\\*>", html: "<p><a href=\"https://example.com?find=%5C*\">https://example.com?find=\\*</a></p>" }
]
