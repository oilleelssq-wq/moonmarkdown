// Fenced and indented code block parsing.

// Check if a line starts a fenced code block.
// Returns (fence_char, fence_length, info_string) or None.

///|
fn try_open_fence(line : String) -> (String, Int, String)? {
  let len = line.length()
  if len < 3 {
    return None
  }
  let c = line[0]
  if c != '`' && c != '~' {
    return None
  }
  let fence_char = if c == '`' { "`" } else { "~" }
  // Count fence characters
  let mut fence_len = 0
  while fence_len < len && line[fence_len] == c {
    fence_len = fence_len + 1
  }
  if fence_len < 3 {
    return None
  }
  // Skip spaces after fence
  let mut i = fence_len
  while i < len && (line[i] == ' ' || line[i] == '\t') {
    i = i + 1
  }
  // Info string
  let info = if i < len {
    let raw = line.substring(start=i)
    if c == '`' {
      // Strip any ` characters from info string of backtick fences
      let mut clean = ""
      let mut j = 0
      while j < raw.length() {
        if raw[j] != '`' {
          clean = clean + raw.substring(start=j, end=j + 1)
        }
        j = j + 1
      }
      clean
    } else {
      raw
    }
  } else {
    ""
  }
  Some((fence_char, fence_len, info))
}

// Check if a line closes a fenced code block.

///|
fn is_closing_fence(line : String, fence_char : String, min_len : Int) -> Bool {
  let len = line.length()
  let fc = fence_char[0]
  let mut count = 0
  while count < len && line[count] == fc {
    count = count + 1
  }
  if count < min_len {
    return false
  }
  let mut i = count
  while i < len {
    if line[i] != ' ' && line[i] != '\t' {
      return false
    }
    i = i + 1
  }
  true
}
