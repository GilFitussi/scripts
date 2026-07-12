---
name: Data Workers and Infrastructure PR Review
description: Extra checks for databases, queues, workers, deployment configuration, and secrets.
applyTo: "**/*.{js,ts,mjs,cjs,json,yaml,yml,sql,sh,ps1}"
---

# Data, worker, and infrastructure checks

Apply only relevant sections.

## Databases

- Check atomicity of read-modify-write paths, transactions, upserts, uniqueness, and partial writes.
- Check query bounds, pagination, deterministic ordering, projections, indexes for new query shapes, and unsafe user-controlled filters.
- Check migration compatibility, rollout order, locking, backfill cost, rollback safety, and mixed-version deployments.

## Queues and workers

- Check idempotency, duplicate delivery, retry classification, backoff, poison messages, ordering assumptions, and partial side effects.
- Check lock ownership and renewal, concurrency multiplication across replicas, heartbeat/offset timing, and graceful shutdown of in-flight work.

## Infrastructure and secrets

- Check RBAC scope, service accounts, secret exposure, credential rotation, probes, resource configuration, environment-variable consistency, and termination timing.
- Check whether new critical failure states are diagnosable through existing logs, metrics, and identifiers.
