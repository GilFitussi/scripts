param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$ContextPath,
    [Parameter(Mandatory = $true)][string]$OutputPath
)

$ErrorActionPreference = "Stop"
$report = Get-Content -Raw $InputPath | ConvertFrom-Json
$context = Get-Content -Raw $ContextPath | ConvertFrom-Json
$diffPath = Join-Path (Split-Path -Parent $ContextPath) "pr.diff"
if (-not (Test-Path $diffPath)) { throw "Missing committed diff file: $diffPath" }

foreach ($name in @("metadata", "summary", "findings", "missingTests", "checks", "limitations", "recommendation")) {
    if (-not $report.PSObject.Properties.Name.Contains($name)) { throw "Missing report property: $name" }
}

$diffLines = @{}
$currentFile = $null
$newLine = 0
foreach ($lineText in (Get-Content $diffPath)) {
    if ($lineText -match '^\+\+\+ b/(.+)$') { $currentFile = $Matches[1]; continue }
    if ($lineText -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@') { $newLine = [int]$Matches[1]; continue }
    if (-not $currentFile) { continue }
    if ($lineText.StartsWith('+') -and -not $lineText.StartsWith('+++')) { $diffLines["$currentFile`:$newLine"] = $true; $newLine++; continue }
    if ($lineText.StartsWith('-') -and -not $lineText.StartsWith('---')) { continue }
    if (-not $lineText.StartsWith('\')) { $newLine++ }
}

$ids = @{}
$fields = @("id", "title", "severity", "confidence", "category", "file", "line", "changedBehavior", "trigger", "evidence", "impact", "suggestedFix", "reviewComment")
foreach ($finding in $report.findings) {
    foreach ($field in $fields) {
        if (-not $finding.PSObject.Properties.Name.Contains($field) -or $null -eq $finding.$field -or "$($finding.$field)".Length -eq 0) { throw "Finding is missing '$field'." }
    }
    if ($ids.ContainsKey($finding.id)) { throw "Duplicate finding id: $($finding.id)" }
    $ids[$finding.id] = $true
    if (-not $diffLines.ContainsKey("$($finding.file):$($finding.line)")) { throw "Finding $($finding.id) is not anchored to a changed line: $($finding.file):$($finding.line)" }
}

$skillRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$templatePath = Join-Path $skillRoot "assets\report-template.html"
if (-not (Test-Path $templatePath)) { throw "Missing report template: $templatePath" }

$payload = [ordered]@{ report = $report; context = $context } | ConvertTo-Json -Depth 20 -Compress
$payload = $payload.Replace('<', '\u003c').Replace('>', '\u003e').Replace('&', '\u0026')
$html = (Get-Content -Raw $templatePath).Replace('__PR_REVIEW_DATA__', $payload)
$parent = Split-Path -Parent $OutputPath
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$html | Set-Content -Encoding utf8 $OutputPath
Write-Host "Validated $($report.findings.Count) findings and wrote $OutputPath"
