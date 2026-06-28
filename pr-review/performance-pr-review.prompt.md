# Performance PR Review

Review the currently opened Pull Request from a performance and scalability perspective.

Rules:

- Review only changed code.
- Use surrounding code only as context.
- Only report meaningful performance issues.
- Do not report micro-optimizations.

Check for:

- N+1 queries
- repeated DB/API calls
- unbounded queries
- missing index for new query pattern
- blocking operations
- large allocations
- inefficient algorithms
- missing pagination
- memory leaks
- unbounded caches
- excessive parallelism

Return:

# Performance Summary

# Performance Findings

# Scalability Risks

# Suggested Fixes

# Merge Recommendation
