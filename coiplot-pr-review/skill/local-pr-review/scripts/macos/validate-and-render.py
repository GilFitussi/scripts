#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path


def changed_lines(diff_text):
    result, current_file, new_line = set(), None, 0
    for text in diff_text.splitlines():
        match = re.match(r"^\+\+\+ b/(.+)$", text)
        if match:
            current_file = match.group(1)
            continue
        match = re.match(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@", text)
        if match:
            new_line = int(match.group(1))
            continue
        if not current_file:
            continue
        if text.startswith("+") and not text.startswith("+++"):
            result.add((current_file, new_line))
            new_line += 1
        elif text.startswith("-") and not text.startswith("---"):
            continue
        elif not text.startswith("\\"):
            new_line += 1
    return result


parser = argparse.ArgumentParser()
parser.add_argument("--input", required=True)
parser.add_argument("--context", required=True)
parser.add_argument("--output", required=True)
args = parser.parse_args()

report = json.loads(Path(args.input).read_text(encoding="utf-8-sig"))
context_path = Path(args.context)
context = json.loads(context_path.read_text(encoding="utf-8-sig"))
diff_path = context_path.parent / "pr.diff"
if not diff_path.exists():
    raise SystemExit(f"Missing committed diff: {diff_path}")

required = {"metadata", "summary", "findings", "missingTests", "checks", "limitations", "recommendation"}
missing = required - report.keys()
if missing:
    raise SystemExit(f"Missing report properties: {', '.join(sorted(missing))}")

valid_lines = changed_lines(diff_path.read_text(encoding="utf-8-sig", errors="replace"))
seen = set()
fields = {"id", "title", "severity", "confidence", "category", "file", "line", "changedBehavior", "trigger", "evidence", "impact", "suggestedFix", "reviewComment"}
for finding in report["findings"]:
    absent = [key for key in fields if key not in finding or finding[key] in (None, "")]
    if absent:
        raise SystemExit(f"Finding is missing fields: {', '.join(sorted(absent))}")
    if finding["id"] in seen:
        raise SystemExit(f"Duplicate finding id: {finding['id']}")
    seen.add(finding["id"])
    location = (finding["file"], int(finding["line"]))
    if location not in valid_lines:
        raise SystemExit(f"Finding {finding['id']} is not on a changed line: {location[0]}:{location[1]}")

template_path = Path(__file__).resolve().parents[2] / "assets" / "report-template.html"
if not template_path.exists():
    raise SystemExit(f"Missing report template: {template_path}")

payload = json.dumps({"report": report, "context": context}, ensure_ascii=False, separators=(",", ":"))
payload = payload.replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026")
document = template_path.read_text(encoding="utf-8").replace("__PR_REVIEW_DATA__", payload)
output = Path(args.output)
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(document, encoding="utf-8")
print(f"Validated {len(report['findings'])} findings and wrote {output}")
