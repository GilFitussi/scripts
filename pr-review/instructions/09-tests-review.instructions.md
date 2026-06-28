---
applyTo: "**/*.{js,ts,mjs,cjs,test.js,test.ts,spec.js,spec.ts}"
---

# Test Review Rules

Apply these rules when reviewing changed tests or code that should have tests.

Review only changed code and tests relevant to changed behavior.

---

## Test quality

Check that tests:

- verify behavior, not implementation details
- cover the changed logic
- include important edge cases
- would fail before the fix/change
- are deterministic
- do not rely on test order
- do not use real external services unless integration test is intended
- clean up resources
- do not hide failures with broad mocks

---

## Missing tests

Ask whether the PR needs tests for:

- happy path
- empty input
- null/undefined input
- invalid input
- failure path
- retry behavior
- timeout
- concurrency
- duplicate event
- DB error
- external API error
- authorization failure
- backward compatibility
- migration behavior

Report missing tests only when the changed behavior has meaningful risk.

---

## Mocking

Check for:

- mocks not reset between tests
- mock behavior inconsistent with real dependency
- mocking the unit under test
- over-mocking that prevents regression detection
- ESM mocking issues
- hoisted mock pitfalls
- spy not restored

---

## Async tests

Check for:

- missing await in test
- promise not returned
- test finishes before async assertion
- fake timers not advanced correctly
- unhandled rejection hidden
- race-prone assertion
- timeout too low/high

---

## Integration tests

For API/DB/worker changes, consider whether an integration test is needed.

Especially for:

- API contract changes
- Mongo query/update behavior
- Kafka/worker processing
- authentication/authorization
- error response shape
- concurrency or idempotency
