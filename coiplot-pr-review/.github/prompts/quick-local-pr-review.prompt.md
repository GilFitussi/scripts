---
agent: 'agent'
description: 'Run a fast, high-signal review of the committed branch diff'
---

# Quick local PR review

Follow [the core review rules](../instructions/pr-review-core.instructions.md).

Resolve a reliable base ref and merge base as described by the full review prompt. Review only committed changes from the merge base through `HEAD`. Mention staged, unstaged, and untracked changes but exclude them unless requested.

Focus on Critical, High, and strong Medium-confidence correctness, security, contract, data integrity, concurrency, and reliability problems. Inspect minimal context. Do not modify code and do not report style or optional refactoring.

Return:

1. Scope and inferred intent.
2. Blocking findings with file, changed line, evidence, impact, focused fix, and paste-ready review comment.
3. Important missing tests.
4. Checks actually run.
5. Limitations.
6. Merge recommendation.

If no meaningful issues are found, say: `I couldn't find any production-impacting issues in the committed branch changes.`
