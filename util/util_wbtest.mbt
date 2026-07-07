///|
/// Whitebox tests for utility modules.
test "scan_lines basic" {
  let lines = scan_lines("hello\nworld\n")
  assert_eq(lines.length(), 3)
  assert_eq(lines[0].content, "hello")
  assert_eq(lines[0].ending, 1)
  assert_eq(lines[1].content, "world")
  assert_eq(lines[1].ending, 1)
  assert_eq(lines[2].content, "")
  assert_eq(lines[2].ending, 0)
}

///|
test "scan_lines empty input" {
  let lines = scan_lines("")
  assert_eq(lines.length(), 1)
  assert_eq(lines[0].content, "")
  assert_eq(lines[0].is_blank, true)
}

///|
test "scan_lines CRLF" {
  let lines = scan_lines("a\r\nb\r\n")
  assert_eq(lines.length(), 3)
  assert_eq(lines[0].content, "a")
  assert_eq(lines[0].ending, 2)
  assert_eq(lines[1].content, "b")
  assert_eq(lines[1].ending, 2)
}

///|
test "scan_lines blank in middle" {
  let lines = scan_lines("a\n\nb\n")
  assert_eq(lines.length(), 4)
  assert_eq(lines[0].content, "a")
  assert_eq(lines[1].is_blank, true)
  assert_eq(lines[2].content, "b")
}

///|
test "scan_lines trailing spaces stripped" {
  let lines = scan_lines("hello   \n")
  assert_eq(lines[0].content, "hello")
}

///|
test "scan_lines CR only" {
  let lines = scan_lines("a\rb\r")
  assert_eq(lines.length(), 3)
  assert_eq(lines[0].content, "a")
  assert_eq(lines[1].content, "b")
}

///|
test "escape_html plain" {
  assert_eq(escape_html("hello"), "hello")
}

///|
test "escape_html ampersand" {
  assert_eq(escape_html("a & b"), "a &amp; b")
}

///|
test "escape_html less_than" {
  assert_eq(escape_html("<tag>"), "&lt;tag&gt;")
}

///|
test "escape_html double_quote" {
  assert_eq(escape_html("\"x\""), "&quot;x&quot;")
}

///|
test "escape_html mixed" {
  assert_eq(
    escape_html("<a href=\"x\">&</a>"),
    "&lt;a href=&quot;x&quot;&gt;&amp;&lt;/a&gt;",
  )
}

///|
test "char classification whitespace" {
  assert_eq(is_whitespace(' '), true)
  assert_eq(is_whitespace('\t'), true)
  assert_eq(is_whitespace('\n'), false)
  assert_eq(is_whitespace('A'), false)
}

///|
test "char classification alpha" {
  assert_eq(is_alpha('a'), true)
  assert_eq(is_alpha('Z'), true)
  assert_eq(is_alpha('0'), false)
}

///|
test "char classification digit" {
  assert_eq(is_digit('0'), true)
  assert_eq(is_digit('9'), true)
  assert_eq(is_digit('a'), false)
}

///|
test "is_escapable punctuation" {
  assert_eq(is_escapable('*'), true)
  assert_eq(is_escapable('_'), true)
  assert_eq(is_escapable('`'), true)
  assert_eq(is_escapable('\\'), true)
  assert_eq(is_escapable('&'), true)
  assert_eq(is_escapable('A'), false)
  assert_eq(is_escapable(' '), false)
}

///|
test "decode_entity named" {
  match decode_entity("amp") {
    Some(s) => assert_eq(s, "&")
    _ => assert_eq("should decode", "failed")
  }
  match decode_entity("lt") {
    Some(s) => assert_eq(s, "<")
    _ => assert_eq("should decode", "failed")
  }
  match decode_entity("gt") {
    Some(s) => assert_eq(s, ">")
    _ => assert_eq("should decode", "failed")
  }
}

///|
test "decode_entity hex" {
  match decode_entity("#x41") {
    Some(s) => assert_eq(s, "A")
    _ => assert_eq("should decode", "failed")
  }
}

///|
test "decode_entity decimal" {
  match decode_entity("#65") {
    Some(s) => assert_eq(s, "A")
    _ => assert_eq("should decode", "failed")
  }
}

///|
test "decode_entity unknown" {
  match decode_entity("nonexistent") {
    Some(_) => assert_eq("should not decode", "unexpectedly decoded")
    _ => ()
  }
}

///|
test "raw_line_content with LF" {
  let src = "hello\n"
  let lines = scan_lines(src)
  assert_eq(raw_line_content(src, lines[0]), "hello")
}

///|
test "raw_line_content no newline" {
  let src = "hello"
  let lines = scan_lines(src)
  assert_eq(raw_line_content(src, lines[0]), "hello")
}
