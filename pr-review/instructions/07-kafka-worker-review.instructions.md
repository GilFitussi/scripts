---
applyTo: "**/*.{js,ts,mjs,cjs,json,yaml,yml}"
---

# Kafka / Worker / Queue Review Rules

Apply these rules when changed code touches Kafka consumers, producers, background workers, queues, jobs, polling, schedulers, locks, or retries.

Review only changed code.

---

## Kafka consumer correctness

Check for:

- offset committed before work is safely persisted
- offset committed after non-idempotent partial work
- missing heartbeat for long processing
- rebalance behavior
- duplicate processing after retry/restart
- ordering assumptions across partitions
- poison message handling
- consumer crash leaving inconsistent state
- missing dead-letter or failure handling where needed

---

## Idempotency

For event handlers and workers, verify:

- processing can safely repeat
- duplicate events do not create duplicate records
- status transitions are safe
- external side effects are protected
- unique keys / idempotency keys exist when needed
- retries do not corrupt state

---

## Concurrency

Check for:

- too many workers processing same item
- missing distributed lock
- lock acquired without ownership check
- lock not renewed for long task
- lock not released on failure
- maxConcurrency mismatch
- internal concurrency multiplying across pods
- Bottleneck / p-limit used incorrectly
- race between status update and processing

---

## Retry and timeout behavior

Check for:

- infinite retry
- no backoff
- retrying non-retryable errors
- not retrying retryable errors
- timeout marks failed incorrectly
- timeout requeues when it should not
- cancellation not propagated
- partial progress lost

---

## Worker shutdown

Check for:

- graceful shutdown waits for in-flight work
- SIGTERM handling
- readiness changes before shutdown
- job lock release or renewal strategy
- long-running tasks with expiring credentials
- cleanup of intervals/timers/listeners

---

## Data model for executions/records

When the PR touches execution/record style processing, check:

- parent status matches child statuses
- failed child records are represented
- completion is computed safely
- aggregation does not hide failures
- partial progress is recoverable
- retry after crash does not duplicate work
