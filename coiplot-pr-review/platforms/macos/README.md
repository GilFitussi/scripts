# macOS

This directory contains the files that are specific to macOS:

```text
macos/
├── install-personal.sh
└── scripts/
    ├── collect-review-context.sh
    └── validate-and-render.py
```

For a personal installation that works from every repository, run from the package root:

```bash
chmod +x ./platforms/macos/install-personal.sh
./platforms/macos/install-personal.sh
```

The installer copies these tools and the shared JSON schema to `~/.copilot/pr-review`, then prints the VS Code User Settings entries required to load the shared prompts and instructions.

See [PERSONAL-INSTALL.md](../../PERSONAL-INSTALL.md) for the complete macOS guide.
