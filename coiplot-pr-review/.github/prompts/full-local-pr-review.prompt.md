---
agent: 'agent'
description: 'Run a complete local PR review and generate JSON and HTML reports'
---

# Full local pull request review

Perform a complete, read-only review of the current branch. Follow [the core review rules](../instructions/pr-review-core.instructions.md). Apply the language and infrastructure instructions when their file patterns or subject matter are relevant.

Do not edit application code. You may create or replace files only under `.pr-review/`.

## 1. Resolve the review range

Determine the base ref in this order:

1. Base branch of the Pull Request currently opened by the GitHub Pull Requests extension, if available.
2. Base ref supplied by the user in this chat.
3. Configured upstream/default remote branch.
4. `origin/main`, then `origin/master`, only when the ref exists and is a plausible repository default.

Do not silently guess. If no reliable base exists, ask for it and stop.

Compute the merge base with `git merge-base HEAD <base-ref>`. Review committed branch changes from that merge base through `HEAD`. Enable rename detection.

Separately inspect and report whether staged, unstaged, and untracked changes exist. Exclude them from the PR findings unless the user explicitly asks to include the complete local working tree. Never mix their results silently with the committed PR diff.

## 2. Collect context

Locate the review tools in this order:

1. Personal installation: `$HOME/.copilot/pr-review`.
2. Repository installation: `.github/pr-review`.

Use the first location containing the schema and tools for the current operating system. On macOS/Linux, require `scripts/collect-review-context.sh` and `scripts/validate-and-render.py`. On Windows, require the corresponding PowerShell scripts. If no complete tool set exists, stop and explain that the personal or repository tools are not installed.

On macOS/Linux run:

```bash
bash "<tool-root>/scripts/collect-review-context.sh" --base-ref "<base-ref>"
```

On Windows run `<tool-root>/scripts/collect-review-context.ps1` with the resolved base ref. Then read `.pr-review/context.json` and `.pr-review/pr.diff`.

Read PR title, description, linked issue, acceptance criteria, and design documents when available. If unavailable, state that intent was inferred from the diff and repository context.

Build an internal change map: changed files, changed symbols, behavior added/removed, contracts, tests, dependencies, configuration, migrations, and risk surfaces.

## 3. Analyze the change

Start with every diff hunk. Expand only to the minimum context needed. You may inspect unchanged code to trace impact, but every finding must be caused by and anchored to a changed line.

For each candidate issue, attempt to disprove it. Trace actual callers, configuration, guards, tests, and runtime behavior. Omit speculative or duplicate issues.

## 4. Run verification

Discover project commands from manifests, build files, CI workflows, and repository documentation. Prefer focused checks for affected packages/files, followed by broader checks only when their cost is reasonable.

Run applicable typecheck, build, lint, and tests when safe. Do not install dependencies, change lockfiles, start persistent services, access production systems, or make network calls without explicit user approval.

Record the exact command, status, duration if known, and a concise result. A command not run is `not_run`, never `passed`.

## 5. Write structured results

Create `.pr-review/findings.json` conforming to `<tool-root>/schema/findings.schema.json`.

Every finding must contain a changed file and an added/modified line from the committed PR diff. Use `limitations` for unavailable context or incomplete checks. Do not create a finding merely because tests did not run.

For each finding, write `reviewComment` as standalone Markdown that the user can copy from the JSON or HTML report and paste directly into the GitHub PR conversation. The comment must make sense without the rest of the report. Do not include the finding ID, severity, confidence, or JSON/report terminology in it.

Set the recommendation deterministically:

- `do_not_merge` when a Critical finding exists.
- `merge_after_fixes` when a High finding exists, or a Medium correctness/security/reliability finding requires correction.
- `ready_with_caveats` when no blocking finding exists but verification is materially incomplete.
- `ready_to_merge` only when no blocking finding exists and relevant verification completed successfully.

## 6. Validate and render

On macOS/Linux run:

```bash
python3 "<tool-root>/scripts/validate-and-render.py" --input .pr-review/findings.json --context .pr-review/context.json --output .pr-review/report.html
```

On Windows run:

```powershell
& "<tool-root>/scripts/validate-and-render.ps1" -InputPath .pr-review/findings.json -ContextPath .pr-review/context.json -OutputPath .pr-review/report.html
```

Fix only report/schema/location errors and rerun until validation succeeds. Do not weaken validation or invent locations.

## 7. Respond

Summarize the finding count by severity, verification status, recommendation, and limitations. Link to `.pr-review/report.html`. If no production-impacting findings exist, say so explicitly without implying that unexecuted checks passed.
