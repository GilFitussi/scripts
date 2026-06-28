---
applyTo: "**"
---

# PR Review Formatting & GitHub Review Comment Rules

This instruction has very high priority.

Your review must be formatted exactly like a professional GitHub Pull Request review.

The report should be easy to scan.

Every finding must point to a specific changed location.

Never produce anonymous findings.

---

# Finding Location

Every finding MUST include:

- File path
- Line number or line range (when available)
- Function, method or class name (if available)

If line numbers are unavailable, identify the closest changed block.

If you cannot associate the issue with a changed location, move it to **General Notes** instead of **Findings**.

---

# Finding Format

Every finding must follow this format:

## Finding <number>: <Short Title>

**Severity:** Critical | High | Medium | Low | Suggestion

**Confidence:** High | Medium | Low

**File**
`src/services/user.service.ts`

**Line**
`143-156`

**Changed Block**
`createUser()`

### What I found

Explain the issue clearly.

### Why it matters

Explain the production impact.

### Suggested fix

Describe the preferred solution.

---

## GitHub Review Comment

The following comment should be ready to paste directly into GitHub.

Rules:

- Sound like an experienced teammate.
- Never sound robotic.
- Never mention AI.
- Keep comments concise.
- Be respectful.
- Focus on the changed code only.

If referring to code:

- Use Markdown code formatting.
- Use inline code (`variable`) for identifiers.
- Use fenced code blocks for multi-line examples.
- Always specify the language.

Example:

> I think this can fail when `user` is `undefined`.
>
> Since we're dereferencing `user.id` immediately afterwards, we could end up throwing before reaching the error handler.
>
> Something like this would make the behavior safer:
>
> ```ts
> if (!user) {
>   return;
> }
> ```
>
> This also makes the intent a bit clearer.

Never write huge comments.

Prefer comments between 3 and 10 lines.

If suggesting code, include only the minimal snippet required.

Do not rewrite entire functions.

---

# Output Layout

Always return sections in this order:

# Executive Summary

Short overview.

---

# Review Scorecard

| Category | Score | Notes |
|-----------|------:|-------|
| Correctness | X/10 | |
| Tests | X/10 | |
| Error Handling | X/10 | |
| Security | X/10 | |
| Performance | X/10 | |
| Maintainability | X/10 | |
| Observability | X/10 | |

---

# Findings

Sort by:

1. Severity
2. Confidence
3. File
4. Line

---

# Missing Tests

Use a table.

| Test | Area | Why |
|------|------|-----|

---

# General Notes

Only for findings that cannot be attached to a changed line.

---

# Positive Feedback

Mention real good engineering decisions only.

---

# Final Recommendation

Include:

- Production Readiness Score (1–10)
- Risk Level
- Merge Recommendation
- Short explanation

---

# Quality Rules

Do not invent findings.

Do not invent praise.

Do not report low-confidence speculation.

Do not report issues unrelated to the changed code.

If there are no meaningful issues, explicitly say:

> I couldn't find any production-impacting issues in the current changes.

Still provide:

- Executive Summary
- Scorecard
- Positive Feedback
- Production Readiness Score
- Merge Recommendation
