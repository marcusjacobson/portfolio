# Deployment Rules

This page codifies the deployment and merge-gating contract for the [portfolio repo](https://github.com/marcusjacobson/portfolio) so future contributors — and the [`@wiki-sync`](Agents) agent — can detect drift quickly. The user's intent: "I want one page that names every required check, the Pages deploy contract, and the pitfalls that have already burned me."

For the workflow catalog (triggers, permissions, secrets per workflow), see [Workflows](Workflows). For where everything lives on disk, see [Repo-Architecture](Repo-Architecture).

## Source of truth

[`scripts/apply-branch-protection.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/apply-branch-protection.ps1) is the **only** source of truth for branch-protection settings on `main`. The script `PUT`s the full `branches/main/protection` payload via the GitHub API; whatever it sends overwrites whatever is in the GitHub UI. Treat the GitHub UI as read-only — if a setting needs to change, change the script and re-run it.

Re-run after any new required check has reported successfully on `main` at least once. GitHub rejects required-context strings that have never been seen on the branch.

```powershell
# Dry-run to inspect the payload before applying:
./scripts/apply-branch-protection.ps1 -DryRun

# Apply (defaults: 0 required reviewers, admin-enforced):
./scripts/apply-branch-protection.ps1
```

## Required PR status contexts

The contexts below are what currently block a merge to `main`. Each string must match the **rendered** check name exactly — including matrix parameters in parentheses. See the matrix-naming pitfall below.

| Required context | Source workflow | Job ID | Notes |
|------------------|-----------------|--------|-------|
| `lint` | [`html-css-lint.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/html-css-lint.yml) | `lint` | HTMLHint + Stylelint. Runs on every PR to `main`. |
| `lychee` | [`link-check.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/link-check.yml) | `lychee` | Link checker. Also runs on a weekly cron — failures auto-file a `link-rot` issue. |
| `analyze (javascript-typescript)` | [`codeql.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/codeql.yml) | `analyze` (matrix) | CodeQL. The matrix value `javascript-typescript` is part of the rendered check name and **must** be in the required-context string. |
| `scan` | [`gitleaks.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/gitleaks.yml) | `scan` | Secrets scan. |

Other settings enforced by the script:

- `required_linear_history: true` — squash or rebase merges only; no merge commits.
- `required_conversation_resolution: true` — every review thread must be resolved before merge.
- `enforce_admins: true` — admins included; nobody bypasses required checks silently.
- `allow_force_pushes: false`, `allow_deletions: false` — `main` cannot be force-pushed or deleted.
- `dismiss_stale_reviews: true` — new commits invalidate prior approvals.
- `required_approving_review_count: 0` — solo-dev default. Pass `-Reviewers 1` (or higher) to require approvals.

`build` (from `pages-deploy.yml`) and `playwright` (from `visual-regression.yml`) are **not** required. Both are listed in the script with comments explaining why; see the path-filter and Pages pitfalls below.

## Pages deploy contract

Publishing to <https://marcusjacobson.github.io/portfolio/> is owned exclusively by [`pages-deploy.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-deploy.yml), which delegates rendering to the reusable [`pages-build.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-build.yml).

| Aspect | Value |
|--------|-------|
| Trigger | `push` to `main`, plus `workflow_dispatch` for manual reruns. |
| Environment | `github-pages` (the deployment URL surfaces as the job's environment URL). |
| Permissions | `contents: read`, `pages: write`, `id-token: write` (OIDC for `actions/deploy-pages`). |
| Secrets | None. Uses `GITHUB_TOKEN` via OIDC. |
| Concurrency | `group: pages`, `cancel-in-progress: false` — in-flight deploys finish before the next starts, preventing torn artifacts. |
| Jobs | `build` calls `pages-build.yml` with `upload-pages-artifact: true` to render `_site/` and emit the special `github-pages` artifact; `deploy` consumes it via [`actions/deploy-pages`](https://github.com/actions/deploy-pages). |

Because `pages-deploy.yml` only fires on `push` to `main`, it never produces a status check on a PR. That is by design: the merge gates above already protect `main`, and Pages publishes after merge.

## Staging preview gate (PR-side)

[`pages-build.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-build.yml) runs on every PR to `main` and on `workflow_call` from the deploy pipeline. The PR-side run uploads the rendered site as a `site-preview` workflow artifact (14-day retention), enabling a hard merge gate:

- Rule: **no content PR is merged before the maintainer fetches the artifact via [`scripts/preview-pr.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/preview-pr.ps1) and clicks through the rendered site locally.** This is why PR-side rendering exists.
- The [`@publish-manager`](Agents) agent enforces this: it refuses to advise merge without preview confirmation. See [Agents](Agents) for the full handoff.
- The reusable workflow runs identical render steps in both the PR and deploy paths, so a green preview is a faithful representation of what will go live.

## Wiki deploy contract

Wiki content (this folder) is published by [`wiki-sync.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/wiki-sync.yml).

| Aspect | Value |
|--------|-------|
| Trigger | `push` to `main` with `paths: ['wiki/**', '.github/workflows/wiki-sync.yml']`, plus `workflow_dispatch`. |
| Direction | One-way: `wiki/` in this repo → `portfolio.wiki.git`. |
| Permissions | `contents: read`. |
| Secrets | `WIKI_SYNC_TOKEN` (falls back to `GITHUB_TOKEN`). |

Edits made directly on github.com to the wiki UI are **overwritten** on the next sync. Always edit `wiki/*.md` in the repo and open a PR.

## Pitfalls (read these before changing the required list)

### Matrix-job context naming

GitHub renders matrix-job status checks with the matrix parameters in parentheses. The CodeQL `analyze` job uses `strategy.matrix.language: [javascript-typescript]`, so the rendered check name is `analyze (javascript-typescript)`, **not** `analyze`. If the required-context string omits the parentheses, `gh pr merge --admin` fails with `Required status check "analyze" is expected.` and the PR is unmergeable even when CodeQL is green.

Rule: the required-context string must match the **rendered** check name, not the bare job id. Same goes for any future matrix workflow added to the required list.

### Path-filter + required-context deadlock

Workflows whose triggers use `paths:` filters (or `paths-ignore:`) only register a status check when a PR touches a matching path. If such a check is also in the required-contexts list, any PR that does not touch a matching path becomes **unmergeable** — the required check never reports.

Concrete examples in this repo:

- [`visual-regression.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/visual-regression.yml) is path-filtered to HTML/CSS/JS/`tests/`/`package.json`/the workflow itself. It is intentionally **not** required — a docs-only or workflow-only PR would otherwise deadlock.
- [`pages-deploy.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-deploy.yml) only triggers on `push` to `main`, so its `build` job never fires on a PR. It must not be required for that same reason; the script's commented-out `build` entry is a deliberate placeholder, not an oversight.

When considering whether to require a new check, answer two questions first:

1. Does the workflow run on **every** PR to `main` (no `paths:` filter, `pull_request` trigger present)?
2. Is the rendered check name stable (no matrix that could change) and already green on `main` at least once?

If either answer is "no", do not add it to the required list.

### `gh api` boolean encoding

`gh api ... -f strict=true` sends the string `"true"` and the GitHub API returns HTTP 422. The script avoids this by `ConvertTo-Json`-ing a hashtable with the boolean `$true` and piping the result via `--input -`. Stick to that pattern when extending the payload.

## Action pinning status

As of [PR #233](https://github.com/marcusjacobson/portfolio/pull/233) (2026-04-28), every action used in every workflow under [`.github/workflows/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/workflows) is pinned to a full 40-char commit SHA, with the major-tag version recorded in a trailing comment for human readability. This satisfies the `source:github-docs` action-pin lane in the maturity scan and matches the rule in [.github/instructions/workflows.instructions.md](https://github.com/marcusjacobson/portfolio/blob/main/.github/instructions/workflows.instructions.md).

The pinning is maintained automatically by Dependabot. The `dev-tooling` group in [`.github/dependabot.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/dependabot.yml) batches GitHub Actions bumps so each Dependabot PR replaces the SHA + comment together; merge them as-is unless the PR description flags a breaking change.

When adding a new action to a workflow, do **not** pin to a tag (`@v4`) — find the target release on the action's GitHub `releases` page and copy the full SHA from the release notes. Verify against the upstream release page before pinning; do not fabricate from memory.

## Cross-references

- [Workflows](Workflows) — the catalog of every workflow including the ones listed above.
- [Repo-Architecture](Repo-Architecture) — folder map; explains where `scripts/apply-branch-protection.ps1` and `.github/workflows/` live.
- [Boards](Boards) — the boards that surface CI failures and audit history for this repo.
- [Publishing-Workflow](Publishing-Workflow) — content-side flow for shipping changes to the live site.
