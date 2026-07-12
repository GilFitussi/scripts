#!/usr/bin/env python3
import argparse
import html
import json
from pathlib import Path


def changed_lines(diff_text):
    result, current_file, new_line = set(), None, 0
    import re
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
            result.add((current_file, new_line)); new_line += 1
        elif text.startswith("-") and not text.startswith("---"):
            continue
        elif not text.startswith("\\"):
            new_line += 1
    return result


def esc(value):
    return html.escape(str(value), quote=True)


parser = argparse.ArgumentParser()
parser.add_argument("--input", default=".pr-review/findings.json")
parser.add_argument("--context", default=".pr-review/context.json")
parser.add_argument("--output", default=".pr-review/report.html")
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
finding_fields = {"id", "title", "severity", "confidence", "category", "file", "line", "changedBehavior", "trigger", "evidence", "impact", "suggestedFix", "reviewComment"}
for finding in report["findings"]:
    absent = [key for key in finding_fields if key not in finding or finding[key] in (None, "")]
    if absent:
        raise SystemExit(f"Finding is missing fields: {', '.join(sorted(absent))}")
    if finding["id"] in seen:
        raise SystemExit(f"Duplicate finding id: {finding['id']}")
    seen.add(finding["id"])
    location = (finding["file"], int(finding["line"]))
    if location not in valid_lines:
        raise SystemExit(f"Finding {finding['id']} is not on a changed line: {location[0]}:{location[1]}")

rank = {"critical": 0, "high": 1, "medium": 2}
cards = []
for f in sorted(report["findings"], key=lambda x: (rank.get(x["severity"], 9), x["file"], x["line"])):
    cards.append(f'''<article class="finding {esc(f['severity'])}" data-severity="{esc(f['severity'])}">
<header><span class="badge">{esc(f['severity'])}</span><h3>{esc(f['id'])}: {esc(f['title'])}</h3></header>
<p class="location">{esc(f['file'])}:{esc(f['line'])} · {esc(f['category'])} · confidence {esc(f['confidence'])}</p>
<h4>Evidence</h4><p>{esc(f['evidence'])}</p><h4>Impact</h4><p>{esc(f['impact'])}</p>
<h4>Suggested fix</h4><p>{esc(f['suggestedFix'])}</p><h4>GitHub review comment</h4>
<button class="copy" type="button" onclick="copyComment(this)">Copy comment</button><pre class="review-comment">{esc(f['reviewComment'])}</pre></article>''')

checks = "".join(f"<tr><td>{esc(c['name'])}</td><td><code>{esc(c['command'])}</code></td><td>{esc(c['status'])}</td><td>{esc(c['result'])}</td></tr>" for c in report["checks"])
tests = "".join(f"<tr><td>{esc(t['area'])}</td><td>{esc(t['test'])}</td><td>{esc(t['reason'])}</td></tr>" for t in report["missingTests"])
limits = "".join(f"<li>{esc(item)}</li>" for item in report["limitations"])

document = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{esc(report['metadata']['title'])}</title><style>
:root{{color-scheme:light dark;--bg:#0d1117;--panel:#161b22;--text:#e6edf3;--muted:#8b949e;--border:#30363d;--red:#f85149;--orange:#db6d28;--yellow:#d29922}}*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--text);font:15px/1.55 system-ui,sans-serif}}main{{max-width:1180px;margin:auto;padding:32px}}.summary,.finding,section{{background:var(--panel);border:1px solid var(--border);border-radius:10px;padding:20px;margin:18px 0}}.finding header{{display:flex;gap:12px;align-items:center}}.critical{{border-left:5px solid var(--red)}}.high{{border-left:5px solid var(--orange)}}.medium{{border-left:5px solid var(--yellow)}}.badge{{font-weight:700;text-transform:uppercase}}.location{{color:var(--muted)}}pre{{white-space:pre-wrap;background:#010409;padding:14px;border-radius:7px}}table{{width:100%;border-collapse:collapse}}td,th{{text-align:left;padding:9px;border-bottom:1px solid var(--border)}}button{{margin:3px;padding:7px 12px}}.hidden{{display:none}}
</style></head><body><main><h1>{esc(report['metadata']['title'])}</h1><p class="location">Base {esc(context['baseRef'])} · merge base {esc(context['mergeBase'])} · head {esc(context['head'])}</p>
<div class="summary"><h2>Executive summary</h2><p>{esc(report['summary'])}</p><strong>Recommendation: {esc(report['recommendation'])}</strong></div>
<section><h2>Findings ({len(report['findings'])})</h2><button onclick="f('all')">All</button><button onclick="f('critical')">Critical</button><button onclick="f('high')">High</button><button onclick="f('medium')">Medium</button>{''.join(cards)}</section>
<section><h2>Verification</h2><table><tr><th>Check</th><th>Command</th><th>Status</th><th>Result</th></tr>{checks}</table></section>
<section><h2>Missing tests</h2><table><tr><th>Area</th><th>Test</th><th>Reason</th></tr>{tests}</table></section><section><h2>Limitations</h2><ul>{limits}</ul></section>
</main><script>function f(s){{document.querySelectorAll('.finding').forEach(x=>x.classList.toggle('hidden',s!=='all'&&x.dataset.severity!==s))}}async function copyComment(button){{const text=button.parentElement.querySelector('.review-comment').textContent;await navigator.clipboard.writeText(text);const old=button.textContent;button.textContent='Copied';setTimeout(()=>button.textContent=old,1400)}}</script></body></html>'''

output = Path(args.output)
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(document, encoding="utf-8")
print(f"Validated {len(report['findings'])} findings and wrote {output}")
