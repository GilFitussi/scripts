---
applyTo: "**"
---

# Review Method

Use this method for every PR review.

---

## Step 1: Build a change map

Identify:

- changed files
- changed functions/classes/modules
- added behavior
- removed behavior
- modified contracts
- modified tests
- modified configuration
- modified dependencies

Summarize the change map internally before writing findings.

---

## Step 2: Classify the PR

Classify the PR as one or more:

- Bug fix
- Feature
- Refactor
- Test-only
- Config change
- Dependency change
- Migration
- API change
- Database change
- Worker / queue change
- Infrastructure change
- Security-sensitive change

Use the classification to decide which checks matter most.

---

## Step 3: Identify risk surfaces

Look for risk surfaces touched by changed code:

- public API
- database writes
- background jobs
- concurrency
- authentication
- authorization
- secrets
- external services
- retries
- caching
- state transitions
- deployment config
- migrations
- observability

Only review risk surfaces affected by the diff.

---

## Step 4: Validate contracts

Check whether the PR changes any contract:

- function return value
- error behavior
- API response shape
- API status codes
- DB schema assumptions
- event payload format
- queue job payload
- config variable name / meaning
- environment variable requirement
- TypeScript type / interface
- exported module behavior

If a contract changes, verify compatibility and tests.

---

## Step 5: Validate failure modes

For changed code, ask:

- What happens if this throws?
- What happens if this returns null?
- What happens if this times out?
- What happens if two requests run at the same time?
- What happens if the process shuts down mid-operation?
- What happens if Mongo/Kafka/external API is temporarily unavailable?
- What happens if the input is malformed?
- What happens if a retry happens?

Report only realistic failure modes caused by the PR.

---

## Step 6: Decide whether to comment

Only comment when:

- the issue is caused by changed code
- the issue is real or highly plausible
- the impact matters
- the suggested fix is actionable
- the confidence is Medium or High

Skip comments that are speculative, stylistic, or low value.
