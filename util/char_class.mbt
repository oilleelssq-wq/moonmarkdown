// Character classification predicates for CommonMark parsing.
// CommonMark is defined in terms of ASCII character classes.

/// Whitespace: space (U+0020) or tab (U+0009).
fn is_whitespace(c : Char) -> Bool {
  c == ' ' || c == '\t'
}

/// Line ending: LF or CR.
fn is_line_ending(c : Char) -> Bool {
  c == '\n' || c == '\r'
}

/// Space or tab (same as is_whitespace).
fn is_space_or_tab(c : Char) -> Bool {
  c == ' ' || c == '\t'
}

/// ASCII punctuation as defined by CommonMark spec.
fn is_ascii_punctuation(c : Char) -> Bool {
  let code = c.to_int()
  (code >= 0x21 && code <= 0x2F) ||
  (code >= 0x3A && code <= 0x40) ||
  (code >= 0x5B && code <= 0x60) ||
  (code >= 0x7B && code <= 0x7E)
}

/// Unicode punctuation (Pc, Pd, Pe, Pf, Pi, Po, Ps categories).
/// For simplicity in CommonMark, this is a reasonable approximation.
fn is_unicode_punctuation(c : Char) -> Bool {
  let code = c.to_int()
  // General Unicode punctuation ranges
  (code >= 0x00A1 && code <= 0x00BF) ||
  (code >= 0x2010 && code <= 0x2027) ||
  (code >= 0x2030 && code <= 0x205E) ||
  code == 0x00A0 || // NBSP
  code == 0x2000 || code == 0x2001 || code == 0x2002 || code == 0x2003 ||
  code == 0x2004 || code == 0x2005 || code == 0x2006 || code == 0x2007 ||
  code == 0x2008 || code == 0x2009 || code == 0x200A || code == 0x2028 ||
  code == 0x2029 || code == 0x202F
}

/// Is c a valid domain character for autolinks?
fn is_alpha(c : Char) -> Bool {
  let code = c.to_int()
  (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)
}

fn is_digit(c : Char) -> Bool {
  let code = c.to_int()
  code >= 0x30 && code <= 0x39
}

fn is_alphanumeric(c : Char) -> Bool {
  is_alpha(c) || is_digit(c)
}

fn is_lower_alpha(c : Char) -> Bool {
  let code = c.to_int()
  code >= 0x61 && code <= 0x7A
}

fn is_upper_alpha(c : Char) -> Bool {
  let code = c.to_int()
  code >= 0x41 && code <= 0x5A
}

/// Hex digit (0-9, a-f, A-F).
fn is_hexdig(c : Char) -> Bool {
  is_digit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

/// Is the character an escapable ASCII punctuation character?
fn is_escapable(c : Char) -> Bool {
  match c {
    '!' | '"' | '#' | '$' | '%' | '&' | '\'' | '(' | ')' |
    '*' | '+' | ',' | '-' | '.' | '/' | ':' | ';' | '<' |
    '=' | '>' | '?' | '@' | '[' | '\\' | ']' | '^' | '_' |
    '`' | '{' | '|' | '}' | '~' => true
    _ => false
  }
}
