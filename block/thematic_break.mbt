// Thematic break parsing: ---, ***, ___ (3 or more, optionally spaced).

///|
fn is_thematic_break(line : String) -> Bool {
  let len = line.length()
  if len < 3 {
    return false
  }
  let c = line[0]
  if c != '-' && c != '*' && c != '_' {
    return false
  }
  let mut count = 0
  let mut i = 0
  while i < len {
    let ch = line[i]
    if ch == c {
      count = count + 1
    } else if ch != ' ' && ch != '\t' {
      return false
    }
    i = i + 1
  }
  count >= 3
}
