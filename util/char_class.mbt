/// Character classification predicates for CommonMark parsing.
/// CommonMark is defined in terms of ASCII character classes.

///|
/// Check if c is whitespace (U+0020 space or U+0009 tab).
pub fn is_whitespace(c : UInt16) -> Bool {
  c == ' ' || c == '\t'
}

///|
/// Check if c is a line ending (LF or CR).
pub fn is_line_ending(c : UInt16) -> Bool {
  c == '\n' || c == '\r'
}

///|
/// Check if c is a space or tab (same as is_whitespace).
pub fn is_space_or_tab(c : UInt16) -> Bool {
  c == ' ' || c == '\t'
}

///|
/// Check if c is ASCII punctuation per CommonMark spec definition.
/// Ranges: 0x21-0x2F, 0x3A-0x40, 0x5B-0x60, 0x7B-0x7E
pub fn is_ascii_punctuation(c : UInt16) -> Bool {
  (c >= 0x21 && c <= 0x2F) ||
  (c >= 0x3A && c <= 0x40) ||
  (c >= 0x5B && c <= 0x60) ||
  (c >= 0x7B && c <= 0x7E)
}

///|
/// Check if c is a Unicode punctuation character.
pub fn is_unicode_punctuation(c : UInt16) -> Bool {
  (c >= 0x00A1 && c <= 0x00BF) ||
  (c >= 0x2010 && c <= 0x2027) ||
  (c >= 0x2030 && c <= 0x205E) ||
  c == 0x00A0 ||
  c == 0x2028 ||
  c == 0x2029 ||
  c == 0x202F
}

///|
/// Check if c is alphabetic (A-Z or a-z).
pub fn is_alpha(c : UInt16) -> Bool {
  (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
}

///|
/// Check if c is a decimal digit (0-9).
pub fn is_digit(c : UInt16) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// Check if c is alphanumeric.
pub fn is_alphanumeric(c : UInt16) -> Bool {
  is_alpha(c) || is_digit(c)
}

///|
/// Check if c is lowercase alpha (a-z).
pub fn is_lower_alpha(c : UInt16) -> Bool {
  c >= 'a' && c <= 'z'
}

///|
/// Check if c is uppercase alpha (A-Z).
pub fn is_upper_alpha(c : UInt16) -> Bool {
  c >= 'A' && c <= 'Z'
}

///|
/// Check if c is a hexadecimal digit (0-9, a-f, A-F).
pub fn is_hexdig(c : UInt16) -> Bool {
  is_digit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

///|
/// Check if c is an escapable ASCII punctuation character.
/// These characters lose their special meaning when preceded by a backslash.
pub fn is_escapable(c : UInt16) -> Bool {
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
