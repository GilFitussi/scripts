---
applyTo: "**"
---

# Core PR Review Checklist

Focus on production-impacting issues.

---

## Correctness

Check changed code for:

- incorrect logic
- wrong boolean condition
- missing branch
- missing edge case
- null / undefined access
- wrong default value
- off-by-one errors
- incorrect state transition
- incorrect data mapping
- lost data
- duplicate data
- partial update
- incorrect return value
- broken backward compatibility
- regression from previous behavior

---

## Async and concurrency

Check for:

- missing await
- unhandled promise
- async map without Promise.all
- Promise.all when partial failure handling is required
- race condition
- non-atomic read-modify-write
- duplicate execution
- ordering assumption
- lock not released
- lock lifetime too short
- timeout not handled
- cancellation not handled
- resource leak
- shutdown while work is still running

---

## Error handling

Check for:

- swallowed error
- lost original exception
- generic error that hides context
- missing cleanup
- missing finally
- missing rollback
- partial failure not represented
- retry loop without limit
- retry loop without backoff
- errors logged without relevant identifiers
- expected error treated as unexpected
- unexpected error treated as success

---

## Security

Check for:

- missing input validation
- missing authorization
- authentication bypass
- unsafe trust boundary
- injection risk
- secret in logs
- credentials returned in response
- unsafe serialization
- unsafe deserialization
- path traversal
- leaking internal error details

---

## Performance

Only report meaningful performance issues.

Check for:

- N+1 queries
- repeated DB calls in loops
- repeated external API calls in loops
- unbounded query
- missing pagination / limit
- blocking synchronous operation in hot path
- large unnecessary allocation
- repeated expensive computation
- inefficient algorithm for expected scale
- missing index for new query pattern

---

## Maintainability

Only report maintainability issues introduced by the current PR.

Check for:

- hidden coupling
- duplicated logic
- unclear responsibility
- overly complex condition
- magic value that should be named
- misleading name that can cause misuse
- inconsistent error contract
- inconsistent architecture pattern
- code path that is hard to test

Do not report maintainability issues if they are merely personal preference.

---

## Observability

For production behavior, check:

- meaningful logs
- correlation IDs where relevant
- important identifiers in error logs
- metrics for new worker/job paths
- logs do not leak secrets
- failures can be diagnosed from production logs
- success/failure states are visible

Only comment when observability gap creates real operational risk.
