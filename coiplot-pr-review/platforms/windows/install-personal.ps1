param(
    [string]$SkillsRoot = (Join-Path $HOME ".copilot\skills")
)

$ErrorActionPreference = "Stop"
$platformRoot = $PSScriptRoot
$packageRoot = (Resolve-Path (Join-Path $platformRoot "..\..")).Path
$sourceSkill = Join-Path $packageRoot "skill\local-pr-review"
$targetSkill = Join-Path $SkillsRoot "local-pr-review"
$stagingSkill = Join-Path $SkillsRoot ".local-pr-review.installing"

if ([string]::IsNullOrWhiteSpace($SkillsRoot) -or $SkillsRoot -eq $HOME) {
    throw "Refusing unsafe skills directory: '$SkillsRoot'."
}

foreach ($required in @(
    (Join-Path $sourceSkill "SKILL.md"),
    (Join-Path $sourceSkill "scripts\windows\collect-review-context.ps1"),
    (Join-Path $sourceSkill "references\findings.schema.json")
)) {
    if (-not (Test-Path $required)) { throw "Incomplete skill package. Missing: $required" }
}

New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -LiteralPath $stagingSkill
Copy-Item -Recurse -Force -Path $sourceSkill -Destination $stagingSkill
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -LiteralPath $targetSkill
Move-Item -LiteralPath $stagingSkill -Destination $targetSkill

Write-Host "Installed Copilot skill: $targetSkill"
Write-Host "Reload VS Code, select Agent mode, and run: /local-pr-review against origin/main"
