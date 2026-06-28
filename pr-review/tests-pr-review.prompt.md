# Tests PR Review

Review the currently opened Pull Request focusing only on tests and test gaps.

Rules:

- Review only changed code and tests related to the changed behavior.
- Use surrounding tests only as context.
- Do not ask for tests unrelated to this PR.
- Report missing tests only when they cover meaningful risk.

Check for:

- missing unit tests
- missing integration tests
- missing regression tests
- missing failure-path tests
- missing concurrency/idempotency tests
- weak assertions
- over-mocking
- flaky async behavior
- tests that would pass even if the implementation is broken

Return:

# Test Summary

# Missing Tests

# Weak Tests

# Suggested Test Cases

# Merge Recommendation
