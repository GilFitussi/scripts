---
applyTo: "**/*.{js,ts,mjs,cjs,json}"
---

# MongoDB Review Rules

Apply these rules when changed code touches MongoDB, Mongoose, migrations, indexes, DB connections, or repository code.

Review only changed code.

Use schema/model/repository files as context only.

---

## Query safety

Check for:

- unbounded queries
- missing limit/pagination
- inefficient filters
- regex queries that cannot use indexes
- user-controlled query object injection
- wrong projection
- missing sort when deterministic order matters
- query shape that likely needs an index

---

## Atomicity and consistency

Check for:

- read-modify-write race conditions
- non-atomic counters/status updates
- wrong `findOneAndUpdate` usage
- missing filter condition for lock/state transition
- upsert creating duplicates
- partial writes across multiple collections
- missing transaction when multiple writes must be consistent
- transaction used unnecessarily in high-risk way

---

## Updates

Check for:

- `$set` overwriting nested objects unintentionally
- `$push` causing unbounded array growth
- missing `$addToSet` when uniqueness is required
- wrong `$inc`
- update without checking matched/modified count
- status transition that can go backward
- stale data overwrite

---

## Indexes

If the PR adds a new query pattern, check whether an index is needed.

If the PR adds an index, check:

- index matches query and sort pattern
- uniqueness is intentional
- sparse/partial behavior is correct
- migration/deployment impact is considered
- index name is stable if used operationally

---

## Connection and reload

Check for:

- stale Mongo connection usage
- using closed connection after reload
- credentials cached longer than intended
- in-flight job behavior during reconnect
- graceful shutdown of old connection
- retry behavior after credential rotation
- connection replacement that affects long-running tasks

---

## Agenda / Mongo-backed jobs

If changed code uses Agenda or Mongo-backed jobs, check for:

- lockLifetime too short for long tasks
- job timeout behavior
- failure state handling
- retry vs no-retry behavior
- duplicate job execution
- processor registration order
- missing job definitions
- job removal assumptions
- graceful shutdown while jobs are running
