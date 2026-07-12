param(
    [string]$InputPath = ".pr-review/findings.json",
    [string]$ContextPath = ".pr-review/context.json",
    [string]$OutputPath = ".pr-review/report.html"
)

$ErrorActionPreference = "Stop"
$report = Get-Content -Raw $InputPath | ConvertFrom-Json
$context = Get-Content -Raw $ContextPath | ConvertFrom-Json
$diffPath = Join-Path (Split-Path -Parent $ContextPath) "pr.diff"
if (-not (Test-Path $diffPath)) { throw "Missing committed diff file: $diffPath" }

$required = @("metadata", "summary", "findings", "missingTests", "checks", "limitations", "recommendation")
foreach ($name in $required) {
    if (-not $report.PSObject.Properties.Name.Contains($name)) { throw "Missing report property: $name" }
}

$diffLines = @{}
$currentFile = $null
$newLine = 0
foreach ($lineText in (Get-Content $diffPath)) {
    if ($lineText -match '^\+\+\+ b/(.+)$') { $currentFile = $Matches[1]; continue }
    if ($lineText -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@') { $newLine = [int]$Matches[1]; continue }
    if (-not $currentFile) { continue }
    if ($lineText.StartsWith('+') -and -not $lineText.StartsWith('+++')) {
        $diffLines["$currentFile`:$newLine"] = $true; $newLine++; continue
    }
    if ($lineText.StartsWith('-') -and -not $lineText.StartsWith('---')) { continue }
    if (-not $lineText.StartsWith('\')) { $newLine++ }
}

$ids = @{}
foreach ($finding in $report.findings) {
    foreach ($field in @("id", "title", "severity", "confidence", "category", "file", "line", "evidence", "impact", "suggestedFix", "reviewComment")) {
        if (-not $finding.PSObject.Properties.Name.Contains($field) -or $null -eq $finding.$field -or "$($finding.$field)".Length -eq 0) {
            throw "Finding is missing '$field': $($finding | ConvertTo-Json -Compress)"
        }
    }
    if ($ids.ContainsKey($finding.id)) { throw "Duplicate finding id: $($finding.id)" }
    $ids[$finding.id] = $true
    if (-not $diffLines.ContainsKey("$($finding.file):$($finding.line)")) {
        throw "Finding $($finding.id) is not anchored to an added/modified diff line: $($finding.file):$($finding.line)"
    }
}

function ConvertTo-HtmlText([object]$value) { [System.Net.WebUtility]::HtmlEncode("$value") }

$severityRank = @{ critical = 0; high = 1; medium = 2 }
$cards = foreach ($f in ($report.findings | Sort-Object { $severityRank[$_.severity] }, file, line)) {
    $safeComment = ConvertTo-HtmlText $f.reviewComment
    @"
<article class="finding $($f.severity)" data-severity="$($f.severity)" data-category="$($f.category)">
  <header><span class="badge">$(ConvertTo-HtmlText $f.severity)</span><h3>$(ConvertTo-HtmlText $f.id): $(ConvertTo-HtmlText $f.title)</h3></header>
  <p class="location">$(ConvertTo-HtmlText $f.file):$(ConvertTo-HtmlText $f.line) · $(ConvertTo-HtmlText $f.category) · confidence $(ConvertTo-HtmlText $f.confidence)</p>
  <h4>Evidence</h4><p>$(ConvertTo-HtmlText $f.evidence)</p>
  <h4>Impact</h4><p>$(ConvertTo-HtmlText $f.impact)</p>
  <h4>Suggested fix</h4><p>$(ConvertTo-HtmlText $f.suggestedFix)</p>
  <h4>GitHub review comment</h4><pre>$safeComment</pre>
</article>
"@
}

$checks = foreach ($c in $report.checks) { "<tr><td>$(ConvertTo-HtmlText $c.name)</td><td><code>$(ConvertTo-HtmlText $c.command)</code></td><td>$(ConvertTo-HtmlText $c.status)</td><td>$(ConvertTo-HtmlText $c.result)</td></tr>" }
$limits = foreach ($l in $report.limitations) { "<li>$(ConvertTo-HtmlText $l)</li>" }
$testRows = foreach ($t in $report.missingTests) { "<tr><td>$(ConvertTo-HtmlText $t.area)</td><td>$(ConvertTo-HtmlText $t.test)</td><td>$(ConvertTo-HtmlText $t.reason)</td></tr>" }

$html = @"
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>$(ConvertTo-HtmlText $report.metadata.title)</title><style>
:root{color-scheme:light dark;--bg:#0d1117;--panel:#161b22;--text:#e6edf3;--muted:#8b949e;--border:#30363d;--red:#f85149;--orange:#db6d28;--yellow:#d29922;--blue:#58a6ff}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:15px/1.55 system-ui,sans-serif}.wrap{max-width:1180px;margin:auto;padding:32px}h1,h2,h3,h4{line-height:1.25}h1{margin-bottom:4px}.meta,.location{color:var(--muted)}.summary,.finding,section{background:var(--panel);border:1px solid var(--border);border-radius:10px;padding:20px;margin:18px 0}.finding header{display:flex;align-items:center;gap:12px}.finding h3{margin:0}.badge{font-weight:700;text-transform:uppercase;border-radius:20px;padding:3px 9px}.critical{border-left:5px solid var(--red)}.high{border-left:5px solid var(--orange)}.medium{border-left:5px solid var(--yellow)}pre{white-space:pre-wrap;background:#010409;padding:14px;border-radius:7px;overflow:auto}table{width:100%;border-collapse:collapse}th,td{text-align:left;padding:9px;border-bottom:1px solid var(--border);vertical-align:top}code{color:var(--blue)}button{padding:7px 12px;margin:3px;border:1px solid var(--border);border-radius:7px;background:var(--panel);color:var(--text);cursor:pointer}.hidden{display:none}
</style></head><body><main class="wrap">
<h1>$(ConvertTo-HtmlText $report.metadata.title)</h1><p class="meta">Base $(ConvertTo-HtmlText $context.baseRef) · merge base $(ConvertTo-HtmlText $context.mergeBase) · head $(ConvertTo-HtmlText $context.head) · generated $(ConvertTo-HtmlText $report.metadata.generatedAt)</p>
<div class="summary"><h2>Executive summary</h2><p>$(ConvertTo-HtmlText $report.summary)</p><p><strong>Recommendation:</strong> $(ConvertTo-HtmlText $report.recommendation)</p></div>
<section><h2>Findings ($($report.findings.Count))</h2><div><button onclick="filterFindings('all')">All</button><button onclick="filterFindings('critical')">Critical</button><button onclick="filterFindings('high')">High</button><button onclick="filterFindings('medium')">Medium</button></div>$($cards -join "`n")</section>
<section><h2>Verification</h2><table><thead><tr><th>Check</th><th>Command</th><th>Status</th><th>Result</th></tr></thead><tbody>$($checks -join "`n")</tbody></table></section>
<section><h2>Missing tests</h2><table><thead><tr><th>Area</th><th>Test</th><th>Reason</th></tr></thead><tbody>$($testRows -join "`n")</tbody></table></section>
<section><h2>Limitations</h2><ul>$($limits -join "`n")</ul></section>
</main><script>function filterFindings(s){document.querySelectorAll('.finding').forEach(x=>x.classList.toggle('hidden',s!=='all'&&x.dataset.severity!==s))}</script></body></html>
"@

$parent = Split-Path -Parent $OutputPath
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$html | Set-Content -Encoding utf8 $OutputPath
Write-Host "Validated $($report.findings.Count) findings and wrote $OutputPath"
