param(
    [Parameter(Mandatory = $true)][string]$BaseRef,
    [string]$OutputDirectory = ".pr-review",
    [switch]$IncludeWorkingTree
)

$ErrorActionPreference = "Stop"

if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
    throw "Run this script from inside a Git repository."
}

git rev-parse --verify $BaseRef *> $null
if ($LASTEXITCODE -ne 0) { throw "Base ref '$BaseRef' does not exist locally." }

$mergeBase = (git merge-base HEAD $BaseRef).Trim()
if (-not $mergeBase) { throw "Could not compute a merge base for HEAD and '$BaseRef'." }

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$diffPath = Join-Path $OutputDirectory "pr.diff"
$changedFilesPath = Join-Path $OutputDirectory "changed-files.txt"

$committedDiff = @(git diff --find-renames --binary "$mergeBase...HEAD")
$changedFileList = @(git diff --find-renames --name-status "$mergeBase...HEAD")
Set-Content -Encoding utf8 -Path $diffPath -Value $committedDiff
Set-Content -Encoding utf8 -Path $changedFilesPath -Value $changedFileList

$numStat = @(git diff --numstat "$mergeBase...HEAD")
$files = @()
foreach ($entry in $numStat) {
    $parts = $entry -split "`t", 3
    if ($parts.Count -eq 3) {
        $files += [ordered]@{ additions = $parts[0]; deletions = $parts[1]; path = $parts[2] }
    }
}

$working = [ordered]@{
    included = [bool]$IncludeWorkingTree
    staged = @((git diff --cached --name-only) | Where-Object { $_ })
    unstaged = @((git diff --name-only) | Where-Object { $_ })
    untracked = @((git ls-files --others --exclude-standard) | Where-Object { $_ })
}

if ($IncludeWorkingTree) {
    Set-Content -Encoding utf8 -Path (Join-Path $OutputDirectory "staged.diff") -Value @(git diff --cached)
    Set-Content -Encoding utf8 -Path (Join-Path $OutputDirectory "unstaged.diff") -Value @(git diff)
}

$context = [ordered]@{
    repositoryRoot = (git rev-parse --show-toplevel).Trim()
    baseRef = $BaseRef
    mergeBase = $mergeBase
    head = (git rev-parse HEAD).Trim()
    branch = (git branch --show-current).Trim()
    generatedAt = (Get-Date).ToString("o")
    files = $files
    workingTree = $working
}

$context | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $OutputDirectory "context.json")
Write-Host "Review context written to $OutputDirectory"
Write-Host "Range: $mergeBase...HEAD ($BaseRef)"
