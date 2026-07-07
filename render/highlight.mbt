// Simple keyword-based syntax highlighting for multiple languages.

///|
pub fn highlight(code : String, lang : String) -> String {
  match lang {
    "moonbit" | "mbt" => highlight_moonbit(code)
    "js" | "javascript" | "ts" | "typescript" => highlight_js(code)
    "py" | "python" => highlight_python(code)
    "rs" | "rust" => highlight_rust(code)
    "go" | "golang" => highlight_go(code)
    "java" => highlight_java(code)
    "c" | "cpp" | "c++" => highlight_c(code)
    "html" | "htm" => highlight_html(code)
    "css" => highlight_css(code)
    "json" | "yaml" | "yml" | "toml" => highlight_data(code)
    _ => @util.escape_html(code)
  }
}

///|
fn highlight_moonbit(code : String) -> String {
  let kw = [
    "fn", "let", "mut", "pub", "priv", "type", "enum", "struct", "trait", "impl",
    "match", "if", "else", "while", "for", "break", "continue", "return", "import",
    "as", "test", "all", "try", "catch", "throw", "async", "await", "extern", "const",
    "ref", "self", "true", "false",
  ]
  let types = [
    "Int", "String", "Bool", "Char", "Double", "Float", "UInt", "UInt16", "UInt32",
    "UInt64", "Int64", "Byte", "Bytes", "Array", "Map", "Option", "Result", "Unit",
    "Iter",
  ]
  highlight_generic(code, kw, types)
}

///|
fn highlight_js(code : String) -> String {
  let kw = [
    "const", "let", "var", "function", "return", "if", "else", "for", "while", "break",
    "continue", "switch", "case", "default", "new", "this", "class", "extends", "import",
    "export", "from", "async", "await", "try", "catch", "throw", "typeof", "instanceof",
    "of", "in",
  ]
  let types = ["string", "number", "boolean", "null", "undefined", "void"]
  highlight_generic(code, kw, types)
}

///|
fn highlight_python(code : String) -> String {
  let kw = [
    "def", "return", "class", "import", "from", "if", "elif", "else", "for", "while",
    "break", "continue", "pass", "raise", "try", "except", "finally", "with", "as",
    "in", "not", "and", "or", "is", "None", "True", "False", "lambda", "yield", "async",
    "await",
  ]
  let types = [
    "int", "str", "float", "bool", "list", "dict", "tuple", "set", "object", "type",
    "bytes", "bytearray", "range",
  ]
  highlight_generic(code, kw, types)
}

///|
fn highlight_rust(code : String) -> String {
  let kw = [
    "fn", "let", "mut", "pub", "struct", "enum", "trait", "impl", "match", "if",
    "else", "while", "for", "loop", "break", "continue", "return", "use", "mod",
    "crate", "self", "super", "where", "as", "in", "ref", "move", "async", "await",
    "const", "static", "unsafe",
  ]
  let types = [
    "i32", "i64", "u32", "u64", "f32", "f64", "bool", "char", "String", "str", "Vec",
    "Option", "Result", "Box", "Rc", "Arc",
  ]
  highlight_generic(code, kw, types)
}

///|
fn highlight_data(code : String) -> String {
  @util.escape_html(code)
}

///|
fn highlight_generic(
  code : String,
  keywords : Array[String],
  types : Array[String],
) -> String {
  // Simple word-boundary matching
  let mut html = ""
  let len = code.length()
  let mut i = 0

  while i < len {
    let c = code[i]
    // Check for comment start
    if c == '/' && i + 1 < len && code[i + 1] == '/' {
      // Line comment
      let mut j = i
      while j < len && code[j] != '\n' {
        j = j + 1
      }
      html = html +
        "<span class=\"c\">" +
        @util.escape_html(code[i:j].to_owned()) +
        "</span>"
      i = j
      continue
    }
    // String literal
    if c == '"' {
      let start = i
      i = i + 1
      while i < len && code[i] != '"' {
        if code[i] == '\\' {
          i = i + 1
        }
        i = i + 1
      }
      if i < len {
        i = i + 1
      }
      html = html +
        "<span class=\"s\">" +
        @util.escape_html(code[start:i].to_owned()) +
        "</span>"
      continue
    }
    // Number
    if c >= '0' && c <= '9' {
      let start = i
      while i < len &&
            (
              (code[i] >= '0' && code[i] <= '9') ||
              code[i] == '.' ||
              code[i] == '_' ||
              code[i] == 'x' ||
              (code[i] >= 'a' && code[i] <= 'f') ||
              (code[i] >= 'A' && code[i] <= 'F')
            ) {
        i = i + 1
      }
      html = html +
        "<span class=\"m\">" +
        @util.escape_html(code[start:i].to_owned()) +
        "</span>"
      continue
    }
    // Word (identifier or keyword)
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' {
      let start = i
      while i < len &&
            (
              (code[i] >= 'a' && code[i] <= 'z') ||
              (code[i] >= 'A' && code[i] <= 'Z') ||
              (code[i] >= '0' && code[i] <= '9') ||
              code[i] == '_'
            ) {
        i = i + 1
      }
      let word = code[start:i].to_owned()
      let mut found = false
      // Check keywords
      let mut ki = 0
      while ki < keywords.length() {
        if word == keywords[ki] {
          html = html +
            "<span class=\"k\">" +
            @util.escape_html(word) +
            "</span>"
          found = true
          break
        }
        ki = ki + 1
      }
      // Check types
      if !found {
        let mut ti = 0
        while ti < types.length() {
          if word == types[ti] {
            html = html +
              "<span class=\"t\">" +
              @util.escape_html(word) +
              "</span>"
            found = true
            break
          }
          ti = ti + 1
        }
      }
      if !found {
        html = html + @util.escape_html(word)
      }
      continue
    }
    html = html + @util.escape_html(code[i:i + 1].to_owned())
    i = i + 1
  }
  html
}

///|
fn highlight_go(code : String) -> String {
  let kw = [
    "break", "case", "chan", "const", "continue", "default", "defer", "else", "fallthrough",
    "for", "func", "go", "goto", "if", "import", "interface", "map", "package", "range",
    "return", "select", "struct", "switch", "type", "var", "true", "false", "nil",
    "make", "new", "append", "len", "cap", "close", "delete", "copy", "panic", "recover",
  ]
  let types = [
    "int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32",
    "uint64", "float32", "float64", "string", "bool", "byte", "rune", "error", "complex64",
    "complex128",
  ]
  highlight_generic(code, kw, types)
}

///|
fn highlight_java(code : String) -> String {
  let kw = [
    "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class",
    "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally",
    "float", "for", "if", "implements", "import", "int", "interface", "long", "native",
    "new", "package", "private", "protected", "public", "return", "short", "static",
    "strictfp", "super", "switch", "synchronized", "this", "throw", "throws", "transient",
    "try", "void", "volatile", "while", "true", "false", "null",
  ]
  let types = [
    "String", "Integer", "Long", "Double", "Float", "Boolean", "Object", "Class",
    "List", "Map", "Set", "ArrayList", "HashMap",
  ]
  highlight_generic(code, kw, types)
}

///|
fn highlight_c(code : String) -> String {
  let kw = [
    "auto", "break", "case", "char", "const", "continue", "default", "do", "double",
    "else", "enum", "extern", "float", "for", "goto", "if", "int", "long", "register",
    "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef",
    "union", "unsigned", "void", "volatile", "while", "include", "define", "ifdef",
    "ifndef", "endif", "pragma", "NULL",
  ]
  let types = [
    "int", "char", "float", "double", "long", "short", "void", "size_t", "FILE",
    "bool", "int8_t", "uint8_t", "int16_t", "uint16_t", "int32_t", "uint32_t", "int64_t",
    "uint64_t",
  ]
  highlight_generic(code, kw, types)
}

///|
fn highlight_html(code : String) -> String {
  highlight_xml_like(code)
}

///|
fn highlight_xml_like(code : String) -> String {
  let result = @util.escape_html(code)
  result
}

///|
fn highlight_css(code : String) -> String {
  let kw = [
    "color", "background", "font", "margin", "padding", "border", "display", "position",
    "width", "height", "top", "left", "right", "bottom", "flex", "grid", "text",
    "align", "justify", "overflow", "opacity", "transform", "transition", "animation",
    "none", "auto", "inherit", "initial", "important", "block", "inline", "relative",
    "absolute", "fixed", "sticky", "center", "bold", "normal", "italic",
  ]
  let types = [
    "px", "em", "rem", "vh", "vw", "pct", "deg", "s", "ms", "rgb", "rgba", "hsl",
    "hsla", "hex", "url",
  ]
  highlight_generic(code, kw, types)
}
