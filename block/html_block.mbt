// HTML block parsing per CommonMark spec types 1-7.

///|
/// Strip leading whitespace and return a String.
fn ltrim(s : String) -> String {
  let mut i = 0
  while i < s.length() && (s[i] == ' ' || s[i] == '\t') {
    i = i + 1
  }
  s[i:].to_owned()
}

///|
/// Check if a line starts an HTML block (type 1-7 conditions).
pub fn is_html_block_start(line : String) -> Bool {
  let trimmed = ltrim(line)
  let tlen = trimmed.length()

  // Type 1: <pre, <script, <style, <textarea (case-insensitive)
  if tlen >= 4 {
    let start4 = trimmed[0:4].to_owned()
    if start4 == "<pre" || start4 == "<PRE" || start4 == "<Pre" {
      return check_tag_end(trimmed, 4)
    }
    if tlen >= 7 {
      let start7 = trimmed[0:7].to_owned()
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
  if tlen >= 4 && trimmed[0:4].to_owned() == "<!--" {
    return true
  }

  // Type 3: <?
  if tlen >= 2 && trimmed[0:2].to_owned() == "<?" {
    return true
  }

  // Type 4: <! followed by uppercase letter
  if tlen >= 3 && trimmed[0:2].to_owned() == "<!" {
    let c = trimmed[2]
    if c >= 'A' && c <= 'Z' {
      return true
    }
  }

  // Type 5: <![CDATA[
  if tlen >= 8 && trimmed[0:8].to_owned() == "<![CDATA[" {
    return true
  }

  // Type 6: </xxx> or </xxx (closing tag)
  if tlen >= 3 && trimmed[0:2].to_owned() == "</" {
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
