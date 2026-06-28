---
applyTo: "**"
---
# PR Review Scope

Review ONLY changed code.

Never review unrelated code.
Never suggest unrelated refactoring.
Never report existing technical debt unless this PR makes it worse.

Use surrounding code only as context.

Every finding must be directly caused by the modified code.

Rule:
Diff first → minimal context → findings only if caused by the current PR.
