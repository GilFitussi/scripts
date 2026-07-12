# Copilot Local PR Review Skill

A personal GitHub Copilot Agent Skill that reviews the committed changes on the current branch, runs relevant verification, validates every finding against the diff, and generates JSON plus a self-contained HTML report.

The skill works from every repository. You install it once; you do not copy files into each project.

## Package structure

```text
coiplot-pr-review/
├── skill/
│   └── local-pr-review/
│       ├── SKILL.md
│       ├── scripts/
│       │   ├── macos/
│       │   └── windows/
│       └── references/
│           ├── review-core.md
│           ├── node-typescript.md
│           ├── data-workers-infra.md
│           └── findings.schema.json
└── platforms/
    ├── macos/install-personal.sh
    └── windows/install-personal.ps1
```

`skill/local-pr-review` is the single source of truth. The platform installers copy that complete directory to Copilot's personal skills location.

## Personal installation on macOS

From the package root:

```bash
chmod +x ./platforms/macos/install-personal.sh
./platforms/macos/install-personal.sh
```

The installer replaces only this skill at:

```text
~/.copilot/skills/local-pr-review
```

Then:

1. Open VS Code.
2. Run `Developer: Reload Window` from the Command Palette.
3. Run `Chat: Open Customizations` and confirm that `local-pr-review` appears under Skills.
4. Open any Git repository and select Copilot **Agent** mode.
5. Run:

   ```text
   /local-pr-review against origin/main
   ```

Copilot can also load the skill automatically for requests such as:

```text
Review the current branch against origin/main and generate the PR review report.
```

## Personal installation on Windows

From the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\platforms\windows\install-personal.ps1"
```

Reload VS Code and invoke `/local-pr-review` in Agent mode.

## Generated output

The skill writes only below the currently reviewed repository's `.pr-review` directory:

```text
.pr-review/
├── context.json
├── changed-files.txt
├── pr.diff
├── findings.json
└── report.html
```

Each finding contains a `reviewComment` field with standalone Markdown ready to paste directly into a GitHub Pull Request. The HTML report includes a **Copy comment** button.

## Ignore generated reports globally

For personal use on macOS, configure a global ignore once:

```bash
git config --global core.excludesFile "$HOME/.gitignore_global"
grep -qxF '.pr-review/' "$HOME/.gitignore_global" 2>/dev/null || echo '.pr-review/' >> "$HOME/.gitignore_global"
```

This avoids modifying `.gitignore` in every repository.

## Update

Pull the newest package version and rerun the installer for your operating system. It replaces the complete installed `local-pr-review` directory, so old scripts and references are not left behind.

## Uninstall

On macOS:

```bash
rm -rf "$HOME/.copilot/skills/local-pr-review"
```

On Windows:

```powershell
Remove-Item -Recurse -Force "$HOME\.copilot\skills\local-pr-review"
```

Reload VS Code after uninstalling.

## Validation and limitations

- The renderer rejects findings that are not anchored to an added or modified line.
- Commands that were not executed are recorded as `not_run`, never `passed`.
- Working-tree changes are reported separately from committed PR changes.
- The skill does not edit application code unless the user explicitly requests fixes after the review.
- AI review supplements CI, automated tests, security tools, and human review; it does not replace them.
