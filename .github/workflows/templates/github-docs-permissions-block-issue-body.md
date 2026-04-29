## Source

GitHub Actions security hardening — <https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token>

> The default permissions granted to the `GITHUB_TOKEN` when running a workflow can be set in the repository settings. You can also set the permissions for an individual job or for the entire workflow using the `permissions` key.

## Why it matters

This repo's `.github/copilot-instructions.md` and `AGENTS.md` both require a top-level `permissions:` block on every workflow, defaulting to `contents: read` and elevating per job only as needed. A scan of `.github/workflows/*.yml` found __COUNT__ workflow file(s) without a top-level `permissions:` block. Workflows without an explicit block inherit the repository default, which can be broader than the workflow actually needs and silently expands the blast radius of a compromised action.

## Suggested change

Add a top-level `permissions:` block to each workflow listed below, scoped to only the permissions the workflow actually needs. Default to `contents: read` and elevate per job only when required (e.g. `issues: write`, `pull-requests: write`).

Findings:

__FINDINGS__

## Acceptance criteria

- [ ] Every workflow listed above has a top-level `permissions:` block.
- [ ] Each block uses least-privilege scopes (no blanket `write-all`).
- [ ] No regressions in existing workflow runs after the change.
