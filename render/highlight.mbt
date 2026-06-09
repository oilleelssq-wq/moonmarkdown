// Simple keyword-based syntax highlighting for multiple languages.

pub fn highlight(code : String, lang : String) -> String {
  match lang {
    "moonbit" | "mbt" => highlight_moonbit(code)
    "js" | "javascript" | "ts" | "typescript" => highlight_js(code)
    "py" | "python" => highlight_python(code)
    "rs" | "rust" => highlight_rust(code)
    "json" | "yaml" | "yml" | "toml" => highlight_data(code)
    _ => @util.escape_html(code)
  }
}

fn highlight_moonbit(code : String) -> String {
  let kw = [ "fn", "let", "mut", "pub", "priv", "type", "enum", "struct", "trait",
             "impl", "match", "if", "else", "while", "for", "break", "continue",
             "return", "import", "as", "test", "all", "try", "catch", "throw",
             "async", "await", "extern", "const", "ref", "self", "true", "false" ]
  let types = [ "Int", "String", "Bool", "Char", "Double", "Float", "UInt",
                "UInt16", "UInt32", "UInt64", "Int64", "Byte", "Bytes",
                "Array", "Map", "Option", "Result", "Unit", "Iter" ]
  highlight_generic(code, kw, types)
}

fn highlight_js(code : String) -> String {
  let kw = [ "const", "let", "var", "function", "return", "if", "else", "for",
             "while", "break", "continue", "switch", "case", "default", "new",
             "this", "class", "extends", "import", "export", "from", "async",
             "await", "try", "catch", "throw", "typeof", "instanceof", "of", "in" ]
  let types = [ "string", "number", "boolean", "null", "undefined", "void" ]
  highlight_generic(code, kw, types)
}

fn highlight_python(code : String) -> String {
  let kw = [ "def", "return", "class", "import", "from", "if", "elif", "else",
             "for", "while", "break", "continue", "pass", "raise", "try",
             "except", "finally", "with", "as", "in", "not", "and", "or",
             "is", "None", "True", "False", "lambda", "yield", "async", "await" ]
  let types = [ "int", "str", "float", "bool", "list", "dict", "tuple", "set",
                "object", "type", "bytes", "bytearray", "range" ]
  highlight_generic(code, kw, types)
}

fn highlight_rust(code : String) -> String {
  let kw = [ "fn", "let", "mut", "pub", "struct", "enum", "trait", "impl",
             "match", "if", "else", "while", "for", "loop", "break", "continue",
             "return", "use", "mod", "crate", "self", "super", "where", "as",
             "in", "ref", "move", "async", "await", "const", "static", "unsafe" ]
  let types = [ "i32", "i64", "u32", "u64", "f32", "f64", "bool", "char",
                "String", "str", "Vec", "Option", "Result", "Box", "Rc", "Arc" ]
  highlight_generic(code, kw, types)
}

fn highlight_data(code : String) -> String {
  @util.escape_html(code)
}

fn highlight_generic(code : String, keywords : Array[String], types : Array[String]) -> String {
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
      html = html + "<span class=\"c\">" + @util.escape_html(code.substring(start=i, end=j)) + "</span>"
      i = j
      continue
    }
    // String literal
    if c == '"' {
      let start = i
      i = i + 1
      while i < len && code[i] != '"' {
        if code[i] == '\\' { i = i + 1 }
        i = i + 1
      }
      if i < len { i = i + 1 }
      html = html + "<span class=\"s\">" + @util.escape_html(code.substring(start=start, end=i)) + "</span>"
      continue
    }
    // Number
    if c >= '0' && c <= '9' {
      let start = i
      while i < len && (code[i] >= '0' && code[i] <= '9' || code[i] == '.' || code[i] == '_' || code[i] == 'x' || (code[i] >= 'a' && code[i] <= 'f') || (code[i] >= 'A' && code[i] <= 'F')) {
        i = i + 1
      }
      html = html + "<span class=\"m\">" + @util.escape_html(code.substring(start=start, end=i)) + "</span>"
      continue
    }
    // Word (identifier or keyword)
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' {
      let start = i
      while i < len && ((code[i] >= 'a' && code[i] <= 'z') || (code[i] >= 'A' && code[i] <= 'Z') || (code[i] >= '0' && code[i] <= '9') || code[i] == '_') {
        i = i + 1
      }
      let word = code.substring(start=start, end=i)
      let mut found = false
      // Check keywords
      let mut ki = 0
      while ki < keywords.length() {
        if word == keywords[ki] {
          html = html + "<span class=\"k\">" + @util.escape_html(word) + "</span>"
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
            html = html + "<span class=\"t\">" + @util.escape_html(word) + "</span>"
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
    html = html + @util.escape_html(code.substring(start=i, end=i + 1))
    i = i + 1
  }
  html
}
