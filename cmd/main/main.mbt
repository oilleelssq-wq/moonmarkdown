/// MoonMarkdown CLI — convert Markdown to HTML.

///|
struct CliConfig {
  input : String?
  output : String?
  options : @types.MarkdownOptions
}

///|
fn main raise {
  match parse_args(@sys.get_cli_args()) {
    Some(config) => run(config)
    _ => ()
  }
}

///|
fn parse_args(args : Array[String]) -> CliConfig? {
  let mut input : String? = None
  let mut output : String? = None
  let mut options = @types.MarkdownOptions::default()
  let mut i = 1
  while i < args.length() {
    let arg = args[i]
    if arg == "-h" || arg == "--help" {
      print_usage()
      return None
    } else if arg == "--gfm" {
      options = { ..options, gfm: true }
      i = i + 1
      continue
    } else if arg == "--highlight" {
      options = options.with_highlight(true)
      i = i + 1
      continue
    } else if arg == "--no-html" {
      options = options.with_html(false)
      i = i + 1
      continue
    } else if arg == "--css" {
      if i + 1 >= args.length() {
        fail_with_usage("missing value for --css")
      }
      match args[i + 1] {
        "none" => options = options.with_css(@types.CssPreset::None)
        "default" => options = options.with_css(@types.CssPreset::Default)
        "bootstrap" => options = options.with_css(@types.CssPreset::Bootstrap)
        other => fail_with_usage("unknown css preset: " + other)
      }
      i = i + 2
      continue
    } else if arg == "-o" || arg == "--output" {
      if i + 1 >= args.length() {
        fail_with_usage("missing output path")
      }
      output = Some(args[i + 1])
      i = i + 2
      continue
    } else if arg.has_prefix("-") {
      fail_with_usage("unknown option: " + arg)
    } else {
      if input is Some(_) {
        fail_with_usage("only one input file is supported")
      }
      input = Some(arg)
      i = i + 1
      continue
    }
  }
  Some({ input, output, options })
}

///|
fn run(config : CliConfig) -> Unit raise {
  let markdown = match config.input {
    Some(path) => @fs.read_file_to_string(path)
    _ =>
      fail_with_usage(
        "missing input file; (stdin requires native target, not yet implemented)",
      )
  }
  let html = @moonmarkdown.md_to_html_with_options(markdown, config.options)
  match config.output {
    Some(path) => @fs.write_string_to_file(path, html)
    _ => println(html)
  }
}

///|
fn[T] fail_with_usage(message : String) -> T {
  println("moonmarkdown: " + message)
  print_usage()
  abort(message)
}

///|
fn print_usage() -> Unit {
  println("Usage: moonmarkdown [options] <input.md>")
  println("")
  println("Options:")
  println("  --gfm                  Enable GFM tables and strikethrough")
  println("  --highlight            Enable syntax highlighting for fenced code")
  println(
    "  --no-html              Escape raw HTML instead of passing it through",
  )
  println("  --css none|default|bootstrap")
  println("                         Add CSS class attributes using a preset")
  println("  -o, --output <file>    Write HTML to a file")
  println("  -h, --help             Show this help")
}
