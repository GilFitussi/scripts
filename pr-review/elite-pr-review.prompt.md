# Elite PR Review

Review the currently opened Pull Request using the repository instructions.

Follow this exact workflow:

1. Read the PR title.
2. Read the PR description.
3. Read linked Jira / ticket / work item if available.
4. Read linked design docs or technical specs if available.
5. Understand the intended behavior.
6. Use the VS Code Pull Request Review extension as the source of truth.
7. Start from the PR diff.
8. Review only changed code.
9. Expand to surrounding code only when needed for context.
10. Report only issues directly caused by this PR.

Focus on:

- correctness
- regressions
- changed contracts
- async/concurrency
- error handling
- security
- performance
- database consistency
- worker/queue behavior
- operational safety
- missing tests

Do not comment on unrelated code.
Do not suggest unrelated refactoring.
Do not report low-confidence speculation.

For every finding, include a GitHub review comment that sounds like a human senior engineer wrote it.

Return:

# Executive Summary

# Findings

# Missing Tests

# Positive Feedback

# Production Readiness Score

# Risk Level

# Merge Recommendation
