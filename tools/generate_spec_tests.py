#!/usr/bin/env python3
"""Extract CommonMark spec test cases and generate MoonBit test code."""

import re
import sys


def extract_tests(spec_path):
    """Extract test cases from CommonMark spec.txt."""
    with open(spec_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Match example blocks: ```````... example \n input \n . \n expected \n ```````...
    pattern = r"`{12,}\s*example\s*\n(.*?)\n\.\n(.*?)\n`{12,}"
    matches = list(re.finditer(pattern, content, re.DOTALL))

    tests = []
    for i, m in enumerate(matches):
        markdown = m.group(1)
        html = m.group(2)
        # Find the section name from context (lines starting with ##)
        section = "Unknown"
        pos = m.start()
        before = content[:pos]
        section_match = re.findall(r"^## (.+)$", before, re.MULTILINE)
        if section_match:
            section = section_match[-1]
        tests.append({
            "section": section,
            "number": i + 1,
            "markdown": markdown,
            "html": html,
        })

    return tests


def escape_moonbit_string(s):
    """Escape a string for MoonBit source code."""
    result = []
    for ch in s:
        if ch == "\\":
            result.append("\\\\")
        elif ch == '"':
            result.append('\\"')
        elif ch == "\n":
            result.append("\\n")
        elif ch == "\r":
            result.append("\\r")
        elif ch == "\t":
            result.append("\\t")
        elif ord(ch) < 32:
            result.append(f"\\u{{{ord(ch):04x}}}")
        else:
            result.append(ch)
    return "".join(result)


def generate_mbt(tests):
    """Generate MoonBit source containing all test cases."""
    lines = []
    lines.append("// Auto-generated from CommonMark spec.txt (0.31.2)")
    lines.append("// DO NOT EDIT")
    lines.append("")
    lines.append("pub struct SpecCase {")
    lines.append("  section : String")
    lines.append("  number : Int")
    lines.append("  markdown : String")
    lines.append("  html : String")
    lines.append("}")
    lines.append("")
    lines.append(f"pub let spec_cases : Array[SpecCase] = [")

    for i, t in enumerate(tests):
        md = escape_moonbit_string(t["markdown"])
        html = escape_moonbit_string(t["html"])
        section = escape_moonbit_string(t["section"])
        comma = "," if i < len(tests) - 1 else ""
        lines.append(
            f'  {{ section: "{section}", number: {t["number"]}, markdown: "{md}", html: "{html}" }}{comma}'
        )

    lines.append("]")
    lines.append("")
    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        spec_path = "spec/spec.txt"
    else:
        spec_path = sys.argv[1]

    if len(sys.argv) < 3:
        output_path = "tests/spec_data.mbt"
    else:
        output_path = sys.argv[2]

    print(f"Extracting tests from {spec_path}...")
    tests = extract_tests(spec_path)
    print(f"Found {len(tests)} test cases")

    print(f"Generating {output_path}...")
    code = generate_mbt(tests)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(code)

    print(f"Done! {len(tests)} test cases generated.")


if __name__ == "__main__":
    main()
