# Copilot PR Review Pack

A reusable GitHub Copilot customization pack for high-signal local pull request reviews in Visual Studio Code. It reviews only changes introduced by the current branch, runs relevant project checks when safe, validates finding locations, and generates a self-contained HTML report.

## What it includes

- A complete end-to-end PR review prompt.
- Quick and security-focused review prompts.
- Shared review instructions for correctness, reliability, security, performance, and tests.
- Additional Node.js, TypeScript, database, worker, queue, and infrastructure checks.
- Deterministic merge-base and diff collection.
- JSON findings with validation against modified lines.
- A local HTML report with severity filters and paste-ready GitHub comments.

## Requirements

- Visual Studio Code with GitHub Copilot and GitHub Copilot Chat.
- Git available from the terminal.
- On macOS: Bash and Python 3. On Windows: PowerShell 5.1 or PowerShell 7.
- A trusted VS Code workspace so Agent mode can execute approved terminal commands.
- Optional: GitHub Pull Requests and Issues extension for PR title, description, and base-branch context.

## Package layout

```text
coiplot-pr-review/
├── .github/                  # Shared Copilot prompts, instructions, and JSON schema
├── platforms/
│   ├── macos/               # Everything platform-specific for Mac
│   │   ├── install-personal.sh
│   │   └── scripts/
│   │       ├── collect-review-context.sh
│   │       └── validate-and-render.py
│   └── windows/             # Everything platform-specific for Windows
│       ├── install-personal.ps1
│       └── scripts/
│           ├── collect-review-context.ps1
│           └── validate-and-render.ps1
├── PERSONAL-INSTALL.md      # Detailed personal macOS setup
├── INSTALL.md               # Repository/team installation
└── README.md
```

The review rules and prompts are shared. Choose only the platform folder matching your computer. A Mac user can ignore `platforms/windows`, and a Windows user can ignore `platforms/macos`.

## Installation

### Personal installation on macOS — install once for every repository

Use this option when the review pack is for your own VS Code profile. You install it once and then run the same review prompts from any Git repository without copying `.github` files into each project.

Keep this package in a stable location on your Mac, then open Terminal in the package directory:

```bash
cd /path/to/scripts/coiplot-pr-review
chmod +x ./platforms/macos/install-personal.sh
./platforms/macos/install-personal.sh
```

The installer copies the shared shell, Python, and schema files to:

```text
~/.copilot/pr-review
```

It then prints the exact entries to add to your VS Code User Settings. In VS Code:

1. Press `Cmd+Shift+P`.
2. Run `Preferences: Open User Settings (JSON)`.
3. Add the paths printed by the macOS installer.

They will look similar to:

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

Use the actual absolute path printed by the installer. If either setting already exists, add the new path to its existing object instead of creating a duplicate setting.

Reload VS Code with `Developer: Reload Window`. Run `Chat: Open Customizations` and confirm the prompts and instructions are visible.

To keep generated review artifacts ignored across all of your repositories without changing their `.gitignore` files, configure a personal global ignore once:

```bash
git config --global core.excludesFile "$HOME/.gitignore_global"
grep -qxF '.pr-review/' "$HOME/.gitignore_global" 2>/dev/null || echo '.pr-review/' >> "$HOME/.gitignore_global"
```

You can now open any repository in VS Code, select Copilot **Agent** mode, and run:

```text
/full-local-pr-review against origin/main
```

Replace `origin/main` when the repository uses a different base branch. The report is generated inside the currently opened repository at `.pr-review/report.html`, but no customization files are copied into that repository.

After updating this package, rerun `./platforms/macos/install-personal.sh` to refresh the shared tools, then reload VS Code. For troubleshooting and uninstall instructions, see [PERSONAL-INSTALL.md](PERSONAL-INSTALL.md).

### Repository installation — share with a team

#### 1. Copy the customization files

Copy this package's `.github` directory into the root of the repository that you want to review:

```text
coiplot-pr-review/.github  ->  your-repository/.github
```

If the target repository already has a `.github` directory, merge the directories. Do not delete or replace existing GitHub Actions workflows or repository configuration.

Then copy the scripts for the operating system used by the reviewer:

```text
# macOS
coiplot-pr-review/platforms/macos/scripts  ->  your-repository/.github/pr-review/scripts

# Windows
coiplot-pr-review/platforms/windows/scripts  ->  your-repository/.github/pr-review/scripts
```

After installation, these files should exist:

```text
your-repository/
└── .github/
    ├── instructions/
    │   ├── pr-review-core.instructions.md
    │   ├── node-typescript-review.instructions.md
    │   └── data-workers-infra-review.instructions.md
    ├── prompts/
    │   ├── full-local-pr-review.prompt.md
    │   ├── quick-local-pr-review.prompt.md
    │   └── security-local-pr-review.prompt.md
    └── pr-review/
        ├── schema/
        │   └── findings.schema.json
        └── scripts/        # Copy either the macOS or Windows scripts here
```

#### 2. Ignore generated reports

Add this entry to the target repository's `.gitignore`:

```gitignore
.pr-review/
```

Generated diffs, findings, and HTML reports can contain source-code context and should normally remain local.

#### 3. Confirm VS Code discovered the files

1. Open the target repository root in VS Code.
2. Open the Command Palette.
3. Run `Chat: Open Customizations`.
4. Confirm the instruction and prompt files are listed.

If they are missing, confirm that the files are located below `.github/instructions` and `.github/prompts`, then inspect the Chat customization diagnostics.

## Running a full review

1. Check out the feature branch that you want to review.
2. Fetch the current base branch, for example:

   ```powershell
   git fetch origin main
   ```

3. Open Copilot Chat and select **Agent** mode.
4. Run the prompt from the prompt picker:

   ```text
   /full-local-pr-review
   ```

5. If the base branch cannot be detected, provide it explicitly:

   ```text
   Run the full local PR review against origin/main.
   ```

6. Review and approve only the expected read-only Git commands, project checks, and writes below `.pr-review/`.
7. Open the generated report:

   ```text
   .pr-review/report.html
   ```

The full workflow creates:

```text
.pr-review/context.json
.pr-review/changed-files.txt
.pr-review/pr.diff
.pr-review/findings.json
.pr-review/report.html
```

Each finding in `.pr-review/findings.json` contains a `reviewComment` field with standalone Markdown that is ready to paste directly into the GitHub Pull Request review:

```json
{
  "id": "PR-001",
  "title": "Concurrent requests can overwrite the state transition",
  "severity": "high",
  "confidence": "high",
  "category": "concurrency",
  "file": "src/jobs/worker.ts",
  "line": 146,
  "changedBehavior": "The state is now read and updated in separate operations.",
  "trigger": "Two workers process the same record concurrently.",
  "evidence": "Both workers can read the previous state before either update completes.",
  "impact": "A completed record can be overwritten or processed twice.",
  "suggestedFix": "Use an atomic conditional update that includes the expected previous state.",
  "reviewComment": "This update is vulnerable to a race when two workers process the same record. Both can read the previous state before either write completes, which can duplicate processing or overwrite the final status. Could we make this an atomic conditional update using the expected previous state?"
}
```

The HTML report also includes a **Copy comment** button for every finding.

## Other review modes

Run a shorter high-signal review:

```text
/quick-local-pr-review
```

Run a security-focused review:

```text
/security-local-pr-review
```

The quick and security prompts return their results in Copilot Chat. The full prompt also creates the structured JSON and HTML artifacts.

## Review scope

The complete prompt reviews committed branch changes between the merge base and `HEAD`. Staged, unstaged, and untracked files are reported separately and excluded from PR findings unless you explicitly ask to include the entire working tree.

Unchanged files may be read to verify callers, contracts, schemas, or tests, but every reported finding must be caused by the diff and anchored to an added or modified line.

## Windows execution policy

If Windows blocks the local scripts because they are unsigned, use a process-scoped execution-policy bypass:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".github/pr-review/scripts/collect-review-context.ps1" -BaseRef origin/main
```

This affects only that PowerShell process and does not change the machine-wide execution policy. Inspect scripts before approving their execution.

## Troubleshooting

### The prompt is not shown

- Open the repository root rather than a nested source directory.
- Confirm the filename ends with `.prompt.md`.
- Run `Chat: Open Customizations` and inspect diagnostics.
- Reload the VS Code window after copying the files.

### Copilot cannot determine the base branch

Supply the remote base ref explicitly, such as `origin/main`, and make sure it exists locally:

```powershell
git fetch origin main
git rev-parse --verify origin/main
```

### The HTML renderer rejects a finding

The renderer accepts findings only when their file and line identify an added or modified line in `.pr-review/pr.diff`. Correct the finding location or remove the unsupported finding; do not weaken the validator.

### Project checks were not run

The reviewer avoids installing dependencies, starting persistent services, or making network calls without approval. Check the report's **Verification** and **Limitations** sections to see what ran and what remains unverified.

## Safety and limitations

- Review commands should be read-only except for generated files below `.pr-review/`.
- The report is local and does not upload source code.
- AI review is non-deterministic and can miss defects or produce false positives.
- Continue to use CI, automated tests, security scanners, and human review before merging production changes.

For the shorter installation reference, see [INSTALL.md](INSTALL.md).

For a one-time personal installation that works across all repositories without copying files into each project, see [PERSONAL-INSTALL.md](PERSONAL-INSTALL.md).
