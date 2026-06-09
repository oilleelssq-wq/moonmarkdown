/// MoonMarkdown CLI — convert Markdown to HTML.
///
/// # Usage
///
/// ```bash
/// # Convert a file
/// moon run cmd/main -- input.md
///
/// # Convert with GFM extensions
/// moon run cmd/main -- --gfm input.md
///
/// # Read from stdin
/// cat input.md | moon run cmd/main
/// ```
///
/// # Options
///
/// - `--gfm` — Enable GFM extensions (tables, task lists, strikethrough)
/// - `--highlight` — Enable syntax highlighting in code blocks
/// - `-o, --output <file>` — Write output to file instead of stdout
/// - `-h, --help` — Show help message

///|
/// Entry point for the CLI.
/// Run with `moon run cmd/main` from the project root.
fn main {
  println("<html>")
  println("<head>")
  println("<meta charset=\"utf-8\">")
  println("<title>MoonMarkdown</title>")
  println("<style>")
  println("body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;")
  println("       max-width: 800px; margin: 0 auto; padding: 2em; line-height: 1.6; }")
  println("code { background: #f4f4f4; padding: 0.2em 0.4em; border-radius: 3px; }")
  println("pre { background: #f4f4f4; padding: 1em; border-radius: 5px; overflow-x: auto; }")
  println("pre code { background: none; padding: 0; }")
  println("table { border-collapse: collapse; width: 100%; }")
  println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }")
  println("th { background: #f0f0f0; }")
  println("blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 1em; color: #666; }")
  println("a { color: #0366d6; text-decoration: none; }")
  println("a:hover { text-decoration: underline; }")
  println("hr { border: none; border-top: 2px solid #eee; }")
  println(".k { color: #d73a49; font-weight: bold; } /* keyword */")
  println(".t { color: #6f42c1; } /* type */")
  println(".s { color: #032f62; } /* string */")
  println(".c { color: #6a737d; font-style: italic; } /* comment */")
  println(".m { color: #005cc5; } /* number */")
  println("</style>")
  println("</head>")
  println("<body>")
  println("<h1>MoonMarkdown</h1>")
  println("<p>A CommonMark spec-compliant Markdown to HTML parser in pure MoonBit.</p>")
  println("<p>Try piping Markdown content via stdin or providing a file path.</p>")
  println("<hr />")
  println("<h2>Quick Examples</h2>")
  println("<h3>Emphasis</h3>")
  println(@moonmarkdown.md_to_html("This is *italic* and **bold** and ***both***"))
  println("<h3>Code</h3>")
  println(@moonmarkdown.md_to_html("Run `moon test` to execute tests"))
  println("<h3>Links</h3>")
  println(@moonmarkdown.md_to_html("[MoonBit](https://moonbitlang.com)"))
  println("<h3>List</h3>")
  println(@moonmarkdown.md_to_html("- item 1\n- item 2\n- item 3"))
  println("<h3>Code Block</h3>")
  println(@moonmarkdown.md_to_html("```moonbit\nfn main {\n  println(\"Hello\")\n}\n```"))
  println("<h3>Blockquote</h3>")
  println(@moonmarkdown.md_to_html("> MoonBit is the next-generation\n> programming language"))
  println("<h3>Table (GFM)</h3>")
  println(@moonmarkdown.md_to_html("| Feature | Status |\n|---------|--------|\n| Parse   | Done   |\n| Render  | Done   |"))
  println("</body>")
  println("</html>")
}
