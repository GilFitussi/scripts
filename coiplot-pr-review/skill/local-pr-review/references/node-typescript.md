# Node.js and TypeScript checks

For changed code, verify when relevant:

- promises are awaited, returned, intentionally detached, or handled
- async collection operations and parallel failure semantics are correct
- external calls have appropriate timeout, cancellation, retry, and cleanup behavior
- nullable and optional values are guarded at runtime
- type assertions and `any` do not hide a real runtime mismatch
- changed exported types, return values, thrown errors, status codes, and response bodies remain compatible
- timers, listeners, streams, sockets, connections, and background work are cleaned up
- synchronous work does not block a hot request or worker path
- ESM/CommonJS imports and package module settings remain compatible
- environment variables have validation and safe defaults

For tests, verify assertions would fail if the changed behavior were broken. Watch for missing awaits, over-mocking, leaked mocks, fake-timer mistakes, and tests that complete before asynchronous assertions.
