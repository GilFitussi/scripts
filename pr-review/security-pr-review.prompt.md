# Security PR Review

Review the currently opened Pull Request from a security perspective.

Rules:

- Review only changed code.
- Use surrounding code only as context.
- Do not report unrelated pre-existing security debt unless this PR makes it worse.
- Focus on realistic exploitability and production impact.

Check for:

- authentication bypass
- authorization gaps
- input validation
- injection
- secret leakage
- sensitive logging
- unsafe serialization/deserialization
- path traversal
- SSRF
- insecure defaults
- exposure of internal errors
- overly broad Kubernetes/OpenShift/Vault permissions

Return:

# Security Summary

# Security Findings

# Suggested Fixes

# Security Risk Level

# Merge Recommendation
