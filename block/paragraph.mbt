// Paragraph parsing: accumulate consecutive non-blank lines.

///|
fn is_blank_line(line : String) -> Bool {
  let mut i = 0
  while i < line.length() {
    if line[i] != ' ' && line[i] != '\t' {
      return false
    }
    i = i + 1
  }
  true
}

///|
fn is_block_start(line : String) -> Bool {
  is_atx_heading(line) ||
  is_thematic_break(line) ||
  try_open_fence(line).is_some() ||
  is_blockquote_start(line) ||
  is_list_item_start(line) ||
  is_blank_line(line)
}

///|
fn is_blockquote_start(line : String) -> Bool {
  line.length() > 0 && line[0] == '>'
}

///|
fn is_list_item_start(line : String) -> Bool {
  let len = line.length()
  if len == 0 {
    return false
  }
  let c0 = line[0]
  if c0 == '-' || c0 == '*' || c0 == '+' {
    return len > 1 && (line[1] == ' ' || line[1] == '\t')
  }
  if c0 >= '0' && c0 <= '9' {
    let mut i = 0
    while i < len && line[i] >= '0' && line[i] <= '9' {
      i = i + 1
    }
    if i > 0 && i < len - 1 {
      let next = line[i]
      (next == '.' || next == ')') &&
      (line[i + 1] == ' ' || line[i + 1] == '\t')
    } else {
      false
    }
  } else {
    false
  }
}
