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
- PowerShell 5.1 or PowerShell 7 for the bundled scripts.
- A trusted VS Code workspace so Agent mode can execute approved terminal commands.
- Optional: GitHub Pull Requests and Issues extension for PR title, description, and base-branch context.

## Installation

### 1. Copy the customization files

Copy this package's `.github` directory into the root of the repository that you want to review:

```text
coiplot-pr-review/.github  ->  your-repository/.github
```

If the target repository already has a `.github` directory, merge the directories. Do not delete or replace existing GitHub Actions workflows or repository configuration.

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
        └── scripts/
            ├── collect-review-context.ps1
            └── validate-and-render.ps1
```

### 2. Ignore generated reports

Add this entry to the target repository's `.gitignore`:

```gitignore
.pr-review/
```

Generated diffs, findings, and HTML reports can contain source-code context and should normally remain local.

### 3. Confirm VS Code discovered the files

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
