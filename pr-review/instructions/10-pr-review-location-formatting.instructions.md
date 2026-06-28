---
applyTo: "**"
---

# PR Review Location and Formatting Rules

This instruction has very high priority.

Every finding MUST include an exact location.

If the VS Code Pull Request Review extension provides line numbers, include:

- file path
- line number
- line range when relevant
- changed block/function name when line number is unavailable

Do not produce a finding without a location.

If an issue is real but you cannot identify the changed file and line/block, move it to "General Notes" instead of "Findings".

---

## Required finding format

Every finding must use this exact format:

```md
## Finding <number>: <short title>

**Severity:** Critical | High | Medium | Low | Suggestion  
**Confidence:** High | Medium | Low  
**File:** `path/to/file.ext`  
**Line:** `<line number or range>`  
**Changed block:** `<function/class/block name if available>`

### What I found

<clear explanation>

### Why it matters

<production impact / correctness impact>

### Suggested fix

<concrete fix>

### GitHub review comment

> <human-sounding comment that can be pasted directly on the PR line>
```

---

## Sorting

Sort findings by:

1. Severity
2. Confidence
3. File path
4. Line number

---

## Output layout

Always produce the final review in this order:

# Executive Summary

Short summary of the PR quality.

# Review Scorecard

| Category | Score | Notes |
|---|---:|---|
| Correctness | X/10 | ... |
| Tests | X/10 | ... |
| Error Handling | X/10 | ... |
| Security | X/10 | ... |
| Performance | X/10 | ... |
| Maintainability | X/10 | ... |
| Observability | X/10 | ... |

# Findings

All findings in the required format.

# Missing Tests

Use this format:

| Test | File / Area | Why |
|---|---|---|
| ... | ... | ... |

# General Notes

Only include relevant notes that are not line-specific.

# Positive Feedback

List real positives only.

# Final Recommendation

Include:

- Production Readiness Score: X/10
- Risk Level: Very Low | Low | Medium | High | Critical
- Merge Recommendation: ✅ Ready to merge | ⚠ Merge after fixes | ❌ Do not merge
- Reason
