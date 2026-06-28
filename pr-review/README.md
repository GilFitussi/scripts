# Copilot Elite PR Review Skill Pack

This package configures GitHub Copilot in VS Code to behave like a Staff+ engineer during PR reviews.

## What this pack does

It instructs Copilot to:

- Start from the PR diff, not the whole repository.
- Review only changed code.
- Use surrounding code only as context.
- Read PR title, description, linked Jira/work item, design docs, and relevant PR discussion when available.
- Focus on production-impacting issues.
- Produce human-sounding GitHub review comments.
- Give a production readiness score.
- Give a risk level.
- Give a merge recommendation.

## Folder structure

```text
.github/
├── instructions/
│   ├── 00-pr-review-workflow.instructions.md
│   ├── 01-pr-review-scope.instructions.md
│   ├── 02-pr-review-method.instructions.md
│   ├── 03-pr-review-checklist-core.instructions.md
│   ├── 04-pr-review-output.instructions.md
│   ├── 05-node-typescript-backend.instructions.md
│   ├── 06-mongodb-review.instructions.md
│   ├── 07-kafka-worker-review.instructions.md
│   ├── 08-kubernetes-openshift-vault.instructions.md
│   └── 09-tests-review.instructions.md
└── prompts/
    ├── elite-pr-review.prompt.md
    ├── quick-pr-review.prompt.md
    ├── security-pr-review.prompt.md
    ├── performance-pr-review.prompt.md
    └── tests-pr-review.prompt.md
```

## How to use

1. Copy the `.github` folder to the root of your repository.
2. Open a Pull Request in VS Code using GitHub Pull Requests extension.
3. Open Copilot Chat.
4. Run one of the prompt files, for example:

```text
/elite-pr-review
```

or select `elite-pr-review.prompt.md` from the prompt picker.

## Important idea

The review target is always the PR diff.

Repository files are only context.

The reviewer should never comment on unrelated old code unless the current PR made it worse.
