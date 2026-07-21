// Main block parser: orchestrates line-by-line block recognition.

///|
pub fn parse_blocks(lines : Array[@util.Line]) -> @types.Block {
  parse_blocks_with_options(lines, @types.MarkdownOptions::default())
}

///|
pub fn parse_blocks_with_options(
  lines : Array[@util.Line],
  options : @types.MarkdownOptions,
) -> @types.Block {
  let children = Array::new(capacity=lines.length() / 2)
  let len = lines.length()
  let mut pos = 0
  while pos < len {
    let line = lines[pos]
    if line.is_blank {
      pos = pos + 1
      continue
    }

    let content = line.content

    if options.gfm {
      match @ext.try_table(lines, pos, len) {
        Some((table, consumed)) => {
          children.push(table)
          pos = pos + consumed
          continue
        }
        _ => ()
      }
    }

    match try_open_fence(content) {
      Some((fence_char, fence_len, info)) => {
        let code_lines = Array::new(capacity=4)
        pos = pos + 1
        while pos < len {
          if is_closing_fence(lines[pos].content, fence_char, fence_len) {
            pos = pos + 1
            break
          }
          code_lines.push(lines[pos].content)
          pos = pos + 1
        }
        children.push(
          @types.Block::FencedCodeBlock(info, join_lines(code_lines)),
        )
        continue
      }
      _ => ()
    }

    match try_atx_heading(content) {
      Some(heading) => {
        match heading {
          @types.Block::Heading(level, _) => {
            let raw = extract_heading_text(content)
            let inlines = @inline.parse_inlines_with_options(raw, options)
            children.push(@types.Block::Heading(level, inlines))
          }
          _ => children.push(heading)
        }
        pos = pos + 1
        continue
      }
      _ => ()
    }

    if is_thematic_break(content) {
      children.push(@types.Block::ThematicBreak)
      pos = pos + 1
      continue
    }

    if options.html && is_html_block_start(content) {
      let html_lines = Array::new(capacity=4)
      html_lines.push(content)
      pos = pos + 1
      while pos < len && !lines[pos].is_blank {
        html_lines.push(lines[pos].content)
        pos = pos + 1
      }
      children.push(@types.Block::HTMLBlock(join_lines(html_lines)))
      continue
    }

    if is_blockquote_start(content) {
      let quote_lines = collect_blockquote_lines(lines, pos, len)
      let inner = parse_blocks_with_options(quote_lines, options)
      match inner {
        @types.Block::Document(inner_children) =>
          children.push(@types.Block::BlockQuote(inner_children))
        _ => children.push(@types.Block::BlockQuote([inner]))
      }
      pos = pos + 1
      while pos < len &&
            lines[pos].content != "" &&
            lines[pos].content[0] == '>' {
        pos = pos + 1
      }
      continue
    }

    match try_lrd(content) {
      Some((label, url, title)) => {
        children.push(@types.Block::LinkReferenceDefinition(label, url, title))
        pos = pos + 1
        continue
      }
      _ => ()
    }

    match detect_list_item(content) {
      Some(list_info) => {
        let list_children = parse_list_items(
          lines, pos, len, list_info, options,
        )
        let list_items = list_children.0
        let consumed = list_children.1
        pos = pos + consumed
        let tight = true
        children.push(
          @types.Block::List(
            if list_info.ordered {
              Some(list_info.start)
            } else {
              None
            },
            tight,
            list_info.marker,
            list_items,
          ),
        )
        continue
      }
      _ => ()
    }

    if content.length() >= 4 && check_four_spaces(content) {
      let code_lines = Array::new(capacity=4)
      while pos < len &&
            (
              lines[pos].is_blank ||
              (
                lines[pos].content.length() >= 4 &&
                check_four_spaces(lines[pos].content)
              )
            ) {
        let lc = lines[pos].content
        if lc.length() >= 4 && check_four_spaces(lc) {
          code_lines.push(lc[4:].to_owned())
        } else {
          code_lines.push("")
        }
        pos = pos + 1
      }
      children.push(@types.Block::IndentedCodeBlock(join_lines(code_lines)))
      continue
    }

    let para_lines = Array::new(capacity=4)
    while pos < len &&
          !lines[pos].is_blank &&
          !is_block_start(lines[pos].content) {
      para_lines.push(lines[pos].content)
      pos = pos + 1
    }
    if para_lines.length() > 0 {
      let raw_text = join_lines(para_lines)
      if pos < len && !lines[pos].is_blank {
        match try_setext_underline(lines[pos].content) {
          Some(level) => {
            let inlines = @inline.parse_inlines_with_options(raw_text, options)
            children.push(@types.Block::Heading(level, inlines))
            pos = pos + 1
            continue
          }
          _ => ()
        }
      }
      let inlines = @inline.parse_inlines_with_options(raw_text, options)
      children.push(@types.Block::Paragraph(inlines))
    }
  }

  @types.Block::Document(children)
}

///|
fn check_four_spaces(s : String) -> Bool {
  if s.length() < 4 {
    return false
  }
  let mut i = 0
  while i < 4 {
    if s[i] != ' ' {
      return false
    }
    i = i + 1
  }
  true
}

///|
fn join_lines(lines : Array[String]) -> String {
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

///|
fn collect_blockquote_lines(
  lines : Array[@util.Line],
  start : Int,
  len : Int,
) -> Array[@util.Line] {
  let result = Array::new(capacity=4)
  let mut i = start
  while i < len {
    let content = lines[i].content
    if content != "" && content[0] == '>' {
      let inner = if content.length() > 1 && content[1] == ' ' {
        content[2:].to_owned()
      } else if content.length() > 1 {
        content[1:].to_owned()
      } else {
        ""
      }
      result.push(@util.Line::{
        content: inner,
        offset: 0,
        is_blank: inner == "",
        ending: 0,
      })
    } else {
      result.push(@util.Line::{
        content,
        offset: 0,
        is_blank: content == "",
        ending: 0,
      })
    }
    i = i + 1
  }
  result
}

// LRD parsing

///|
fn try_lrd(line : String) -> (String, String, String?)? {
  let len = line.length()
  if len == 0 || line[0] != '[' {
    return None
  }
  // Find closing bracket
  let mut i = 1
  while i < len && line[i] != ']' {
    i = i + 1
  }
  if i >= len {
    return None
  }
  let label = line[1:i].to_owned()
  i = i + 1
  // Must be followed by :
  if i >= len || line[i] != ':' {
    return None
  }
  i = i + 1
  // Skip whitespace
  while i < len && (line[i] == ' ' || line[i] == '\t') {
    i = i + 1
  }
  // URL: <url> or bare url
  let mut url = ""
  if i < len && line[i] == '<' {
    let url_start = i + 1
    i = i + 1
    while i < len && line[i] != '>' {
      i = i + 1
    }
    if i >= len {
      return None
    }
    url = line[url_start:i].to_owned()
    i = i + 1
  } else {
    let url_start = i
    while i < len && line[i] != ' ' && line[i] != '\t' {
      i = i + 1
    }
    url = line[url_start:i].to_owned()
  }
  // Optional title
  let mut title : String? = None
  while i < len && (line[i] == ' ' || line[i] == '\t') {
    i = i + 1
  }
  if i < len {
    let title_char = line[i]
    if title_char == '(' || title_char == '"' || title_char == '\'' {
      if title_char == '(' {
        let title_start = i + 1
        i = i + 1
        while i < len && line[i] != ')' {
          i = i + 1
        }
        if i < len {
          title = Some(line[title_start:i].to_owned())
        }
      } else {
        let close = title_char
        let title_start = i + 1
        i = i + 1
        while i < len && line[i] != close {
          i = i + 1
        }
        if i < len {
          title = Some(line[title_start:i].to_owned())
        }
      }
    }
  }
  Some((label, url, title))
}

// Extract raw heading text (after # prefix and before trailing #).

///|
fn extract_heading_text(line : String) -> String {
  let len = line.length()
  let mut i = 0
  // Skip # characters
  while i < len && line[i] == '#' {
    i = i + 1
  }
  // Skip whitespace after #
  while i < len && (line[i] == ' ' || line[i] == '\t') {
    i = i + 1
  }
  let start = i
  let mut end = len
  // Strip trailing spaces
  while end > start && (line[end - 1] == ' ' || line[end - 1] == '\t') {
    end = end - 1
  }
  // Strip trailing # (only if preceded by space)
  let mut hash_end = end
  while hash_end > start && line[hash_end - 1] == '#' {
    hash_end = hash_end - 1
  }
  if hash_end < end && hash_end > start && line[hash_end - 1] == ' ' {
    end = hash_end
    while end > start && line[end - 1] == ' ' {
      end = end - 1
    }
  }
  if start < end {
    line[start:end].to_owned()
  } else {
    ""
  }
}

// List item parsing: returns (items, lines_consumed)

///|
fn parse_list_items(
  lines : Array[@util.Line],
  start : Int,
  len : Int,
  first_info : ListInfo,
  options : @types.MarkdownOptions,
) -> (Array[@types.Block], Int) {
  let items = Array::new(capacity=4)
  let mut pos = start
  let mut info = first_info
  while pos < len {
    let content = lines[pos].content
    let item_lines = Array::new(capacity=4)
    let item_content = strip_list_marker(content, info)
    item_lines.push(item_content)
    pos = pos + 1
    // Collect continuation lines
    while pos < len {
      let lc = lines[pos].content
      if lc == "" {
        pos = pos + 1
        if pos < len &&
          detect_list_item(lines[pos].content) is None &&
          !is_block_start(lines[pos].content) {
          item_lines.push("")
        } else {
          break
        }
      } else if detect_list_item(lc) is Some(_) {
        break
      } else if is_block_start(lc) {
        break
      } else {
        if lc.length() >= 4 && check_four_spaces(lc) {
          item_lines.push(lc[4:].to_owned())
        } else {
          item_lines.push(lc)
        }
        pos = pos + 1
      }
    }
    // Parse item content
    let item_text = join_lines(item_lines)
    let item_inlines = @inline.parse_inlines_with_options(item_text, options)
    let item_blocks = Array::new(capacity=1)
    item_blocks.push(@types.Block::Paragraph(item_inlines))
    items.push(@types.Block::ListItem(item_blocks))
    // Check next list item
    if pos >= len {
      break
    }
    match detect_list_item(lines[pos].content) {
      Some(next_info) => info = next_info
      _ => break
    }
  }
  (items, pos - start)
}

///|
