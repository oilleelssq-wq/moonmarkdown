// Inline parser: converts raw text within leaf blocks to inline AST nodes.

///|
pub fn parse_inlines(text : String) -> Array[@types.Inline] {
  parse_inlines_with_options(text, @types.MarkdownOptions::default())
}

///|
pub fn parse_inlines_with_options(
  text : String,
  options : @types.MarkdownOptions,
) -> Array[@types.Inline] {
  parse_inlines_with_refs(text, options, [])
}

///|
pub fn parse_inlines_with_refs(
  text : String,
  options : @types.MarkdownOptions,
  refs : Array[(String, String, String?)],
) -> Array[@types.Inline] {
  if text == "" {
    return []
  }
  let p = InlineParser::new(text, options, refs)
  p.parse()
}

///|
priv struct InlineParser {
  text : String
  len : Int
  mut pos : Int
  options : @types.MarkdownOptions
  refs : Array[(String, String, String?)]
}

///|
fn InlineParser::new(
  text : String,
  options : @types.MarkdownOptions,
  refs : Array[(String, String, String?)],
) -> InlineParser {
  { text, len: text.length(), pos: 0, options, refs }
}

///|
fn InlineParser::parse(self : InlineParser) -> Array[@types.Inline] {
  let inlines = Array::new(capacity=8)
  let mut buf = ""
  while self.pos < self.len {
    let c = self.text[self.pos]
    if self.options.gfm && c == '~' {
      match self.try_strikethrough() {
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
    if self.options.entities && c == '&' {
      match self.try_entity() {
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
    if c == '\\' && self.pos + 1 < self.len {
      let next = self.text[self.pos + 1]
      if is_escapable(next) {
        if buf != "" {
          inlines.push(@types.Inline::Text(buf))
          buf = ""
        }
        inlines.push(
          @types.Inline::Text(self.text[self.pos + 1:self.pos + 2].to_owned()),
        )
        self.pos = self.pos + 2
        continue
      }
    }
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
      if self.options.html {
        match self.try_raw_html() {
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
    }
    if c == '\\' && self.pos + 1 < self.len {
      let n = self.text[self.pos + 1]
      if n == '\n' || n == '\r' {
        if buf != "" {
          inlines.push(@types.Inline::Text(buf))
          buf = ""
        }
        inlines.push(@types.Inline::HardBreak)
        self.pos = self.pos + 1
        if self.pos + 1 < self.len &&
          self.text[self.pos] == '\r' &&
          self.text[self.pos + 1] == '\n' {
          self.pos = self.pos + 2
        } else {
          self.pos = self.pos + 1
        }
        continue
      }
    }
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
    buf = buf + self.text[self.pos:self.pos + 1].to_owned()
    self.pos = self.pos + 1
  }
  if buf != "" {
    inlines.push(@types.Inline::Text(buf))
  }
  inlines
}

///|
fn InlineParser::try_emphasis(
  self : InlineParser,
  marker : UInt16,
) -> Array[@types.Inline]? {
  let start = self.pos
  let mut count = 0
  while self.pos < self.len && self.text[self.pos] == marker && count < 3 {
    count = count + 1
    self.pos = self.pos + 1
  }
  let can_open = self.pos < self.len &&
    self.text[self.pos] != ' ' &&
    self.text[self.pos] != '\t' &&
    self.text[self.pos] != '\n'
  if !can_open {
    self.pos = start
    return None
  }
  let content_start = self.pos
  let mut close_pos = content_start
  while close_pos < self.len {
    if self.text[close_pos] == marker {
      let can_close = close_pos > content_start &&
        (
          close_pos == 0 ||
          (self.text[close_pos - 1] != ' ' && self.text[close_pos - 1] != '\t')
        )
      if can_close {
        let mut ccount = 0
        let mut cp = close_pos
        while cp < self.len && self.text[cp] == marker && ccount < count {
          ccount = ccount + 1
          cp = cp + 1
        }
        if ccount == count {
          let inner_text = self.text[content_start:close_pos].to_owned()
          let inner_inlines = parse_inlines_with_refs(
            inner_text,
            self.options,
            self.refs,
          )
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

///|
fn InlineParser::try_link(self : InlineParser) -> Array[@types.Inline]? {
  let start = self.pos
  self.pos = self.pos + 1
  let mut text_end = self.pos
  while text_end < self.len && self.text[text_end] != ']' {
    text_end = text_end + 1
  }
  if text_end >= self.len {
    self.pos = start
    return None
  }
  let link_text = self.text[self.pos:text_end].to_owned()
  if text_end + 1 < self.len && self.text[text_end + 1] == '(' {
    return self.finish_inline_link(start, link_text, text_end)
  }
  if self.options.reference_links {
    match self.finish_reference_link(start, link_text, text_end) {
      Some(nodes) => return Some(nodes)
      _ => ()
    }
  }
  self.pos = start
  None
}

///|
fn InlineParser::finish_inline_link(
  self : InlineParser,
  start : Int,
  link_text : String,
  text_end : Int,
) -> Array[@types.Inline]? {
  let url_start = text_end + 2
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
  url_end = url_end - 1
  let url_part = self.text[url_start:url_end].to_owned()
  let (final_url, title) = parse_url_and_title(url_part)
  let children = parse_inlines_with_refs(link_text, self.options, self.refs)
  self.pos = url_end + 1
  let result = Array::new(capacity=1)
  result.push(@types.Inline::Link(children, final_url, title))
  Some(result)
}

///|
fn InlineParser::finish_reference_link(
  self : InlineParser,
  start : Int,
  link_text : String,
  text_end : Int,
) -> Array[@types.Inline]? {
  let mut label = link_text
  let mut end_pos = text_end + 1
  if text_end + 1 < self.len && self.text[text_end + 1] == '[' {
    let label_start = text_end + 2
    let mut label_end = label_start
    while label_end < self.len && self.text[label_end] != ']' {
      label_end = label_end + 1
    }
    if label_end >= self.len {
      self.pos = start
      return None
    }
    if label_end > label_start {
      label = self.text[label_start:label_end].to_owned()
    }
    end_pos = label_end + 1
  }
  match find_reference(self.refs, normalize_label(label)) {
    Some((url, title)) => {
      self.pos = end_pos
      let result = Array::new(capacity=1)
      let children = parse_inlines_with_refs(link_text, self.options, self.refs)
      result.push(@types.Inline::Link(children, url, title))
      Some(result)
    }
    _ => {
      self.pos = start
      None
    }
  }
}

///|
fn InlineParser::try_image(self : InlineParser) -> @types.Inline? {
  let start = self.pos
  self.pos = self.pos + 1
  let link = self.try_link()
  match link {
    Some(nodes) =>
      if nodes.length() == 1 {
        match nodes[0] {
          @types.Inline::Link(children, url, title) =>
            Some(@types.Inline::Image(children, url, title))
          _ => {
            self.pos = start
            None
          }
        }
      } else {
        self.pos = start
        None
      }
    _ => {
      self.pos = start
      None
    }
  }
}

///|
fn InlineParser::try_autolink(self : InlineParser) -> @types.Inline? {
  let start = self.pos
  self.pos = self.pos + 1
  let mut end = self.pos
  while end < self.len &&
        self.text[end] != '>' &&
        self.text[end] != '\n' &&
        self.text[end] != ' ' {
    end = end + 1
  }
  if end >= self.len || self.text[end] != '>' {
    self.pos = start
    return None
  }
  let content = self.text[self.pos:end].to_owned()
  if content == "" || content[0] == '>' {
    self.pos = start
    return None
  }
  self.pos = end + 1
  Some(@types.Inline::Autolink(content))
}

///|
fn InlineParser::try_raw_html(self : InlineParser) -> @types.Inline? {
  let start = self.pos
  if self.text[start] != '<' {
    return None
  }
  let mut end = start + 1
  while end < self.len && self.text[end] != '>' && self.text[end] != '\n' {
    end = end + 1
  }
  if end >= self.len || self.text[end] != '>' {
    return None
  }
  if is_html_tag(self.text[start:end + 1].to_owned()) {
    self.pos = end + 1
    Some(@types.Inline::RawHTML(self.text[start:end + 1].to_owned()))
  } else {
    None
  }
}

///|
fn InlineParser::try_entity(self : InlineParser) -> @types.Inline? {
  let start = self.pos
  let mut end = start + 1
  while end < self.len && end - start <= 32 && self.text[end] != ';' {
    end = end + 1
  }
  if end >= self.len || self.text[end] != ';' {
    return None
  }
  let name = self.text[start + 1:end].to_owned()
  match @util.decode_entity(name) {
    Some(decoded) => {
      self.pos = end + 1
      Some(@types.Inline::HtmlEntity(decoded))
    }
    _ => None
  }
}

///|
fn InlineParser::try_strikethrough(
  self : InlineParser,
) -> Array[@types.Inline]? {
  let start = self.pos
  if start + 3 >= self.len ||
    self.text[start] != '~' ||
    self.text[start + 1] != '~' {
    return None
  }
  let mut end = start + 2
  while end + 1 < self.len {
    if self.text[end] == '~' && self.text[end + 1] == '~' {
      let inner = self.text[start + 2:end].to_owned()
      let inlines = parse_inlines_with_refs(inner, self.options, self.refs)
      self.pos = end + 2
      let result = Array::new(capacity=1)
      result.push(@types.Inline::Strikethrough(inlines))
      return Some(result)
    }
    end = end + 1
  }
  None
}

///|
fn InlineParser::try_code_span(self : InlineParser) -> String? {
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
      while scan < self.len &&
            self.text[scan] == '`' &&
            close_count < open_count {
        close_count = close_count + 1
        scan = scan + 1
      }
      if close_count == open_count {
        let content = self.text[self.pos:search].to_owned()
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

///|
fn parse_url_and_title(url_part : String) -> (String, String?) {
  let mut title : String? = None
  let mut space_pos = 0
  while space_pos < url_part.length() &&
        url_part[space_pos] != ' ' &&
        url_part[space_pos] != '\t' {
    space_pos = space_pos + 1
  }
  let url = if space_pos < url_part.length() {
    let real_url = url_part[0:space_pos].to_owned()
    let mut ti = space_pos
    while ti < url_part.length() &&
          (url_part[ti] == ' ' || url_part[ti] == '\t') {
      ti = ti + 1
    }
    if ti < url_part.length() {
      let tc = url_part[ti]
      if tc == '"' {
        title = parse_quoted_title(url_part, ti + 1, '"')
      } else if tc == '\'' {
        title = parse_quoted_title(url_part, ti + 1, '\'')
      } else if tc == '(' {
        title = parse_quoted_title(url_part, ti + 1, ')')
      }
    }
    real_url
  } else {
    url_part
  }
  let final_url = if url.length() > 2 &&
    url[0] == '<' &&
    url[url.length() - 1] == '>' {
    url[1:url.length() - 1].to_owned()
  } else {
    url
  }
  (final_url, title)
}

///|
fn parse_quoted_title(s : String, start : Int, close : UInt16) -> String? {
  let mut end = start
  while end < s.length() && s[end] != close {
    end = end + 1
  }
  if end < s.length() {
    Some(s[start:end].to_owned())
  } else {
    None
  }
}

///|
fn find_reference(
  refs : Array[(String, String, String?)],
  label : String,
) -> (String, String?)? {
  let mut i = 0
  while i < refs.length() {
    let (ref_label, url, title) = refs[i]
    if ref_label == label {
      return Some((url, title))
    }
    i = i + 1
  }
  None
}

///|
pub fn normalize_label(label : String) -> String {
  let mut result = ""
  let mut last_space = false
  let lower = label.to_lower()
  let mut i = 0
  while i < lower.length() {
    let c = lower[i]
    if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
      if !last_space && result != "" {
        result = result + " "
      }
      last_space = true
    } else {
      result = result + lower[i:i + 1].to_owned()
      last_space = false
    }
    i = i + 1
  }
  result.trim().to_owned()
}

///|
fn is_html_tag(s : String) -> Bool {
  if s.length() < 3 || s[0] != '<' || s[s.length() - 1] != '>' {
    return false
  }
  if s.length() >= 4 && s[1] == '!' {
    return true
  }
  if s.length() >= 3 && s[1] == '?' {
    return true
  }
  let start = if s[1] == '/' { 2 } else { 1 }
  if start >= s.length() - 1 {
    return false
  }
  let c = s[start]
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
}

///|
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
  s[s_start:s_end].to_owned()
}

///|
fn is_escapable(c : UInt16) -> Bool {
  c == '!' ||
  c == '"' ||
  c == '#' ||
  c == '$' ||
  c == '%' ||
  c == '&' ||
  c == '\'' ||
  c == '(' ||
  c == ')' ||
  c == '*' ||
  c == '+' ||
  c == ',' ||
  c == '-' ||
  c == '.' ||
  c == '/' ||
  c == ':' ||
  c == ';' ||
  c == '<' ||
  c == '=' ||
  c == '>' ||
  c == '?' ||
  c == '@' ||
  c == '[' ||
  c == '\\' ||
  c == ']' ||
  c == '^' ||
  c == '_' ||
  c == '`' ||
  c == '{' ||
  c == '|' ||
  c == '}' ||
  c == '~'
}
