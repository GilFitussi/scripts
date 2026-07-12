# Personal installation on macOS — use from every repository

Use this setup when the PR review pack is for your own VS Code profile and you do not want to copy `.github` files into every repository.

The personal installation has two parts:

1. VS Code loads the prompts and instructions directly from this package directory.
2. The deterministic shell and Python tools are installed once under `~/.copilot/pr-review`.

Nothing is copied into repositories that you review.

## Prerequisites

- Keep this package in a stable location. Do not move or rename it after configuring VS Code unless you also update the settings paths.
- Install GitHub Copilot and GitHub Copilot Chat in VS Code.
- Use a trusted workspace when running Agent mode.
- Make sure `git`, `bash`, and `python3` are available from the VS Code terminal. Current macOS installations normally include Git after installing the Xcode Command Line Tools; verify with `git --version` and `python3 --version`.

## Step 1: Install the shared tools once

Open Terminal in this package directory and run the installer from the dedicated macOS folder:

```bash
chmod +x ./platforms/macos/install-personal.sh
./platforms/macos/install-personal.sh
```

The script copies only the reusable scripts and JSON schema to:

```text
~/.copilot/pr-review/
├── scripts\
│   ├── collect-review-context.sh
│   └── validate-and-render.py
└── schema\
    └── findings.schema.json
```

It also prints the exact VS Code settings entries for the current package location.

## Step 2: Register the prompts and instructions in your VS Code profile

1. Open VS Code.
2. Open the Command Palette with `Ctrl+Shift+P`.
3. Run `Preferences: Open User Settings (JSON)`.
4. Add the locations printed by `install-personal.sh`.

The installer prints the exact paths for your Mac. They look like:

```jsonc
{
  "chat.instructionsFilesLocations": {
    "/Users/your-name/Projects/scripts/coiplot-pr-review/.github/instructions": true
  },
  "chat.promptFilesLocations": {
    "/Users/your-name/Projects/scripts/coiplot-pr-review/.github/prompts": true
  }
}
```

If either setting already exists, add the new path inside the existing object. Do not create a second property with the same name.

Example with existing locations:

```jsonc
{
  "chat.instructionsFilesLocations": {
    ".github/instructions": true,
    "/Users/your-name/Projects/scripts/coiplot-pr-review/.github/instructions": true
  },
  "chat.promptFilesLocations": {
    ".github/prompts": true,
    "/Users/your-name/Projects/scripts/coiplot-pr-review/.github/prompts": true
  }
}
```

Use the absolute macOS path printed by the installer.

## Step 3: Reload and verify

1. Run `Developer: Reload Window` from the Command Palette.
2. Run `Chat: Open Customizations`.
3. Confirm that the three PR review prompts and three instruction files appear as user customizations.
4. Open Copilot Chat and type `/`.
5. Confirm that these commands are available:

```text
/full-local-pr-review
/quick-local-pr-review
/security-local-pr-review
```

If they do not appear, inspect Chat customization diagnostics and confirm the paths in User Settings point to existing directories.

## Run a review from any repository

1. Open the repository root in VS Code.
2. Check out the feature branch you want to review.
3. Fetch the base branch so the remote ref is current:

   ```bash
   git fetch origin main
   ```

4. Open Copilot Chat and select **Agent** mode.
5. Run:

   ```text
   /full-local-pr-review
   ```

6. If Copilot cannot identify the base branch, append it explicitly:

   ```text
   /full-local-pr-review against origin/main
   ```

7. Approve the expected read-only Git commands, project checks, and writes under `.pr-review/`.
8. Open the generated report at:

   ```text
   <current-repository>/.pr-review/report.html
   ```

The generated `.pr-review` directory belongs to the repository's working directory, but it is untracked. The full prompt attempts to add nothing to the repository and never edits application code.

## Keep generated reports out of Git without editing every `.gitignore`

For personal use, add `.pr-review/` to your global Git ignore file once:

```bash
git config --global core.excludesFile "$HOME/.gitignore_global"
grep -qxF '.pr-review/' "$HOME/.gitignore_global" 2>/dev/null || echo '.pr-review/' >> "$HOME/.gitignore_global"
```

This keeps `.pr-review/` ignored in every repository for your user only. It does not modify project `.gitignore` files.

## Update the personal installation

After pulling a newer version of this package, rerun:

```bash
./platforms/macos/install-personal.sh
```

The prompt and instruction files are read directly from this package, so VS Code sees their updates after a window reload. Rerunning the installer refreshes the copied scripts and schema.

## Optional: synchronize prompts across machines

The path-based setup assumes this package exists at the configured path on each computer. For multiple machines, either:

- clone the package to the same path on every machine; or
- use `Chat: New Prompt File`, choose **User**, and copy the prompt content into the VS Code user profile on each machine.

VS Code Settings Sync can synchronize user-level prompts and instructions, but the tools under `~/.copilot/pr-review` still need to be installed on each Mac.

## Uninstall

1. Remove the two package paths from `chat.instructionsFilesLocations` and `chat.promptFilesLocations` in User Settings.
2. Reload VS Code.
3. Optionally delete `~/.copilot/pr-review`.
4. Optionally remove `.pr-review/` from your global Git ignore file.
