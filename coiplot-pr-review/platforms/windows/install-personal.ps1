param(
    [string]$ToolDirectory = (Join-Path $HOME ".copilot\pr-review")
)

$ErrorActionPreference = "Stop"
$platformRoot = $PSScriptRoot
$packageRoot = (Resolve-Path (Join-Path $platformRoot "..\..")).Path
$sourceScripts = Join-Path $platformRoot "scripts"
$sourceSchema = Join-Path $packageRoot ".github\pr-review\schema"

if ([string]::IsNullOrWhiteSpace($ToolDirectory) -or $ToolDirectory -eq $HOME) {
    throw "Refusing unsafe tool directory: '$ToolDirectory'."
}

if (-not (Test-Path (Join-Path $sourceScripts "collect-review-context.ps1"))) {
    throw "Could not find the bundled Windows PR review tools below '$sourceScripts'."
}

New-Item -ItemType Directory -Force -Path $ToolDirectory | Out-Null
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -LiteralPath (Join-Path $ToolDirectory "scripts"), (Join-Path $ToolDirectory "schema")
Copy-Item -Recurse -Force -Path $sourceScripts -Destination $ToolDirectory
Copy-Item -Recurse -Force -Path $sourceSchema -Destination $ToolDirectory

$resolvedPackage = (Resolve-Path $packageRoot).Path.Replace("\", "/")
$resolvedTools = (Resolve-Path $ToolDirectory).Path

Write-Host "Personal PR review tools installed at: $resolvedTools"
Write-Host ""
Write-Host "Add these entries to your VS Code User settings.json:"
Write-Host @"
"chat.instructionsFilesLocations": {
  "$resolvedPackage/.github/instructions": true
},
"chat.promptFilesLocations": {
  "$resolvedPackage/.github/prompts": true
}
"@
Write-Host ""
Write-Host "Then reload VS Code and run /full-local-pr-review from any Git repository."
