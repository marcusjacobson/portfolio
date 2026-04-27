# Workflows

This page catalogs every GitHub Actions workflow under [`.github/workflows/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/workflows). The user's intent: "I want the wiki to cover *how* the repo was built — including the automation that ships, audits, and protects the site."

Workflows fall into four roles:

- **Publishing** — gets HTML and wiki content to the public surface.
- **Quality gates** — block PRs until lint, links, visuals, and security scans pass.
- **Boards & intake automation** — keeps GitHub Issues, Projects v2 boards, and labels in sync with [`@request-intake`](Agents) friends.
- **Hygiene scouting** — surfaces best-practice gaps as new issues.

See [Agents](Agents) for the chat agents that consume the issues and PRs these workflows produce. See [Boards](Boards) for the Projects v2 boards they feed.

## Required PR checks

Branch protection on `main` is applied by [`scripts/apply-branch-protection.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/apply-branch-protection.ps1). The required-context list there is the ground truth for which checks block a merge. Until a dedicated `wiki/Deployment-Rules.md` lands, the snapshot below is the canonical reference.

| Required context | Source workflow | Notes |
|------------------|-----------------|-------|
| `build` | [`pages-deploy.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-deploy.yml) | Currently in the required list, but `pages-deploy` only runs on `push` to `main`, so PRs never produce this context. Pending follow-up: drop it from the required list or add a PR trigger. See the matrix-context pitfall below. |
| `lint` | [`html-css-lint.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/html-css-lint.yml) | HTMLHint + Stylelint. Always required. |
| `lychee` | [`link-check.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/link-check.yml) | Lychee link checker. Always required. |
| `analyze (javascript-typescript)` | [`codeql.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/codeql.yml) | Matrix job. The required-context string **must** include the matrix value in parentheses. See pitfall below. |
| `scan` | [`gitleaks.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/gitleaks.yml) | Secrets scan. Always required. |

`playwright` from [`visual-regression.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/visual-regression.yml) is **advisory** until Linux baselines are committed under `tests/visual/__snapshots__/`. It is intentionally commented out in the branch-protection script.

### Matrix-job context naming pitfall

GitHub renders matrix-job status checks with the matrix parameters in parentheses. The CodeQL `analyze` job uses `strategy.matrix.language: [javascript-typescript]`, so the produced check name is `analyze (javascript-typescript)`, **not** `analyze`. If the required-context string omits the parentheses, `gh pr merge --admin` fails with `Required status check "analyze" is expected.` and PRs cannot merge even when the run is green.

The same rule applies to any future matrix workflow: the required-context string must match the **rendered** check name, not the bare job id.

A second pitfall worth flagging here: workflows with `paths:` filters (e.g. `visual-regression.yml`) cannot be required PR checks unless every PR touches a path that matches the filter. Otherwise the check never registers and the PR is unmergeable.

## Publishing

| Workflow | Triggers | Permissions | Secrets | Status check | Required context? |
|----------|----------|-------------|---------|--------------|-------------------|
| [`pages-deploy.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-deploy.yml) | `push` to `main`, `workflow_dispatch` | `contents: read`, `pages: write`, `id-token: write` | None (uses `GITHUB_TOKEN` for OIDC). | `build`, `deploy` | `build` is in the required list (see caveat above). |
| [`wiki-sync.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/wiki-sync.yml) | `push` to `main` (paths `wiki/**` or this file), `workflow_dispatch` | `contents: read` | `WIKI_SYNC_TOKEN` (falls back to `GITHUB_TOKEN`). | `sync` | No. One-way mirror from `wiki/` to the GitHub wiki repo — direct edits on github.com are overwritten on the next sync. |

## Quality gates (PR checks)

| Workflow | Triggers | Permissions | Secrets | Status check | Required context? |
|----------|----------|-------------|---------|--------------|-------------------|
| [`html-css-lint.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/html-css-lint.yml) | `pull_request` to `main`, `workflow_dispatch` | `contents: read` | None. | `lint` | **Yes.** |
| [`link-check.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/link-check.yml) | `pull_request` to `main`, weekly cron (Mon 07:00 UTC), `workflow_dispatch` | `contents: read`, `issues: write` | None. | `lychee` | **Yes.** Scheduled failures auto-file a `link-rot` issue. |
| [`codeql.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/codeql.yml) | `push`/`pull_request` to `main`, weekly cron (Tue 08:00 UTC) | `actions: read`, `contents: read`, `security-events: write` | None. | `analyze (javascript-typescript)` | **Yes** — see matrix pitfall above. |
| [`gitleaks.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/gitleaks.yml) | `pull_request`/`push` to `main`, `workflow_dispatch` | `contents: read` | None. | `scan` | **Yes.** |
| [`visual-regression.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/visual-regression.yml) | `pull_request` to `main` (path-filtered to HTML/CSS/JS/`tests/`/`package.json`/this workflow), `workflow_dispatch` | `contents: read`, `pull-requests: write` | None. | `playwright` | No (advisory until Linux baselines exist). |
| [`labeler.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/labeler.yml) | `pull_request_target` (`opened`, `synchronize`, `reopened`) | `contents: read`, `pull-requests: write` | None. | `label` | No. Applies path-based labels per `.github/labeler.yml`. |

## Boards & intake automation

These workflows feed the [Projects v2 boards](Boards). They run on `issues:` events and need a classic PAT (`BUG_PROJECT_TOKEN`) with `project` scope, because the default `GITHUB_TOKEN` cannot write user-owned Projects v2.

| Workflow | Triggers | Permissions | Secrets | Status check | Required context? |
|----------|----------|-------------|---------|--------------|-------------------|
| [`bug-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/bug-autoadd.yml) | `issues: [opened, labeled]` | `contents: read`, `issues: read` | `BUG_PROJECT_TOKEN` (classic PAT, `project` scope). | `add-to-project` | No. Adds `bug`-labeled issues to board #12 (Bug Tracker). |
| [`board-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/board-autoadd.yml) | `issues: [opened, labeled]` | `contents: read`, `issues: read` | `BUG_PROJECT_TOKEN`. | `add-to-project` | No. Adds `Board`-labeled issues to board #13 (Security Portfolio Roadmap). |
| [`board-membership-labeler.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/board-membership-labeler.yml) | `issues: [opened]` | `contents: read`, `issues: write` | `BUG_PROJECT_TOKEN` (probe step only). | `label-converted-issue` | No. Probes board #13 with the PAT, then applies labels with the default `GITHUB_TOKEN` because `BUG_PROJECT_TOKEN` lacks `repo`/`public_repo` scope. |
| [`maturity-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/maturity-autoadd.yml) | `issues: [opened, labeled]` | `contents: read`, `issues: read` | `BUG_PROJECT_TOKEN`. | `add-to-project` | No. Adds `source:repo-hygiene`, `source:github-docs`, or `source:wcag` issues to board #15 (Portfolio Maturity). |

The split-token pattern in `board-membership-labeler.yml` is intentional: `BUG_PROJECT_TOKEN` is a classic PAT scoped to `project` only, so calls like `addLabelsToLabelable` must run under the default `GITHUB_TOKEN` granted `issues: write` via the workflow's `permissions:` block. Do not widen `BUG_PROJECT_TOKEN`'s scope — it is shared across multiple workflows and broader scope expands the blast radius.

## Hygiene scouting

| Workflow | Triggers | Permissions | Secrets | Status check | Required context? |
|----------|----------|-------------|---------|--------------|-------------------|
| [`maturity-scan.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/maturity-scan.yml) | Weekly cron (Mon 14:00 UTC), `workflow_dispatch` (input: `max`, default 5) | `contents: read`, `issues: write` | `BUG_PROJECT_TOKEN` (for inline `gh project item-add` to board #15). | `scan` | No. Files repo-hygiene gap issues using templates under [`.github/workflows/templates/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/workflows/templates). See [Maturity-Scout](Maturity-Scout) for the chat-mode counterpart. |

`maturity-scan.yml` deliberately performs no live network fetches — every check is a deterministic file-existence probe in the checkout plus dedupe against the GitHub API. LLM-judgment checks live in the on-demand `@maturity-scout` chat agent.

### Heredoc indentation pitfall

Issue templates for `maturity-scan.yml` are stored as separate files under `.github/workflows/templates/` and substituted with `sed`. An earlier version embedded the template via a `cat <<EOF ... EOF` heredoc inside a `run: |` block scalar. A column-0 line inside the heredoc body terminated the YAML block scalar early, producing an `Invalid workflow file ... line N` error and a misleading `gh workflow run` HTTP 422 about a missing `workflow_dispatch` trigger. Future template authors should keep bodies in separate `*-issue-body.md` files rather than re-introducing inline heredocs.

## Cross-references

- [Agents](Agents) — chat agents that consume the issues and PRs these workflows produce.
- [Boards](Boards) — Projects v2 boards fed by the boards-automation workflows.
- [Maturity-Scout](Maturity-Scout) — the chat-mode counterpart to `maturity-scan.yml`.
- [GitHub-Pages-Publishing](GitHub-Pages-Publishing) — what `pages-deploy.yml` puts on the live site.
