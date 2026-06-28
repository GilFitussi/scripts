---
applyTo: "**"
---

# PR Review Scope

This file has the highest priority after the workflow instructions.

Your review scope is strictly limited to the code changed in the current Pull Request.

---

## Strict scope rules

Review only:

- changed lines
- changed blocks
- newly added files
- deleted behavior caused by the PR
- modified tests
- modified configuration
- modified documentation only when it affects behavior, operation, or correctness

Do not review:

- unrelated files
- unchanged old code
- existing technical debt
- future refactoring opportunities
- personal style preferences
- architecture issues that existed before the PR and were not made worse

---

## Surrounding code rule

You may inspect surrounding code only to understand the impact of changed code.

Surrounding code is context only.

Surrounding code is never the review target.

Allowed context expansion:

- function containing the changed lines
- callers of the changed function
- called functions
- imports and exports
- interfaces and types
- service / repository methods used by the change
- API contracts
- database schema / model definitions
- configuration used by the change
- tests related to the changed behavior

Stop exploring when you have enough context to validate the changed block.

---

## Finding causality rule

Every finding must be directly caused by the current PR.

Before reporting an issue, ask:

> Would this issue disappear if this PR did not modify these lines?

If the answer is yes, report it.

If the answer is no, ignore it.

If the issue existed before and the PR does not make it worse, ignore it.

If the PR touches code near an existing bug but does not introduce or worsen it, ignore it.

---

## No drive-by refactoring

Do not suggest refactoring unless it directly fixes a real issue introduced by this PR.

Avoid comments like:

- "Consider cleaning up this class"
- "This could be more elegant"
- "Maybe use another pattern"
- "We should rename this"
- "This old code is complex"

These are not valid PR findings unless the current PR introduced the problem and it matters.

---

## Golden review method

Always use:

Diff first → minimal context → issue only if caused by changed code → human comment.
