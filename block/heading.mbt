// ATX and Setext heading parsing.

///|
fn is_atx_heading(line : String) -> Bool {
  let len = line.length()
  if len == 0 || line[0] != '#' {
    return false
  }
  let mut i = 0
  while i < len && i <= 6 && line[i] == '#' {
    i = i + 1
  }
  i > 0 && i <= 6 && i < len && (line[i] == ' ' || line[i] == '\t')
}

// Parse an ATX heading: 1-6 # characters followed by space and content.
// Returns None if not an ATX heading.

///|
fn try_atx_heading(line : String) -> @types.Block? {
  let len = line.length()
  if len == 0 || line[0] != '#' {
    return None
  }
  let mut level = 0
  let mut i = 0
  while i < len && i < 7 && line[i] == '#' {
    level = level + 1
    i = i + 1
  }
  if i >= len {
    // Just `#` with no content - still a valid empty heading
    return Some(@types.Block::Heading(level, []))
  }
  if line[i] != ' ' && line[i] != '\t' {
    // # not followed by space/tab - not a heading
    return None
  }
  // Skip whitespace after #
  while i < len && (line[i] == ' ' || line[i] == '\t') {
    i = i + 1
  }
  // Find end, stripping trailing # and whitespace
  let content_start = i
  let mut content_end = len
  // Strip trailing spaces
  while content_end > content_start &&
        (line[content_end - 1] == ' ' || line[content_end - 1] == '\t') {
    content_end = content_end - 1
  }
  // Strip trailing # (only if there's a space before the # sequence)
  // Per spec: trailing `#` are only stripped if there's a space before them
  let mut hash_end = content_end
  while hash_end > content_start && line[hash_end - 1] == '#' {
    hash_end = hash_end - 1
  }
  if hash_end < content_end &&
    hash_end > content_start &&
    line[hash_end - 1] == ' ' {
    content_end = hash_end
    // Strip the space before the trailing # as well
    while content_end > content_start && line[content_end - 1] == ' ' {
      content_end = content_end - 1
    }
  }
  let content = if content_start < content_end {
    line.substring(start=content_start, end=content_end)
  } else {
    ""
  }
  Some(@types.Block::Heading(level, [])) // inlines filled by caller
}

// Try to match a setext heading underline on the current line.
// The previous block must be a paragraph.

///|
fn try_setext_underline(line : String) -> Int? {
  let len = line.length()
  if len == 0 {
    return None
  }
  let c = line[0]
  if c != '=' && c != '-' {
    return None
  }
  let mut i = 0
  while i < len && line[i] == c {
    i = i + 1
  }
  // Check remaining chars are only spaces
  while i < len {
    if line[i] != ' ' && line[i] != '\t' {
      return None
    }
    i = i + 1
  }
  if c == '=' {
    Some(1)
  } else {
    Some(2)
  }
}
