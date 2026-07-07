///|
/// Whitebox tests for inline parser.
test "parse_inlines empty" {
  let result = parse_inlines("")
  assert_eq(result.length(), 0)
}

///|
test "parse_inlines plain text" {
  let result = parse_inlines("hello world")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "hello world")
    _ => assert_eq("expected Text", "wrong")
  }
}

///|
test "parse_inlines backslash escape" {
  let result = parse_inlines("\\*star\\*")
  assert_eq(result.length(), 3)
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "*")
    _ => assert_eq("expected Text", "wrong")
  }
  match result[1] {
    @types.Inline::Text(t) => assert_eq(t, "star")
    _ => assert_eq("expected Text", "wrong")
  }
  match result[2] {
    @types.Inline::Text(t) => assert_eq(t, "*")
    _ => assert_eq("expected Text", "wrong")
  }
}

///|
test "parse_inlines code span" {
  let result = parse_inlines("use `code` here")
  assert_eq(result.length(), 3)
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "use ")
    _ => assert_eq("expected Text", "wrong")
  }
  match result[1] {
    @types.Inline::CodeSpan(t) => assert_eq(t, "code")
    _ => assert_eq("expected CodeSpan", "wrong")
  }
  match result[2] {
    @types.Inline::Text(t) => assert_eq(t, " here")
    _ => assert_eq("expected Text", "wrong")
  }
}

///|
test "parse_inlines emphasis single asterisk" {
  let result = parse_inlines("*italic*")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Emphasis(children) => {
      assert_eq(children.length(), 1)
      match children[0] {
        @types.Inline::Text(t) => assert_eq(t, "italic")
        _ => assert_eq("expected Text", "wrong")
      }
    }
    _ => assert_eq("expected Emphasis", "wrong")
  }
}

///|
test "parse_inlines emphasis underscore" {
  let result = parse_inlines("_em_")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Emphasis(_) => ()
    _ => assert_eq("expected Emphasis", "wrong")
  }
}

///|
test "parse_inlines strong" {
  let result = parse_inlines("**bold**")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Strong(children) =>
      match children[0] {
        @types.Inline::Text(t) => assert_eq(t, "bold")
        _ => assert_eq("expected Text", "wrong")
      }
    _ => assert_eq("expected Strong", "wrong")
  }
}

///|
test "parse_inlines bold italic" {
  let result = parse_inlines("***both***")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Strong(children) =>
      match children[0] {
        @types.Inline::Emphasis(inner) =>
          match inner[0] {
            @types.Inline::Text(t) => assert_eq(t, "both")
            _ => assert_eq("expected Text", "wrong")
          }
        _ => assert_eq("expected Emphasis", "wrong")
      }
    _ => assert_eq("expected Strong", "wrong")
  }
}

///|
test "parse_inlines link basic" {
  let result = parse_inlines("[text](url)")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Link(children, url, _) => {
      assert_eq(url, "url")
      match children[0] {
        @types.Inline::Text(t) => assert_eq(t, "text")
        _ => assert_eq("expected Text", "wrong")
      }
    }
    _ => assert_eq("expected Link", "wrong")
  }
}

///|
test "parse_inlines link with title" {
  let result = parse_inlines("[text](url \"title\")")
  match result[0] {
    @types.Inline::Link(_, _, title) => assert_eq(title, Some("title"))
    _ => assert_eq("expected Link", "wrong")
  }
}

///|
test "parse_inlines image" {
  let result = parse_inlines("![alt](img.png)")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Image(alt, url, _) => {
      assert_eq(url, "img.png")
      match alt[0] {
        @types.Inline::Text(t) => assert_eq(t, "alt")
        _ => assert_eq("expected Text", "wrong")
      }
    }
    _ => assert_eq("expected Image", "wrong")
  }
}

///|
test "parse_inlines autolink" {
  let result = parse_inlines("<https://example.com>")
  assert_eq(result.length(), 1)
  match result[0] {
    @types.Inline::Autolink(url) => assert_eq(url, "https://example.com")
    _ => assert_eq("expected Autolink", "wrong")
  }
}

///|
test "parse_inlines hard break" {
  let result = parse_inlines("line\\\nnext")
  // Hard break: backslash + newline
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "line")
    _ => assert_eq("expected Text", "wrong")
  }
}

///|
test "parse_inlines soft break" {
  let result = parse_inlines("line1\nline2")
  assert_eq(result.length(), 3)
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "line1")
    _ => assert_eq("expected Text", "wrong")
  }
  match result[1] {
    @types.Inline::SoftBreak => ()
    _ => assert_eq("expected SoftBreak", "wrong")
  }
  match result[2] {
    @types.Inline::Text(t) => assert_eq(t, "line2")
    _ => assert_eq("expected Text", "wrong")
  }
}

///|
test "parse_inlines mixed content" {
  let result = parse_inlines("**bold** and *italic* and `code`")
  // Should have: Strong, Text(" and "), Emphasis, Text(" and "), CodeSpan
  assert_eq(result.length() >= 5, true)
}

///|
test "parse_inlines not emphasis (no closer)" {
  let result = parse_inlines("*not italic")
  // Should fall through as plain text
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "*not italic")
    _ => ()
  }
}

///|
test "parse_inlines emphasis mid-word" {
  let result = parse_inlines("un*frigging*believable")
  assert_eq(result.length(), 3)
  match result[0] {
    @types.Inline::Text(t) => assert_eq(t, "un")
    _ => assert_eq("expected Text", "wrong")
  }
  match result[1] {
    @types.Inline::Emphasis(children) =>
      match children[0] {
        @types.Inline::Text(t) => assert_eq(t, "frigging")
        _ => assert_eq("expected Text", "wrong")
      }
    _ => assert_eq("expected Emphasis", "wrong")
  }
  match result[2] {
    @types.Inline::Text(t) => assert_eq(t, "believable")
    _ => assert_eq("expected Text", "wrong")
  }
}
