---
name: local-pr-review
description: Perform a high-signal local Pull Request review of the current Git branch, scoped to committed changes from the merge base. Use when the user asks to review a PR, branch, diff, or local changes for correctness, regressions, security, concurrency, data integrity, performance, operations, or missing tests, and when generating structured JSON or an HTML review report with GitHub-ready comments. Supports macOS and Windows.
---

# Local PR Review

Perform a read-only review of the current repository. Do not edit application code unless the user separately requests fixes after receiving the review.

## Select the review mode

- Default to `full`.
- Use `quick` when requested: report only Critical, High, and strong Medium findings; HTML is optional.
- Use `security` when requested: focus on realistically exploitable security regressions.
- Use `tests` when requested: focus on meaningful missing or ineffective tests for changed behavior.

## Resolve the review range

Determine the base ref in this order:

1. Base branch of the Pull Request opened in the GitHub Pull Requests extension, when available.
2. Base ref supplied by the user.
3. Configured upstream or remote default branch.
4. `origin/main`, then `origin/master`, only if the ref exists and is plausible.

Do not silently guess. Ask for the base ref and stop when it cannot be determined reliably.

Review committed changes from `git merge-base HEAD <base-ref>` through `HEAD`. Detect staged, unstaged, and untracked changes separately. Exclude them unless the user explicitly requests a working-tree review.

## Load the required guidance

Read [references/review-core.md](references/review-core.md) for every review.

Read only the relevant specialized references:

- Read [references/node-typescript.md](references/node-typescript.md) for changed JavaScript or TypeScript.
- Read [references/data-workers-infra.md](references/data-workers-infra.md) when the diff touches databases, migrations, queues, workers, deployment configuration, infrastructure, or secrets.
- Use [references/findings.schema.json](references/findings.schema.json) when writing the structured report.

## Collect deterministic context

Resolve this skill directory as `<skill-root>`.

On macOS/Linux run:

```bash
bash "<skill-root>/scripts/macos/collect-review-context.sh" --base-ref "<base-ref>"
```

On Windows run:

```powershell
& "<skill-root>/scripts/windows/collect-review-context.ps1" -BaseRef "<base-ref>"
```

Never create review artifacts inside the repository. Store all output below the centralized personal directory:

```text
~/Copilot-PR-Reviews/<repository>/<PR-number-or-branch>/<timestamp>/
```

When a PR number is available, pass `--review-key "PR-<number>"` on macOS/Linux or `-ReviewKey "PR-<number>"` on Windows. Otherwise let the collector use the current branch name. The user may override the root with `COPILOT_PR_REVIEW_OUTPUT_ROOT`.

Capture the `REPORT_DIRECTORY=...` value printed by the collector as `<report-dir>`. Read `<report-dir>/context.json`, `<report-dir>/changed-files.txt`, and `<report-dir>/pr.diff`.

If PR metadata is available, read its title, description, linked issue, acceptance criteria, and relevant design documents. Otherwise state that intent was inferred from the diff and repository context.

Build an internal change map covering changed symbols, behavior, contracts, tests, dependencies, configuration, migrations, and affected risk surfaces.

## Analyze and verify

Start from every diff hunk. Inspect unchanged callers, callees, schemas, types, configuration, and tests only when required to prove or disprove the impact of a changed line.

For each candidate finding, establish a realistic trigger, execution path, observable impact, causal link to the diff, and focused correction. Attempt to disprove the issue before reporting it. Omit speculation, style preferences, pre-existing debt, unrelated refactors, and duplicates.

Discover relevant build, typecheck, lint, and test commands from repository configuration and CI. Run safe, focused checks first. Do not install dependencies, modify lockfiles, access production systems, start persistent services, or make network calls without explicit approval.

Record each check as `passed`, `failed`, `not_run`, or `unavailable`. Never imply that an unexecuted check passed.

## Produce and validate the report

For a full review, create `<report-dir>/findings.json` conforming to [references/findings.schema.json](references/findings.schema.json).

Every finding must point to an added or modified line. Populate `reviewComment` with self-contained Markdown ready to paste directly into the GitHub PR. Do not include severity, confidence, finding IDs, AI references, or report terminology inside that comment.

Set the recommendation deterministically:

- `do_not_merge`: at least one Critical finding.
- `merge_after_fixes`: a High finding, or a Medium correctness/security/reliability issue requiring correction.
- `ready_with_caveats`: no blocking finding, but relevant verification is materially incomplete.
- `ready_to_merge`: no blocking finding and relevant verification completed successfully.

On macOS/Linux validate and render with:

```bash
python3 "<skill-root>/scripts/macos/validate-and-render.py" --input "<report-dir>/findings.json" --context "<report-dir>/context.json" --output "<report-dir>/report.html"
```

On Windows validate and render with:

```powershell
& "<skill-root>/scripts/windows/validate-and-render.ps1" -InputPath "<report-dir>/findings.json" -ContextPath "<report-dir>/context.json" -OutputPath "<report-dir>/report.html"
```

Fix report data or locations until validation passes. Never weaken validation or invent a changed location.
Use the bundled shared HTML template through the platform renderer; do not generate a separate ad-hoc HTML design.

## Respond

Summarize:

- reviewed base, merge base, and head
- finding count by severity
- checks actually run and their status
- limitations
- merge recommendation
- absolute path to `<report-dir>/report.html` for full reviews

If no meaningful issue is found, say so explicitly without implying that unexecuted verification passed.
