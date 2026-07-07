///|
/// Whitebox tests for block-level parsers.
test "is_atx_heading matches" {
  assert_eq(is_atx_heading("# H"), true)
  assert_eq(is_atx_heading("## H"), true)
  assert_eq(is_atx_heading("###### H"), true)
  assert_eq(is_atx_heading("####### H"), false)
  assert_eq(is_atx_heading("not heading"), false)
  assert_eq(is_atx_heading(""), false)
}

///|
test "is_thematic_break matches" {
  assert_eq(is_thematic_break("---"), true)
  assert_eq(is_thematic_break("***"), true)
  assert_eq(is_thematic_break("___"), true)
  assert_eq(is_thematic_break("- - -  "), true)
  assert_eq(is_thematic_break("* * *"), true)
  assert_eq(is_thematic_break("--"), false)
  assert_eq(is_thematic_break("==="), false)
  assert_eq(is_thematic_break("abc"), false)
}

///|
test "try_open_fence backtick basic" {
  match try_open_fence("```") {
    Some((fence, len, info)) => {
      assert_eq(fence, "`")
      assert_eq(len, 3)
      assert_eq(info, "")
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_open_fence with info string" {
  match try_open_fence("```moonbit") {
    Some((fence, len, info)) => {
      assert_eq(fence, "`")
      assert_eq(len, 3)
      assert_eq(info, "moonbit")
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_open_fence too few backticks" {
  match try_open_fence("``") {
    Some(_) => assert_eq("should not match", "matched")
    _ => ()
  }
}

///|
test "try_open_fence tilde" {
  match try_open_fence("~~~code") {
    Some((fence, len, info)) => {
      assert_eq(fence, "~")
      assert_eq(len, 3)
      assert_eq(info, "code")
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "is_closing_fence matching" {
  assert_eq(is_closing_fence("```", "`", 3), true)
  assert_eq(is_closing_fence("~~~", "~", 3), true)
  assert_eq(is_closing_fence("```  ", "`", 3), true)
  assert_eq(is_closing_fence("``", "`", 3), false)
  assert_eq(is_closing_fence("````", "`", 3), true)
}

///|
test "try_atx_heading level detection" {
  match try_atx_heading("# H") {
    Some(heading) =>
      match heading {
        @types.Block::Heading(1, _) => ()
        _ => assert_eq("expected h1", "wrong")
      }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_atx_heading with trailing #" {
  match try_atx_heading("## Hi ##") {
    Some(heading) =>
      match heading {
        @types.Block::Heading(2, _) => ()
        _ => assert_eq("expected h2", "wrong")
      }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_atx_heading not a heading (# without space)" {
  match try_atx_heading("#nospace") {
    Some(_) => assert_eq("should not match", "matched")
    _ => ()
  }
}

///|
test "detect_list_item unordered" {
  match detect_list_item("- item") {
    Some(info) => assert_eq(info.ordered, false)
    _ => assert_eq("should match", "did not")
  }
}

///|
test "detect_list_item ordered with dot" {
  match detect_list_item("1. item") {
    Some(info) => {
      assert_eq(info.ordered, true)
      assert_eq(info.start, 1)
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "detect_list_item ordered with paren" {
  match detect_list_item("3) item") {
    Some(info) => {
      assert_eq(info.ordered, true)
      assert_eq(info.start, 3)
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "detect_list_item not a list" {
  assert_true(detect_list_item("plain text") is None)
  assert_true(detect_list_item("") is None)
}

///|
test "strip_list_marker unordered" {
  match detect_list_item("- item") {
    Some(info) => assert_eq(strip_list_marker("- item", info), "item")
    _ => ()
  }
}

///|
test "check_four_spaces" {
  assert_eq(check_four_spaces("    code"), true)
  assert_eq(check_four_spaces("   not"), false)
  assert_eq(check_four_spaces(""), false)
  assert_eq(check_four_spaces("  "), false)
}

///|
test "is_html_block_start script" {
  assert_eq(is_html_block_start("<script>"), true)
  assert_eq(is_html_block_start("<SCRIPT>"), true)
  assert_eq(is_html_block_start("<script "), true)
}

///|
test "is_html_block_start comment" {
  assert_eq(is_html_block_start("<!-- comment -->"), true)
  assert_eq(is_html_block_start("<!--"), true)
}

///|
test "is_html_block_start not html" {
  assert_eq(is_html_block_start("plain text"), false)
  assert_eq(is_html_block_start(""), false)
}

///|
test "is_blockquote_start" {
  assert_eq(is_blockquote_start("> quote"), true)
  assert_eq(is_blockquote_start(">"), true)
  assert_eq(is_blockquote_start("not"), false)
}

///|
test "try_lrd basic" {
  match try_lrd("[ref]: https://example.com") {
    Some((label, url, title)) => {
      assert_eq(label, "ref")
      assert_eq(url, "https://example.com")
      assert_true(title is None)
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_lrd with title" {
  match try_lrd("[ref]: https://example.com \"title\"") {
    Some((_, _, Some(title))) => assert_eq(title, "title")
    Some((_, _, None)) => assert_eq("expected title", "missing title")
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_lrd not a definition" {
  assert_true(try_lrd("not an LRD") is None)
  assert_true(try_lrd("[incomplete") is None)
}
