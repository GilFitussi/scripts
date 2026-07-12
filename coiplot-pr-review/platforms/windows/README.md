# Windows installer

Run from the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\platforms\windows\install-personal.ps1"
```

This installs the complete `local-pr-review` skill at `~/.copilot/skills/local-pr-review`. Reload VS Code and run `/local-pr-review against origin/main` in Copilot Agent mode.
