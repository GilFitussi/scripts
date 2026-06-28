---
applyTo: "**/*.{yaml,yml,json,js,ts,mjs,cjs,sh}"
---

# Kubernetes / OpenShift / Vault Review Rules

Apply these rules when changed code touches deployment manifests, OpenShift resources, Kubernetes clients, Vault secrets, service accounts, certificates, readiness/liveness, or runtime config.

Review only changed code.

---

## Kubernetes / OpenShift

Check for:

- missing resource requests/limits if required by project conventions
- wrong namespace assumptions
- wrong service account
- RBAC too broad
- missing readiness/liveness probes
- probe too aggressive for startup time
- deployment config that can cause downtime
- CronJob concurrency policy mismatch
- missing TTL for jobs where expected
- env var mismatch
- secret mounted at wrong path
- config map update not reloaded

---

## Graceful shutdown

Check for:

- SIGTERM handling
- HTTP server shutdown
- worker shutdown
- Kafka consumer stop
- Mongo connection close
- in-flight jobs not abandoned
- readiness set to false before shutdown
- shutdown timeout aligned with Kubernetes terminationGracePeriodSeconds

---

## Vault / secrets

Check for:

- secret logged
- secret exposed in response
- secret persisted when it should be memory-only
- credential reload race condition
- stale credentials used after rotation
- missing retry after secret renewal
- overly broad Vault policy
- service account to Vault role mismatch
- hot reload behavior missing or unsafe

---

## Certificates

Check for:

- certificate reload behavior
- stale TLS context
- private key leakage
- wrong certificate path
- missing CA handling
- TLS config read only at startup when rotation is expected
- failure mode when cert is temporarily unavailable

---

## Operational safety

Check for:

- lack of metrics for new critical path
- logs without correlation identifiers
- missing alerts for failure states
- config change that changes production behavior unexpectedly
- dependency on local file path in container
