# Windows

This directory contains the files that are specific to Windows:

```text
windows/
├── install-personal.ps1
└── scripts/
    ├── collect-review-context.ps1
    └── validate-and-render.ps1
```

For a personal installation, run from the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\platforms\windows\install-personal.ps1"
```

The installer copies these tools and the shared JSON schema to `~/.copilot/pr-review`, then prints the VS Code User Settings entries required to load the shared prompts and instructions.
