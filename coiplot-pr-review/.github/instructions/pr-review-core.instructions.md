---
name: PR Review Core
description: High-signal, diff-scoped rules for local pull request reviews.
applyTo: "**"
---

# Pull request review rules

- Treat the pull request diff as the review target. Never start by scanning the whole repository.
- A finding must be caused by the diff and anchored to an added or modified line.
- Inspect unchanged callers, callees, types, schemas, tests, and configuration only when needed to prove or disprove the impact of a changed line.
- Do not report pre-existing debt, style preferences, formatting, import order, or unrelated refactoring opportunities.
- Do not modify product code during a review unless the user explicitly asks for fixes.
- Do not claim that a check passed unless its command ran successfully in this review.
- Distinguish `passed`, `failed`, `not_run`, and `unavailable` checks.
- Report only Medium or High confidence findings. Put uncertainty and incomplete verification under limitations.
- Deduplicate findings that describe the same root cause.

## Finding proof standard

Before reporting a finding, establish all of the following:

1. The changed line or changed behavior that introduced the risk.
2. A realistic input, state, or execution path that triggers it.
3. The observable correctness, security, reliability, performance, or operational impact.
4. Why reverting the relevant diff would remove or reduce the issue.
5. A specific, proportionate fix.

If this proof is missing, omit the finding.

## Severity

- **Critical**: likely severe outage, exploitable vulnerability, irreversible data loss, or unsafe migration.
- **High**: likely production bug, serious regression, broken contract, race condition, or major security/reliability issue.
- **Medium**: plausible defect or failure path with meaningful impact.
- Test gaps are findings only when they leave changed, risky behavior materially unprotected.

## Review areas

Apply only areas touched by the diff:

- correctness, edge cases, state transitions, compatibility, and data mapping
- nullability, validation, authorization, trust boundaries, and secret handling
- error propagation, cleanup, rollback, retry, timeout, and cancellation
- asynchronous execution, atomicity, concurrency, ordering, and idempotency
- API, event, database, configuration, and exported type contracts
- query bounds, N+1 work, blocking operations, memory growth, and expected scale
- deployment safety, graceful shutdown, observability, and recoverability
- test effectiveness, failure paths, regressions, and flaky asynchronous behavior

## Review comment style

Write concise comments that can be pasted into GitHub. Sound like an experienced teammate. State the concrete failure mode and ask for or suggest a focused correction. Never mention AI or generic best practices.

For every finding, populate `reviewComment` with a self-contained Markdown comment ready to paste directly into the Pull Request. Do not include severity, confidence, finding IDs, report headings, or phrases such as "the review found" inside the comment. Do not wrap the complete comment in quotation marks or a Markdown blockquote. Include a minimal code snippet only when it materially clarifies the fix.
