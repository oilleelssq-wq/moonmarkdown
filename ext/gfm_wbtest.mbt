///|
/// Whitebox tests for GFM extensions.
test "is_table_delimiter valid" {
  assert_eq(is_table_delimiter("| --- |"), true)
  assert_eq(is_table_delimiter("|:---:|"), true)
  assert_eq(is_table_delimiter("|---:|"), true)
  assert_eq(is_table_delimiter("|:---|"), true)
  assert_eq(is_table_delimiter("| abc |"), false)
}

///|
test "parse_table_alignments" {
  let aligns = parse_table_alignments("| --- | --- |")
  assert_eq(aligns[0], "left")
  assert_eq(aligns[1], "left")
}

///|
test "parse_table_alignments center" {
  let aligns = parse_table_alignments("|:---:|:---:|")
  assert_eq(aligns[0], "center")
}

///|
test "parse_table_alignments right" {
  let aligns = parse_table_alignments("|---:|---:|")
  assert_eq(aligns[0], "right")
}

///|
test "parse_table_alignments mixed" {
  let aligns = parse_table_alignments("|:---|---:|:---:|")
  assert_eq(aligns[0], "left")
  assert_eq(aligns[1], "right")
  assert_eq(aligns[2], "center")
}

///|
test "split_table_row simple" {
  let cells = split_table_row("| a | b | c |")
  assert_eq(cells.length(), 3)
  assert_eq(cells[0], "a")
  assert_eq(cells[1], "b")
  assert_eq(cells[2], "c")
}

///|
test "split_table_row empty cells" {
  let cells = split_table_row("| a || c |")
  assert_eq(cells.length(), 3)
  assert_eq(cells[1], "")
}

///|
test "render_table basic" {
  let header = ["Name", "Value"]
  let aligns = ["left", "right"]
  let rows = [["x", "1"], ["y", "2"]]
  let html = render_table(header, aligns, rows)
  assert_eq(html.contains("<table>"), true)
  assert_eq(html.contains("<thead>"), true)
  assert_eq(html.contains("<tbody>"), true)
}

///|
test "is_task_list_item checked" {
  match is_task_list_item("- [x] task") {
    Some((checked, _)) => assert_eq(checked, true)
    _ => assert_eq("should match", "did not")
  }
}

///|
test "is_task_list_item unchecked" {
  match is_task_list_item("- [ ] task") {
    Some((checked, _)) => assert_eq(checked, false)
    _ => assert_eq("should match", "did not")
  }
}

///|
test "is_task_list_item not a task" {
  assert_eq(is_task_list_item("- regular item").is_none(), true)
}

///|
test "try_strikethrough basic" {
  match try_strikethrough("~~text~~", 0) {
    Some((inlines, end_pos)) => {
      assert_eq(inlines.length(), 1)
      assert_eq(end_pos, 8)
    }
    _ => assert_eq("should match", "did not")
  }
}

///|
test "try_strikethrough not found" {
  assert_eq(try_strikethrough("no tildes", 0).is_none(), true)
}

///|
test "trim_spaces leading" {
  assert_eq(trim_spaces("  hello"), "hello")
}

///|
test "trim_spaces trailing" {
  assert_eq(trim_spaces("hello  "), "hello")
}

///|
test "trim_spaces both" {
  assert_eq(trim_spaces("  hello  "), "hello")
}

///|
test "trim_spaces none needed" {
  assert_eq(trim_spaces("hello"), "hello")
}
