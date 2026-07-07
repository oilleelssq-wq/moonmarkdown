// List parsing: unordered (-, *, +) and ordered (1., 2.), single-level.

///|
priv struct ListInfo {
  ordered : Bool
  start : Int
  marker : UInt16
  item_marker_len : Int
}

///|
fn detect_list_item(line : String) -> ListInfo? {
  let len = line.length()
  if len < 2 {
    return None
  }
  let c0 = line[0]
  // Unordered: -, *, +
  if c0 == '-' || c0 == '*' || c0 == '+' {
    if line[1] == ' ' || line[1] == '\t' {
      return Some({ ordered: false, start: 0, marker: c0, item_marker_len: 1 })
    }
    return None
  }
  // Ordered: digit(s) then . or )
  if c0 >= '0' && c0 <= '9' {
    let mut i = 0
    let mut num = 0
    while i < len && line[i] >= '0' && line[i] <= '9' {
      num = num * 10 + line[i].to_int() - 0x30
      i = i + 1
    }
    if i < len - 1 &&
      (line[i] == '.' || line[i] == ')') &&
      (line[i + 1] == ' ' || line[i + 1] == '\t') {
      return Some({
        ordered: true,
        start: num,
        marker: line[i],
        item_marker_len: i,
      })
    }
  }
  None
}

///|
fn strip_list_marker(line : String, info : ListInfo) -> String {
  let mut i = info.item_marker_len + 1 // skip marker + space
  // Skip up to 3 optional spaces after marker
  let mut space_count = 0
  while i < line.length() &&
        (line[i] == ' ' || line[i] == '\t') &&
        space_count < 3 {
    i = i + 1
    space_count = space_count + 1
  }
  line[i:].to_owned()
}
