We found that the worker pod was restarted because the liveness probe failed.
I don’t want to solve this only by increasing probe timeouts, because that feels like a workaround.

Please review the worker architecture and implement controlled high concurrency.

Current model:
- Each pod picks one execution.
- An execution can contain many comparison records.
- We still want high parallelism inside the execution.
- However, we must avoid unbounded Promise.all over all records.

Required direction:
1. Keep worker-per-execution for now.
2. Process records inside the execution with bounded concurrency.
3. The concurrency should be configurable by env var.
4. Prefer adding adaptive backpressure if possible:
   - monitor event loop lag
   - reduce concurrency when lag is high
   - increase concurrency gradually when stable
5. Liveness should stay very lightweight and should not check Mongo/API/Kafka.
6. Readiness can check dependencies, but not liveness.
7. Add logs/metrics for:
   - current concurrency
   - event loop lag
   - record processing duration
   - API latency
   - Mongo save latency
   - errors/timeouts

Goal:
Run with high concurrency, but prevent the worker from choking the Node.js event loop and causing liveness failures.