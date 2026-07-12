param(
    [string]$ToolDirectory = (Join-Path $HOME ".copilot\pr-review")
)

$ErrorActionPreference = "Stop"
$packageRoot = $PSScriptRoot
$sourceTools = Join-Path $packageRoot ".github\pr-review"

if (-not (Test-Path (Join-Path $sourceTools "scripts\collect-review-context.ps1"))) {
    throw "Could not find the bundled PR review tools below '$sourceTools'."
}

New-Item -ItemType Directory -Force -Path $ToolDirectory | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $sourceTools "scripts") -Destination $ToolDirectory
Copy-Item -Recurse -Force -Path (Join-Path $sourceTools "schema") -Destination $ToolDirectory

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
