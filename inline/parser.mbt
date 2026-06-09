// Inline parser: converts raw text within leaf blocks to inline AST nodes.

pub fn parse_inlines(text : String) -> Array[@types.Inline] {
  if text == "" {
    return []
  }
  let p = InlineParser::new(text)
  p.parse()
}

struct InlineParser {
  text : String
  len : Int
  mut pos : Int
}

fn InlineParser::new(text : String) -> InlineParser {
  { text: text, len: text.length(), pos: 0 }
}

fn InlineParser::parse(self : InlineParser) -> Array[@types.Inline] {
  let inlines = Array::new(capacity=8)
  let mut buf = ""
  while self.pos < self.len {
    let c = self.text[self.pos]
    // Emphasis: * and _
    if c == '*' || c == '_' {
      let emphasis = self.try_emphasis(c)
      match emphasis {
        Some(nodes) => {
          if buf != "" {
            inlines.push(@types.Inline::Text(buf))
            buf = ""
          }
          for j = 0; j < nodes.length(); j = j + 1 {
            inlines.push(nodes[j])
          }
          continue
        }
        _ => ()
      }
    }
    // Backslash escape
    if c == '\\' && self.pos + 1 < self.len {
      let next = self.text[self.pos + 1]
      if is_escapable(next) {
        if buf != "" {
          inlines.push(@types.Inline::Text(buf))
          buf = ""
        }
        inlines.push(@types.Inline::Text(self.text.substring(start=self.pos + 1, end=self.pos + 2)))
        self.pos = self.pos + 2
        continue
      }
    }
    // Code span
    if c == '`' {
      let code = self.try_code_span()
      match code {
        Some(content) => {
          if buf != "" {
            inlines.push(@types.Inline::Text(buf))
            buf = ""
          }
          inlines.push(@types.Inline::CodeSpan(content))
          continue
        }
        _ => ()
      }
    }
    // Link or image
    if c == '[' {
      let link = self.try_link()
      match link {
        Some(nodes) => {
          if buf != "" {
            inlines.push(@types.Inline::Text(buf))
            buf = ""
          }
          for j = 0; j < nodes.length(); j = j + 1 {
            inlines.push(nodes[j])
          }
          continue
        }
        _ => ()
      }
    }
    if c == '!' && self.pos + 1 < self.len && self.text[self.pos + 1] == '[' {
      let img = self.try_image()
      match img {
        Some(node) => {
          if buf != "" {
            inlines.push(@types.Inline::Text(buf))
            buf = ""
          }
          inlines.push(node)
          continue
        }
        _ => ()
      }
    }
    // Autolink
    if c == '<' {
      let autolink = self.try_autolink()
      match autolink {
        Some(node) => {
          if buf != "" {
            inlines.push(@types.Inline::Text(buf))
            buf = ""
          }
          inlines.push(node)
          continue
        }
        _ => ()
      }
    }
    // Hard break (backslash-newline)
    if c == '\\' && self.pos + 1 < self.len {
      let n = self.text[self.pos + 1]
      if n == '\n' || n == '\r' {
        if buf != "" {
          inlines.push(@types.Inline::Text(buf))
          buf = ""
        }
        inlines.push(@types.Inline::HardBreak)
        self.pos = self.pos + 1
        if self.pos + 1 < self.len && self.text[self.pos] == '\r' && self.text[self.pos + 1] == '\n' {
          self.pos = self.pos + 2
        } else {
          self.pos = self.pos + 1
        }
        continue
      }
    }
    // Soft break
    if c == '\n' || c == '\r' {
      if buf != "" {
        inlines.push(@types.Inline::Text(buf))
        buf = ""
      }
      inlines.push(@types.Inline::SoftBreak)
      if c == '\r' && self.pos + 1 < self.len && self.text[self.pos + 1] == '\n' {
        self.pos = self.pos + 2
      } else {
        self.pos = self.pos + 1
      }
      continue
    }
    buf = buf + self.text.substring(start=self.pos, end=self.pos + 1)
    self.pos = self.pos + 1
  }
  if buf != "" {
    inlines.push(@types.Inline::Text(buf))
  }
  inlines
}

// --- Emphasis ---

fn InlineParser::try_emphasis(self : InlineParser, marker : UInt16) -> Option[Array[@types.Inline]] {
  let start = self.pos
  // Count delimiters
  let mut count = 0
  while self.pos < self.len && self.text[self.pos] == marker && count < 3 {
    count = count + 1
    self.pos = self.pos + 1
  }
  // Check left-flanking: cannot be followed by space or at end
  let can_open = self.pos < self.len && self.text[self.pos] != ' ' && self.text[self.pos] != '\t' && self.text[self.pos] != '\n'
  if !can_open {
    self.pos = start
    return None
  }
  // Find matching closer
  let content_start = self.pos
  let mut found_close = false
  let mut close_pos = content_start
  while close_pos < self.len {
    if self.text[close_pos] == marker {
      // Check if this is a valid closer
      let can_close = close_pos > content_start && (close_pos == 0 || (self.text[close_pos - 1] != ' ' && self.text[close_pos - 1] != '\t'))
      if can_close {
        let mut ccount = 0
        let mut cp = close_pos
        while cp < self.len && self.text[cp] == marker && ccount < count {
          ccount = ccount + 1
          cp = cp + 1
        }
        if ccount == count {
          // Found! Parse content and wrap
          let inner_text = self.text.substring(start=content_start, end=close_pos)
          let inner_inlines = parse_inlines(inner_text)
          let node = if count == 1 {
            @types.Inline::Emphasis(inner_inlines)
          } else if count == 2 {
            @types.Inline::Strong(inner_inlines)
          } else {
            @types.Inline::Strong([@types.Inline::Emphasis(inner_inlines)])
          }
          self.pos = close_pos + count
          let result = Array::new(capacity=1)
          result.push(node)
          return Some(result)
        }
      }
    }
    close_pos = close_pos + 1
  }
  self.pos = start
  None
}

// --- Links ---

fn InlineParser::try_link(self : InlineParser) -> Option[Array[@types.Inline]] {
  let start = self.pos
  self.pos = self.pos + 1 // skip [
  // Find closing ]
  let mut text_end = self.pos
  while text_end < self.len && self.text[text_end] != ']' {
    text_end = text_end + 1
  }
  if text_end >= self.len || text_end + 1 >= self.len || self.text[text_end + 1] != '(' {
    self.pos = start
    return None
  }
  let link_text = self.text.substring(start=self.pos, end=text_end)
  let url_start = text_end + 2 // after ](
  // Find closing )
  let mut url_end = url_start
  let mut paren_depth = 1
  while url_end < self.len && paren_depth > 0 {
    if self.text[url_end] == '(' {
      paren_depth = paren_depth + 1
    } else if self.text[url_end] == ')' {
      paren_depth = paren_depth - 1
    }
    url_end = url_end + 1
  }
  if paren_depth != 0 {
    self.pos = start
    return None
  }
  url_end = url_end - 1 // before )
  let url_part = self.text.substring(start=url_start, end=url_end)
  let mut title : String? = None
  let mut url_end_pos = url_part.length()
  // Find optional title
  let mut space_pos = 0
  while space_pos < url_part.length() && url_part[space_pos] != ' ' && url_part[space_pos] != '\t' {
    space_pos = space_pos + 1
  }
  let url = if space_pos < url_part.length() {
    let real_url = url_part.substring(start=0, end=space_pos)
    let mut ti = space_pos
    while ti < url_part.length() && (url_part[ti] == ' ' || url_part[ti] == '\t') {
      ti = ti + 1
    }
    if ti < url_part.length() {
      let tc = url_part[ti]
      if tc == '"' {
        let tstart = ti + 1
        let mut tend = ti + 1
        while tend < url_part.length() && url_part[tend] != '"' {
          tend = tend + 1
        }
        title = Some(url_part.substring(start=tstart, end=tend))
      } else if tc == '\'' {
        let tstart = ti + 1
        let mut tend = ti + 1
        while tend < url_part.length() && url_part[tend] != '\'' {
          tend = tend + 1
        }
        title = Some(url_part.substring(start=tstart, end=tend))
      } else if tc == '(' {
        let tstart = ti + 1
        let mut tend = ti + 1
        while tend < url_part.length() && url_part[tend] != ')' {
          tend = tend + 1
        }
        title = Some(url_part.substring(start=tstart, end=tend))
      }
    }
    real_url
  } else {
    url_part
  }
  // Strip optional < > around URL
  let final_url = if url.length() > 2 && url[0] == '<' && url[url.length() - 1] == '>' {
    url.substring(start=1, end=url.length() - 1)
  } else {
    url
  }
  let children = parse_inlines(link_text)
  self.pos = url_end + 1
  let result = Array::new(capacity=1)
  result.push(@types.Inline::Link(children, final_url, title))
  Some(result)
}

// --- Image ---

fn InlineParser::try_image(self : InlineParser) -> Option[@types.Inline] {
  let start = self.pos
  self.pos = self.pos + 1 // skip !
  let link = self.try_link()
  match link {
    Some(nodes) => {
      if nodes.length() == 1 {
        match nodes[0] {
          @types.Inline::Link(children, url, title) => {
            Some(@types.Inline::Image(children, url, title))
          }
          _ => { self.pos = start; None }
        }
      } else {
        self.pos = start
        None
      }
    }
    _ => { self.pos = start; None }
  }
}

// --- Autolink ---

fn InlineParser::try_autolink(self : InlineParser) -> Option[@types.Inline] {
  let start = self.pos
  self.pos = self.pos + 1 // skip <
  let mut end = self.pos
  while end < self.len && self.text[end] != '>' && self.text[end] != '\n' && self.text[end] != ' ' {
    end = end + 1
  }
  if end >= self.len || self.text[end] != '>' {
    self.pos = start
    return None
  }
  let content = self.text.substring(start=self.pos, end=end)
  if content == "" || content[0] == '>' {
    self.pos = start
    return None
  }
  self.pos = end + 1
  Some(@types.Inline::Autolink(content))
}

// --- Code Span ---

fn InlineParser::try_code_span(self : InlineParser) -> Option[String] {
  let start = self.pos
  let mut open_count = 0
  while self.pos < self.len && self.text[self.pos] == '`' {
    open_count = open_count + 1
    self.pos = self.pos + 1
  }
  let mut search = self.pos
  while search < self.len {
    if self.text[search] == '`' {
      let mut close_count = 0
      let mut scan = search
      while scan < self.len && self.text[scan] == '`' && close_count < open_count {
        close_count = close_count + 1
        scan = scan + 1
      }
      if close_count == open_count {
        let content = self.text.substring(start=self.pos, end=search)
        self.pos = search + open_count
        return Some(normalize_code_content(content))
      }
      search = scan
    } else {
      search = search + 1
    }
  }
  self.pos = start
  None
}

fn normalize_code_content(s : String) -> String {
  let len = s.length()
  if len == 0 {
    return ""
  }
  let start = if len > 0 && s[0] == '\n' { 1 } else { 0 }
  let end = if len > start && s[len - 1] == '\n' { len - 1 } else { len }
  let mut s_start = start
  let mut s_end = end
  if s_start < s_end && (s[s_start] == ' ' || s[s_start] == '\t') {
    s_start = s_start + 1
  }
  if s_end > s_start && (s[s_end - 1] == ' ' || s[s_end - 1] == '\t') {
    s_end = s_end - 1
  }
  s.substring(start=s_start, end=s_end)
}

// --- Utilities ---

fn is_escapable(c : UInt16) -> Bool {
  c == '!' || c == '"' || c == '#' || c == '$' || c == '%' || c == '&' ||
  c == '\'' || c == '(' || c == ')' || c == '*' || c == '+' || c == ',' ||
  c == '-' || c == '.' || c == '/' || c == ':' || c == ';' || c == '<' ||
  c == '=' || c == '>' || c == '?' || c == '@' || c == '[' || c == '\\' ||
  c == ']' || c == '^' || c == '_' || c == '`' || c == '{' || c == '|' ||
  c == '}' || c == '~'
}
