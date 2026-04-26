---
description: "Use when creating or modifying GitHub Actions workflows in this repo. Covers least-privilege permissions, action pinning, concurrency, and trigger hygiene."
applyTo: ".github/workflows/**"
---

# Workflow authoring rules

## Required for every workflow

- A `permissions:` block at the workflow OR job level. Default to `contents: read`.
- A meaningful `name:` and `on:` trigger; avoid `on: push` without a branch filter.
- `concurrency:` for any workflow that deploys, comments on PRs, or pushes to a branch.
- Pin actions: use `@vN` major tags at minimum; pin third-party actions to a full SHA.

## Permissions cheat sheet

| Capability | Permission |
|------------|------------|
| Read code | `contents: read` |
| Push commits / tags | `contents: write` |
| Comment on PRs / issues | `pull-requests: write` / `issues: write` |
| Upload SARIF / CodeQL | `security-events: write` |
| Pages deploy via Actions | `pages: write`, `id-token: write` |

## Triggers

- `pull_request` should specify `branches: [main]` and, where useful, `paths:` to skip irrelevant runs.
- Scheduled jobs (`schedule.cron`) should also expose `workflow_dispatch` for manual runs.
- Avoid `pull_request_target` unless you understand the security implications (untrusted code with write token).

## Secrets & tokens

- Use `${{ secrets.GITHUB_TOKEN }}` whenever possible — never store a PAT in the repo.
- Mask any echoed values with `::add-mask::` if they could leak into logs.

## Anti-patterns

- `permissions: write-all` — never. Grant per job.
- Unpinned `uses: actions/checkout@main` — pin to `@v4` minimum.
- Overlapping deploy workflows without `concurrency:` — causes race conditions on Pages.
- Using `pull_request_target` to comment on PRs when `pull_request` + `permissions: pull-requests: write` works.
