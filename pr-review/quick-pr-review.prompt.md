# Quick PR Review

Perform a short, high-signal review of the currently opened Pull Request.

Rules:

- Start from the PR diff.
- Review only changed code.
- Use surrounding code only as context.
- Report only Medium/High confidence issues.
- Ignore style, formatting, and unrelated refactors.
- Focus on blocking or important issues only.

Return:

# Summary

# Blocking Issues

# Important Non-Blocking Issues

# Missing Tests

# Merge Recommendation

If there are no important issues, say:

> I couldn't find any production-impacting issues in the current changes.
