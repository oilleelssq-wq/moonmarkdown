// Split source text into lines, handling \r\n, \r, \n endings.

// A line in the source document.
pub(all) struct Line {
  pub content : String
  pub offset : Int
  pub is_blank : Bool
  pub ending : Int
}

pub fn scan_lines(src : String) -> Array[Line] {
  let lines = Array::new(capacity=(src.length() / 40 + 10))
  let len = src.length()
  let mut pos = 0
  let mut i = 0
  while i < len {
    let c = src[i]
    if c == '\n' {
      let content = src.substring(start=pos, end=i)
      let stripped = strip_trailing_spaces(content)
      lines.push(Line::{ content: stripped, offset: pos, is_blank: stripped == "", ending: 1 })
      pos = i + 1
    } else if c == '\r' {
      let content = src.substring(start=pos, end=i)
      let stripped = strip_trailing_spaces(content)
      if i + 1 < len && src[i + 1] == '\n' {
        lines.push(Line::{ content: stripped, offset: pos, is_blank: stripped == "", ending: 2 })
        pos = i + 2
        i = i + 1
      } else {
        lines.push(Line::{ content: stripped, offset: pos, is_blank: stripped == "", ending: 1 })
        pos = i + 1
      }
    }
    i = i + 1
  }
  if pos <= len {
    let content = src.substring(start=pos, end=len)
    let stripped = strip_trailing_spaces(content)
    lines.push(Line::{ content: stripped, offset: pos, is_blank: stripped == "", ending: 0 })
  }
  lines
}

fn strip_trailing_spaces(s : String) -> String {
  let end = s.length()
  let mut i = end
  while i > 0 {
    let c = s[i - 1]
    if c != ' ' && c != '\t' {
      break
    }
    i = i - 1
  }
  if i == end {
    s
  } else {
    s.substring(start=0, end=i)
  }
}

pub fn raw_line_content(src : String, line : Line) -> String {
  let end = line.offset + line.content.length()
  if line.ending == 2 {
    src.substring(start=line.offset, end=end)
  } else if line.ending == 1 {
    if line.offset + line.content.length() < src.length() {
      src.substring(start=line.offset, end=line.offset + line.content.length())
    } else {
      line.content
    }
  } else {
    src.substring(start=line.offset)
  }
}
