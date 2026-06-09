// GFM (GitHub Flavored Markdown) extensions.

// ---- Tables ----

pub fn try_table(lines : Array[@util.Line], start : Int, len : Int) -> (@types.Block, Int)? {
  if start >= len {
    return None
  }
  let header_line = lines[start].content
  if header_line == "" || header_line[0] != '|' {
    return None
  }
  // Must have a delimiter row
  if start + 1 >= len {
    return None
  }
  let delim_line = lines[start + 1].content
  if !is_table_delimiter(delim_line) {
    return None
  }
  let alignments = parse_table_alignments(delim_line)
  let header_cells = split_table_row(header_line)
  if header_cells.length() != alignments.length() {
    return None
  }
  // Collect data rows
  let rows = Array::new(capacity=4)
  let mut pos = start + 2
  while pos < len {
    let lc = lines[pos].content
    if lc == "" || lc[0] != '|' {
      break
    }
    let cells = split_table_row(lc)
    if cells.length() == alignments.length() {
      rows.push(cells)
    }
    pos = pos + 1
  }
  // Build HTML block with table
  let html = render_table(header_cells, alignments, rows)
  let consumed = pos - start
  Some((@types.Block::HTMLBlock(html), consumed))
}

fn is_table_delimiter(line : String) -> Bool {
  let len = line.length()
  if len == 0 || line[0] != '|' {
    return false
  }
  let mut i = 0
  while i < len {
    let c = line[i]
    if c == '|' || c == ' ' || c == '\t' || c == ':' || c == '-' {
      i = i + 1
    } else {
      return false
    }
  }
  true
}

fn parse_table_alignments(line : String) -> Array[String] {
  let result = Array::new(capacity=4)
  let len = line.length()
  let mut i = 0
  while i < len {
    if line[i] == '|' {
      i = i + 1
    }
    let start = i
    while i < len && line[i] != '|' {
      i = i + 1
    }
    let cell = trim_spaces(line.substring(start=start, end=i))
    let left = cell.length() > 0 && cell[0] == ':'
    let right = cell.length() > 0 && cell[cell.length() - 1] == ':'
    if left && right {
      result.push("center")
    } else if right {
      result.push("right")
    } else {
      result.push("left")
    }
  }
  result
}

fn split_table_row(line : String) -> Array[String] {
  let mut result = Array::new(capacity=4)
  let len = line.length()
  let mut i = 0
  while i < len {
    if line[i] == '|' {
      i = i + 1
    }
    let start = i
    while i < len && line[i] != '|' {
      i = i + 1
    }
    let cell = trim_spaces(line.substring(start=start, end=i))
    result.push(cell)
  }
  // Skip first empty cell if line starts with |
  if result.length() > 0 && result[0] == "" {
    let new_result = Array::new(capacity=result.length() - 1)
    let mut j = 1
    while j < result.length() {
      new_result.push(result[j])
      j = j + 1
    }
    result = new_result
  }
  // Skip last empty cell if line ends with |
  if result.length() > 0 && result[result.length() - 1] == "" {
    result.pop() |> ignore
  }
  result
}


fn trim_spaces(s : String) -> String {
  let len = s.length()
  let mut start = 0
  while start < len && (s[start] == ' ' || s[start] == '\t') {
    start = start + 1
  }
  let mut end = len
  while end > start && (s[end - 1] == ' ' || s[end - 1] == '\t') {
    end = end - 1
  }
  s.substring(start=start, end=end)
}

fn render_table(header : Array[String], aligns : Array[String], rows : Array[Array[String]]) -> String {
  let mut html = "<table>\n<thead>\n<tr>\n"
  let mut i = 0
  while i < header.length() {
    let align = if i < aligns.length() { aligns[i] } else { "left" }
    html = html + "<th align=\"" + align + "\">" + html_escape_cell(header[i]) + "</th>\n"
    i = i + 1
  }
  html = html + "</tr>\n</thead>\n<tbody>\n"
  let mut r = 0
  while r < rows.length() {
    html = html + "<tr>\n"
    let mut c = 0
    while c < rows[r].length() {
      let align = if c < aligns.length() { aligns[c] } else { "left" }
      html = html + "<td align=\"" + align + "\">" + html_escape_cell(rows[r][c]) + "</td>\n"
      c = c + 1
    }
    html = html + "</tr>\n"
    r = r + 1
  }
  html = html + "</tbody>\n</table>\n"
  html
}

fn html_escape_cell(s : String) -> String {
  @util.escape_html(s)
}

// ---- Task Lists ----

pub fn is_task_list_item(line : String) -> (Bool, Bool)? {
  // Check for - [ ] or - [x] pattern
  let len = line.length()
  let mut i = 0
  while i < len && line[i] == ' ' {
    i = i + 1
  }
  if i >= len || (line[i] != '-' && line[i] != '*' && line[i] != '+') {
    return None
  }
  i = i + 1
  if i >= len || line[i] != ' ' {
    return None
  }
  i = i + 1
  if i + 2 >= len || line[i] != '[' {
    return None
  }
  let check = line[i + 1]
  if check != ' ' && check != 'x' && check != 'X' {
    return None
  }
  if line[i + 2] != ']' {
    return None
  }
  Some((check == 'x' || check == 'X', false))
}

// ---- Strikethrough ----

pub fn try_strikethrough(text : String, pos : Int) -> (Array[@types.Inline], Int)? {
  let len = text.length()
  if pos + 4 >= len {
    return None
  }
  if text[pos] != '~' || text[pos + 1] != '~' {
    return None
  }
  // Find closing ~~
  let mut i = pos + 2
  while i + 1 < len {
    if text[i] == '~' && text[i + 1] == '~' {
      let inner = text.substring(start=pos + 2, end=i)
      let inlines = @inline.parse_inlines(inner)
      let result = Array::new(capacity=1)
      result.push(@types.Inline::Strikethrough(inlines))
      return Some((result, i + 2))
    }
    i = i + 1
  }
  None
}
