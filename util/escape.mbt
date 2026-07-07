// HTML entity decoding and backslash escape utilities.

///|
pub fn decode_entity(name : String) -> String? {
  if name == "" {
    return None
  }
  if name[0] == '#' {
    if name.length() > 1 && (name[1] == 'x' || name[1] == 'X') {
      decode_hex_entity(name[2:].to_owned())
    } else {
      decode_dec_entity(name[1:].to_owned())
    }
  } else {
    lookup_named_entity(name)
  }
}

///|
fn decode_hex_entity(hex : String) -> String? {
  let mut val = 0
  let mut i = 0
  while i < hex.length() {
    let c = hex[i]
    if c >= '0' && c <= '9' {
      val = val * 16 + c.to_int() - 0x30
    } else if c >= 'a' && c <= 'f' {
      val = val * 16 + c.to_int() - 0x61 + 10
    } else if c >= 'A' && c <= 'F' {
      val = val * 16 + c.to_int() - 0x41 + 10
    } else {
      return None
    }
    if val > 0x10FFFF {
      return Some("\u{FFFD}")
    }
    i = i + 1
  }
  if val == 0 || (val >= 0xD800 && val <= 0xDFFF) || val > 0x10FFFF {
    Some("\u{FFFD}")
  } else {
    Some(Int::unsafe_to_char(val).to_string())
  }
}

///|
fn decode_dec_entity(dec : String) -> String? {
  let mut val = 0
  let mut i = 0
  while i < dec.length() {
    let c = dec[i]
    if c >= '0' && c <= '9' {
      val = val * 10 + c.to_int() - 0x30
    } else {
      return None
    }
    if val > 0x10FFFF {
      return Some("\u{FFFD}")
    }
    i = i + 1
  }
  if val == 0 || (val >= 0xD800 && val <= 0xDFFF) || val > 0x10FFFF {
    Some("\u{FFFD}")
  } else {
    Some(Int::unsafe_to_char(val).to_string())
  }
}

///|
fn lookup_named_entity(name : String) -> String? {
  match name {
    "amp" => Some("&")
    "lt" => Some("<")
    "gt" => Some(">")
    "quot" => Some("\"")
    "apos" => Some("'")
    "nbsp" => Some("\u{00A0}")
    "iexcl" => Some("\u{00A1}")
    "cent" => Some("\u{00A2}")
    "pound" => Some("\u{00A3}")
    "curren" => Some("\u{00A4}")
    "yen" => Some("\u{00A5}")
    "brvbar" => Some("\u{00A6}")
    "sect" => Some("\u{00A7}")
    "uml" => Some("\u{00A8}")
    "copy" => Some("\u{00A9}")
    "ordf" => Some("\u{00AA}")
    "laquo" => Some("\u{00AB}")
    "not" => Some("\u{00AC}")
    "shy" => Some("\u{00AD}")
    "reg" => Some("\u{00AE}")
    "macr" => Some("\u{00AF}")
    "deg" => Some("\u{00B0}")
    "plusmn" => Some("\u{00B1}")
    "sup2" => Some("\u{00B2}")
    "sup3" => Some("\u{00B3}")
    "acute" => Some("\u{00B4}")
    "micro" => Some("\u{00B5}")
    "para" => Some("\u{00B6}")
    "middot" => Some("\u{00B7}")
    "cedil" => Some("\u{00B8}")
    "sup1" => Some("\u{00B9}")
    "ordm" => Some("\u{00BA}")
    "raquo" => Some("\u{00BB}")
    "frac14" => Some("\u{00BC}")
    "frac12" => Some("\u{00BD}")
    "frac34" => Some("\u{00BE}")
    "iquest" => Some("\u{00BF}")
    "times" => Some("\u{00D7}")
    "divide" => Some("\u{00F7}")
    "ndash" => Some("\u{2013}")
    "mdash" => Some("\u{2014}")
    "lsquo" => Some("\u{2018}")
    "rsquo" => Some("\u{2019}")
    "sbquo" => Some("\u{201A}")
    "ldquo" => Some("\u{201C}")
    "rdquo" => Some("\u{201D}")
    "bdquo" => Some("\u{201E}")
    "dagger" => Some("\u{2020}")
    "Dagger" => Some("\u{2021}")
    "bull" => Some("\u{2022}")
    "hellip" => Some("\u{2026}")
    "permil" => Some("\u{2030}")
    "prime" => Some("\u{2032}")
    "Prime" => Some("\u{2033}")
    "lsaquo" => Some("\u{2039}")
    "rsaquo" => Some("\u{203A}")
    "oline" => Some("\u{203E}")
    "frasl" => Some("\u{2044}")
    "euro" => Some("\u{20AC}")
    "larr" => Some("\u{2190}")
    "uarr" => Some("\u{2191}")
    "rarr" => Some("\u{2192}")
    "darr" => Some("\u{2193}")
    "harr" => Some("\u{2194}")
    _ => None
  }
}

///|
pub fn escape_html(s : String) -> String {
  let mut result = ""
  let mut i = 0
  while i < s.length() {
    let c = s[i:i + 1].to_owned()
    match s[i] {
      '&' => result = result + "&amp;"
      '<' => result = result + "&lt;"
      '>' => result = result + "&gt;"
      '"' => result = result + "&quot;"
      _ => result = result + c
    }
    i = i + 1
  }
  result
}
