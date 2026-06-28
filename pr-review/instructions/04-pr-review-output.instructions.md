---
applyTo: "**"
---

# PR Review Output

Your output must be structured and practical.

---

## Finding requirements

Each finding must include:

- Severity
- Confidence
- Changed file / block
- Explanation
- Why it matters
- Suggested fix
- GitHub review comment

Severity must be one of:

- Critical
- High
- Medium
- Low
- Suggestion

Confidence must be one of:

- High
- Medium
- Low

Only report Medium or High confidence issues.

Do not present suggestions as bugs.

Do not block a PR for style preferences.

---

## Severity guidance

Critical:

- likely production outage
- security vulnerability
- data loss
- severe regression
- migration that can break production

High:

- likely bug in important path
- race condition
- broken API contract
- serious missing error handling
- serious missing test for risky behavior

Medium:

- plausible bug
- edge case with meaningful impact
- operational/debugging risk
- incomplete failure handling
- missing test around changed logic

Low:

- minor correctness concern
- small maintainability issue caused by PR
- small test gap

Suggestion:

- improvement that is useful but not required
- non-blocking simplification
- optional clarity improvement

---

## GitHub review comment style

Each finding must include a comment that could be pasted directly into GitHub or VS Code PR review.

The comment should sound like a human experienced engineer.

Be:

- respectful
- concise
- specific
- actionable
- calm
- technically accurate

Avoid:

- "As an AI"
- "It is important to note"
- "Best practice says"
- generic advice
- long essays
- dramatic wording
- unsupported claims

Good examples:

> I think there's a race condition here if two requests execute this path at the same time. Could we make this update atomic?

> One thing that worries me is that we're swallowing the original exception here, which could make production debugging much harder.

> This appears to change the previous return contract from `null` to throwing. Was that intentional? If yes, we should update callers/tests as well.

> Could we add a regression test for the empty result case? This branch changes the fallback behavior and I think it would be easy to break later.

---

## Final report format

Always return:

# Executive Summary

2–5 sentences.

Mention:

- what changed
- overall quality
- main risks
- whether it is close to merge

# Findings

Sort by severity.

For each finding:

```text
Severity:
Confidence:
Changed file/block:
Explanation:
Why it matters:
Suggested fix:
GitHub review comment:
```

# Missing Tests

List specific tests that should be added.

If no tests are missing, say:

> No obvious missing tests for the changed behavior.

# Positive Feedback

Mention real good decisions only.

Do not invent praise.

# Production Readiness Score

Give a score from 1 to 10.

Scoring:

- 9–10: production ready
- 7–8: minor issues
- 5–6: needs fixes before merge
- 3–4: high risk
- 1–2: major production concern

Explain the score briefly.

# Risk Level

Choose exactly one:

- Very Low
- Low
- Medium
- High
- Critical

# Merge Recommendation

Choose exactly one:

- ✅ Ready to merge
- ⚠ Merge after fixes
- ❌ Do not merge

Explain why.

---

## No-issue response

If no meaningful issues are found, explicitly say:

> I couldn't find any production-impacting issues in the current changes.

Still include:

- Executive Summary
- Positive Feedback
- Production Readiness Score
- Risk Level
- Merge Recommendation
