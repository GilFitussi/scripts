# Copilot local PR review pack

This package adds reusable local pull request reviews to GitHub Copilot Chat in VS Code. It reviews the committed branch diff from a merge base, can run relevant checks, and produces `.pr-review/findings.json` plus a self-contained `.pr-review/report.html`.

## Install into one repository

Copy the package's `.github` directory into the root of the target Git repository. Merge it with an existing `.github` directory; do not replace unrelated workflows or configuration.

The resulting paths must be:

```text
<repository>/.github/instructions/pr-review-core.instructions.md
<repository>/.github/instructions/node-typescript-review.instructions.md
<repository>/.github/instructions/data-workers-infra-review.instructions.md
<repository>/.github/prompts/full-local-pr-review.prompt.md
<repository>/.github/prompts/quick-local-pr-review.prompt.md
<repository>/.github/prompts/security-local-pr-review.prompt.md
<repository>/.github/pr-review/schema/findings.schema.json
<repository>/.github/pr-review/scripts/collect-review-context.ps1
<repository>/.github/pr-review/scripts/validate-and-render.ps1
```

Append the line from `.gitignore.snippet` to the target repository's `.gitignore` so generated reports are not committed.

## VS Code prerequisites

1. Install or update GitHub Copilot and GitHub Copilot Chat.
2. Open the Git repository root as the VS Code workspace.
3. Use a trusted workspace so Agent mode can run terminal commands.
4. For PR metadata, install GitHub Pull Requests and Issues and open the PR in VS Code. This is optional when the base branch is supplied manually.

VS Code discovers workspace instructions below `.github/instructions` and prompt files below `.github/prompts`. If they do not appear, run `Chat: Open Customizations` from the Command Palette and inspect the Chat customization diagnostics.

## Run a complete review

1. Check out the feature branch to review.
2. Fetch the base branch so its remote ref is current.
3. Open Copilot Chat and choose Agent mode.
4. Run `/full-local-pr-review` from the prompt picker.
5. If Copilot cannot determine the base, add it to the request, for example: `Review against origin/main`.
6. Approve only the safe read-only commands and report-file writes you expect.
7. Open `.pr-review/report.html` when the review completes.

If Windows blocks unsigned local PowerShell scripts, Copilot can invoke them with a process-scoped bypass such as `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <script> ...`. This does not change the machine-wide execution policy. Review the script before approving the command.

The complete prompt reviews committed branch changes only. It reports staged, unstaged, and untracked files separately so they are not accidentally presented as PR changes.

## Other prompts

- `/quick-local-pr-review`: faster review with only high-signal issues; it does not generate HTML by default.
- `/security-local-pr-review`: security-only pass focused on realistic exploitability.

## Files and responsibilities

- `pr-review-core.instructions.md`: scope, causality, confidence, severity, and review-quality rules.
- `node-typescript-review.instructions.md`: Node.js, JavaScript, TypeScript, and asynchronous test checks.
- `data-workers-infra-review.instructions.md`: database, worker, queue, deployment, and secrets checks.
- `full-local-pr-review.prompt.md`: complete end-to-end workflow, including checks, JSON, validation, and HTML.
- `collect-review-context.ps1`: deterministically resolves the merge base and captures the committed diff and working-tree state.
- `findings.schema.json`: output contract Copilot follows.
- `validate-and-render.ps1`: rejects findings not anchored to an added/modified diff line and creates the HTML report.

## Notes

- The scripts require PowerShell and Git. On Windows, run them in PowerShell. On macOS/Linux, install PowerShell 7 (`pwsh`) or replace the scripts with equivalents for your shell.
- The HTML is local and self-contained; it does not upload source or findings.
- AI review is non-deterministic. Treat it as an additional reviewer, not a replacement for tests, CI, security tooling, or human approval.
