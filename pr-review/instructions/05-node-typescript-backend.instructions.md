---
applyTo: "**/*.{js,ts,mjs,cjs}"
---

# Node.js / TypeScript Backend Review

Apply these rules only when reviewing changed Node.js / TypeScript backend code.

The changed code remains the only review target.

---

## Async correctness

Check changed code for:

- missing await
- unhandled promises
- lost return from async function
- async callback used where result is ignored
- `array.map(async ...)` without `Promise.all`
- `forEach(async ...)`
- `Promise.all` when one failure should not cancel all work
- missing timeout around external calls
- missing abort / cancellation handling
- error propagation across async boundaries

---

## Runtime behavior

Check for:

- code that can crash the process
- uncaught exception
- unhandled rejection
- sync blocking operation in request path
- large JSON stringify/parse in hot path
- memory growth from unbounded maps/caches
- missing cleanup of timers/intervals/listeners
- missing graceful shutdown for long-running work

---

## TypeScript

Check for:

- unsafe `any`
- type assertion hiding real mismatch
- nullable value used without guard
- optional property assumed to exist
- union type not handled completely
- public type/interface contract changed without caller updates
- mismatch between runtime validation and TypeScript type

Do not complain about `any` unless it creates real risk in changed code.

---

## Module system

Check for:

- ESM / CommonJS interop issues
- default import vs named import mismatch
- missing file extension where required by ESM setup
- wrong `__dirname` / `__filename` replacement in ESM
- top-level await effects
- dynamic import error handling
- package `type` field implications

---

## HTTP/API services

Check for:

- missing request validation
- changed response shape
- changed status code
- changed error body
- missing auth check
- leaking internal errors
- missing pagination / limit
- unbounded input
- inconsistent error handling between routes
- missing tests for API contract changes

---

## Configuration

Check for:

- new environment variable without validation
- changed default with production impact
- config read at import time when reload is expected
- secrets logged or exposed
- config reload race conditions
- wrong fallback behavior
