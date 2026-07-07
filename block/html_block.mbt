// HTML block parsing per CommonMark spec types 1-7.

///|
/// Strip leading whitespace and return a String.
fn ltrim(s : String) -> String {
  let mut i = 0
  while i < s.length() && (s[i] == ' ' || s[i] == '\t') {
    i = i + 1
  }
  s.substring(start=i)
}

///|
/// Check if a line starts an HTML block (type 1-7 conditions).
fn is_html_block_start(line : String) -> Bool {
  let trimmed = ltrim(line)
  let tlen = trimmed.length()

  // Type 1: <pre, <script, <style, <textarea (case-insensitive)
  if tlen >= 4 {
    let start4 = trimmed.substring(start=0, end=4)
    if start4 == "<pre" || start4 == "<PRE" || start4 == "<Pre" {
      return check_tag_end(trimmed, 4)
    }
    if tlen >= 7 {
      let start7 = trimmed.substring(start=0, end=7)
      if start7 == "<script" || start7 == "<SCRIPT" || start7 == "<Script" {
        return check_tag_end(trimmed, 7)
      }
      if start7 == "<style>" ||
        start7 == "<style " ||
        start7 == "<STYLE>" ||
        start7 == "<STYLE " {
        return true
      }
    }
  }

  // Type 2: <!--
  if tlen >= 4 && trimmed.substring(start=0, end=4) == "<!--" {
    return true
  }

  // Type 3: <?
  if tlen >= 2 && trimmed.substring(start=0, end=2) == "<?" {
    return true
  }

  // Type 4: <! followed by uppercase letter
  if tlen >= 3 && trimmed.substring(start=0, end=2) == "<!" {
    let c = trimmed[2]
    if c >= 'A' && c <= 'Z' {
      return true
    }
  }

  // Type 5: <![CDATA[
  if tlen >= 8 && trimmed.substring(start=0, end=8) == "<![CDATA[" {
    return true
  }

  // Type 6: </xxx> or </xxx (closing tag)
  if tlen >= 3 && trimmed.substring(start=0, end=2) == "</" {
    let c = trimmed[2]
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
      return check_closing_tag_end(trimmed, 3)
    }
  }

  // Type 7: <xxx (open tag)
  if tlen >= 3 && trimmed[0] == '<' {
    let c = trimmed[1]
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
      return check_open_tag_end(trimmed, 2)
    }
  }

  false
}

///|
/// Check that after tag name we see space, >, or />
fn check_tag_end(line : String, start : Int) -> Bool {
  let mut i = start
  let len = line.length()
  // Skip tag name characters
  while i < len {
    let c = line[i]
    if (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      c == '-' ||
      c == '_' {
      i = i + 1
    } else {
      break
    }
  }
  if i >= len {
    return false
  }
  let c = line[i]
  c == ' ' || c == '\t' || c == '>'
}

///|
fn check_closing_tag_end(line : String, start : Int) -> Bool {
  let mut i = start
  let len = line.length()
  while i < len {
    let c = line[i]
    if (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      c == '-' {
      i = i + 1
    } else {
      break
    }
  }
  if i >= len {
    return true // </tag at end of line is ok
  }
  let c = line[i]
  c == '>' || c == ' ' || c == '\t'
}

///|
fn check_open_tag_end(line : String, start : Int) -> Bool {
  let mut i = start
  let len = line.length()
  while i < len {
    let c = line[i]
    if (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      c == '-' {
      i = i + 1
    } else {
      break
    }
  }
  if i >= len {
    return false // must end with space/>/>, bare <tag is not enough
  }
  let c = line[i]
  c == ' ' || c == '\t' || c == '/' || c == '>'
}

///|
/// Determine if a line continues or ends an HTML block.
fn is_html_block_end(line : String, block_type : Int) -> Bool {
  let content = line
  match block_type {
    1 =>
      // Type 1 ends with </pre> or </script> or </style> or </textarea>
      content.contains("</pre") ||
      content.contains("</script") ||
      content.contains("</style") ||
      content.contains("</textarea")
    2 => content.contains("-->")
    3 => content.contains("?>")
    4 => content == "" || is_blank_line(content)
    5 => content.contains("]]>")
    6 | 7 => content == "" || is_blank_line(content)
    _ => false
  }
}

///|
/// Determine HTML block type (1-7) from opening line.
fn html_block_type(line : String) -> Int {
  let trimmed = ltrim(line)
  let tlen = trimmed.length()

  if tlen >= 7 {
    let s7 = trimmed.substring(start=0, end=7)
    if s7 == "<script" || s7 == "<SCRIPT" {
      return 1
    }
  }
  if tlen >= 6 && trimmed.substring(start=0, end=6) == "<style" {
    return 1
  }
  if tlen >= 4 {
    let s4 = trimmed.substring(start=0, end=4)
    if s4 == "<pre" || s4 == "<PRE" {
      return 1
    }
  }
  if tlen >= 4 && trimmed.substring(start=0, end=4) == "<!--" {
    return 2
  }
  if tlen >= 2 && trimmed.substring(start=0, end=2) == "<?" {
    return 3
  }
  if tlen >= 3 && trimmed.substring(start=0, end=2) == "<!" {
    let c = trimmed[2]
    if c >= 'A' && c <= 'Z' {
      return 4
    }
  }
  if tlen >= 8 && trimmed.substring(start=0, end=8) == "<![CDATA[" {
    return 5
  }
  if tlen >= 3 && trimmed.substring(start=0, end=2) == "</" {
    let c = trimmed[2]
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
      return 6
    }
  }
  if tlen >= 2 && trimmed[0] == '<' {
    let c = trimmed[1]
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
      return 7
    }
  }
  0
}

///|
/// Parse an HTML block from lines starting at pos.
fn try_html_block(
  lines : Array[@util.Line],
  pos : Int,
  len : Int,
) -> (@types.Block, Int)? {
  if pos >= len {
    return None
  }
  let content = lines[pos].content
  if !is_html_block_start(content) {
    return None
  }
  let btype = html_block_type(content)
  let html_lines = Array::new(capacity=4)
  html_lines.push(content)
  let mut i = pos + 1
  while i < len {
    let lc = lines[i].content
    if is_html_block_end(lc, btype) {
      html_lines.push(lc)
      i = i + 1
      break
    }
    html_lines.push(lc)
    i = i + 1
  }
  let html = join_html_lines(html_lines)
  Some((@types.Block::HTMLBlock(html), i - pos))
}

///|
fn join_html_lines(lines : Array[String]) -> String {
  let mut result = ""
  let mut i = 0
  while i < lines.length() {
    if i > 0 {
      result = result + "\n"
    }
    result = result + lines[i]
    i = i + 1
  }
  result
}
