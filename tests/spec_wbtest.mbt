// CommonMark spec test runner.

///|
fn normalize_html(html : String) -> String {
  let trimmed = normalize_rec(html, 0, false, "")
  strip_trailing_space(trimmed, trimmed.length() - 1)
}

///|
fn normalize_rec(
  html : String,
  i : Int,
  last_was_space : Bool,
  result : String,
) -> String {
  if i >= html.length() {
    result
  } else {
    let ch = html[i:i + 1].to_owned()
    if ch == " " || ch == "\t" || ch == "\n" || ch == "\r" {
      if last_was_space || result == "" {
        normalize_rec(html, i + 1, true, result)
      } else {
        normalize_rec(html, i + 1, true, result + " ")
      }
    } else {
      normalize_rec(html, i + 1, false, result + ch)
    }
  }
}

///|
fn strip_trailing_space(s : String, pos : Int) -> String {
  if pos < 0 {
    s
  } else if s[pos] == ' ' {
    s[0:pos].to_owned()
  } else {
    s
  }
}

///|
fn safe_prefix(s : String, max_len : Int) -> String {
  let len = s.length()
  if len <= max_len {
    s
  } else {
    s[0:max_len].to_owned()
  }
}

// Baseline: number of passing CommonMark spec tests.
// Update this when you fix bugs and the pass count increases.

///|
let baseline_passed : Int = 241

///|
test "spec compliance summary" {
  let mut passed = 0
  let failures : Array[SpecCase] = []

  for i in 0..<spec_cases.length() {
    let case = spec_cases[i]
    let ast = @moonmarkdown.parse(case.markdown)
    let got = @moonmarkdown.render(ast)

    let norm_got = normalize_html(got)
    let norm_expected = normalize_html(case.html)

    if norm_got == norm_expected {
      passed = passed + 1
    } else if failures.length() < 20 {
      failures.push(case)
    }
  }

  let total = spec_cases.length()
  let failed = total - passed
  let rate = passed * 100 / total
  println("\n=== Spec Compliance ===")
  println("Total:   " + total.to_string())
  println("Passed:  " + passed.to_string())
  println("Failed:  " + failed.to_string())
  println("Rate:    " + rate.to_string() + "%")
  println("Baseline:" + baseline_passed.to_string())
  println("")

  if failed > 0 {
    println("First failures:")
    for j in 0..<failures.length() {
      let f = failures[j]
      println("--- " + f.section + " #" + f.number.to_string() + " ---")
      let f_ast = @moonmarkdown.parse(f.markdown)
      let f_got = @moonmarkdown.render(f_ast)
      let norm_got = normalize_html(f_got)
      let norm_expected = normalize_html(f.html)
      println("Input:    " + safe_prefix(f.markdown, 60))
      println("Expected: " + safe_prefix(norm_expected, 80))
      println("Got:      " + safe_prefix(norm_got, 80))
      println("")
    }
  }

  if passed < baseline_passed {
    abort(
      "Spec regression: " +
      passed.to_string() +
      " passed < " +
      baseline_passed.to_string() +
      " baseline",
    )
  }
}
