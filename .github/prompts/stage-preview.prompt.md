---
description: "Verify a PR's preview deploy: locate the preview URL, fetch and smoke-check the rendered pages, and post a status update on the PR."
argument-hint: "PR number"
agent: "agent"
---

# Stage / verify a PR preview

The `pr-preview.yml` workflow deploys each PR to `https://<owner>.github.io/<repo>/pr-<N>/`. This prompt verifies that deploy is healthy.

## Steps

1. Resolve PR number from `$ARGUMENTS` (or `gh pr view --json number -q .number`).
2. Wait for the `pr-preview` workflow run to complete on the latest commit: `gh run list --workflow=pr-preview.yml --branch=<branch> --limit=1`.
3. Construct the preview URL from `gh repo view --json owner,name`.
4. Fetch each page and confirm HTTP 200 and that the page contains its expected `<title>`:
   - `index.html`
   - `ms_security_roles.html`
   - `ms_security_projects.html`
   - `certification_strategy.html`
5. Run a quick link-check on the preview URL using `lychee --max-concurrency 4 <url>` (best effort).
6. Post or update a sticky comment on the PR with marker `<!-- preview-status -->`:
   ```
   ### Preview status
   - URL: <preview-url>
   - Pages reachable: ✅ / ❌
   - Link check: pass / N broken
   - Last verified: <UTC timestamp> for commit `<sha7>`
   ```

## Constraints

- DO NOT modify the PR's files.
- DO NOT merge the PR. Only report status.
