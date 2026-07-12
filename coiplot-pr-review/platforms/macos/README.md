# macOS installer

Run from the package root:

```bash
chmod +x ./platforms/macos/install-personal.sh
./platforms/macos/install-personal.sh
```

This installs the complete `local-pr-review` skill at `~/.copilot/skills/local-pr-review`. Reload VS Code and run `/local-pr-review against origin/main` in Copilot Agent mode.
