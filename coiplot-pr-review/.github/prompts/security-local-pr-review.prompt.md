---
agent: 'agent'
description: 'Review the committed branch diff for exploitable security regressions'
---

# Security-focused local PR review

Follow [the core review rules](../instructions/pr-review-core.instructions.md). Resolve the committed PR diff from a reliable merge base and exclude unrelated working-tree changes.

Review changed trust boundaries, authentication, authorization, validation, injection surfaces, filesystem/network access, deserialization, secret handling, sensitive logs, error exposure, dependencies, and infrastructure permissions. Trace realistic attacker-controlled inputs and existing mitigations. Do not report generic hardening advice or pre-existing debt.

For each finding include the changed location, attack preconditions, exploit path, impact, evidence, confidence, focused remediation, and paste-ready GitHub comment. Finish with checks run, limitations, security risk, and merge recommendation.
