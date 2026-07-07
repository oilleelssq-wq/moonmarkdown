/// Line scanner: splits source text into an array of Line structures.
///
/// Handles `\r\n`, `\r`, and `\n` line endings (all normalized to `\n`
/// in the output). Trailing spaces are stripped per CommonMark spec.

///|
/// A line in the source document with position metadata.
pub(all) struct Line {
  /// Line content with trailing whitespace stripped.
  content : String
  /// Byte offset from start of source text (0-based).
  offset : Int
  /// Whether the line is empty or whitespace-only.
  is_blank : Bool
  /// Line ending length: 0=EOF, 1=`\n` or `\r`, 2=`\r\n`
  ending : Int
}

///|
/// Split source text into lines.
/// Each line has trailing spaces stripped and `\r\n` normalized to `\n`.
pub fn scan_lines(src : String) -> Array[Line] {
  let lines = Array::new(capacity=src.length() / 40 + 10)
  let len = src.length()
  let mut pos = 0
  let mut i = 0
  while i < len {
    let c = src[i]
    if c == '\n' {
      let content = src[pos:i].to_owned()
      let stripped = strip_trailing_spaces(content)
      lines.push(Line::{
        content: stripped,
        offset: pos,
        is_blank: stripped == "",
        ending: 1,
      })
      pos = i + 1
    } else if c == '\r' {
      let content = src[pos:i].to_owned()
      let stripped = strip_trailing_spaces(content)
      if i + 1 < len && src[i + 1] == '\n' {
        lines.push(Line::{
          content: stripped,
          offset: pos,
          is_blank: stripped == "",
          ending: 2,
        })
        pos = i + 2
        i = i + 1
      } else {
        lines.push(Line::{
          content: stripped,
          offset: pos,
          is_blank: stripped == "",
          ending: 1,
        })
        pos = i + 1
      }
    }
    i = i + 1
  }
  if pos <= len {
    let content = src[pos:len].to_owned()
    let stripped = strip_trailing_spaces(content)
    lines.push(Line::{
      content: stripped,
      offset: pos,
      is_blank: stripped == "",
      ending: 0,
    })
  }
  lines
}

///|
/// Strip trailing spaces and tabs from a line.
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
    s[0:i].to_owned()
  }
}

///|
/// Get the raw content of a line from the original source.
pub fn raw_line_content(src : String, line : Line) -> String {
  let end = line.offset + line.content.length()
  if line.ending == 2 {
    src[line.offset:end].to_owned()
  } else if line.ending == 1 {
    if line.offset + line.content.length() < src.length() {
      src[line.offset:line.offset + line.content.length()].to_owned()
    } else {
      line.content
    }
  } else {
    src[line.offset:].to_owned()
  }
}
