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

## Centralized output outside repositories

The skill never writes review artifacts into the repository. Reports are organized centrally by repository, PR or branch, and execution time:

```text
~/Copilot-PR-Reviews/
└── my-project/
    └── PR-123/                  # Uses the branch name when no PR number is available
        └── 2026-07-12_143500/
            ├── context.json
            ├── changed-files.txt
            ├── pr.diff
            ├── findings.json
            └── report.html
```

Each finding contains a `reviewComment` field with standalone Markdown ready to paste directly into a GitHub Pull Request. The HTML report includes a **Copy comment** button.

The report is a self-contained review dashboard with:

- severity and verification summary cards
- full-text search and severity filters
- detailed changed behavior, trigger, evidence, impact, and suggested fix sections
- paste-ready GitHub comments with one-click copy
- verification and missing-test tables with status badges
- dark and light themes, responsive mobile layout, and print-friendly styling

To use a different centralized location, set this environment variable before starting VS Code:

```bash
export COPILOT_PR_REVIEW_OUTPUT_ROOT="$HOME/Documents/PR-Reviews"
```

Because the files are outside the repository, they never appear in `git status` and no `.gitignore` entry is required.

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
- The skill does not write any artifact inside the repository and does not edit application code unless the user explicitly requests fixes after the review.
- AI review supplements CI, automated tests, security tools, and human review; it does not replace them.
