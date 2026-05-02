# Workflows

This page catalogs every GitHub Actions workflow under [`.github/workflows/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/workflows). The user's intent: "I want the wiki to cover *how* the repo was built — including the automation that ships, audits, and protects the site."

Workflows fall into four roles:

- **Publishing** — gets HTML and wiki content to the public surface.
- **Quality gates** — block PRs until lint, links, visuals, and security scans pass.
- **Boards & intake automation** — keeps GitHub Issues, Projects v2 boards, and labels in sync with [`@request-intake`](Agents) friends.
- **Hygiene scouting** — surfaces best-practice gaps as new issues.

See [Agents](Agents) for the chat agents that consume the issues and PRs these workflows produce. See [Boards](Boards) for the Projects v2 boards they feed.

### Action pinning

Every `uses:` reference across all workflows is pinned to a full 40-character commit SHA with the human-readable tag retained as a trailing comment (e.g. `actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2`). This was completed in PR #233 to satisfy CodeQL `actions/unpinned-tag` (mirroring [GitHub's hardening guidance](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)). Updates are batched through the `dev-tooling` group in [`.github/dependabot.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/dependabot.yml). When adding a new action, pin to a SHA from day one — do not introduce floating tags.

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

During the `build` step, `pages-deploy.yml` does two pre-flight content transforms before uploading the Pages artifact (PR #182):

- **Render `CHANGELOG.md` into `changelog.html`** via `pandoc --from=gfm --to=html5` plus [`scripts/render_changelog.py`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/render_changelog.py). The rendered body is injected between the `<!-- CHANGELOG_BODY -->` markers; the leading `# Changelog` h1 is stripped because the page header already provides it.
- **Inject per-page `Last updated` timestamps** by replacing the `<!-- LAST_UPDATED -->` placeholder in each root HTML page with `git log -1 --format=%cs` (commit-date, `YYYY-MM-DD`) for that file. This is why the workflow uses `actions/checkout@... with: fetch-depth: 0`.

Neither transform is committed back to the repo — they exist only inside the deployed artifact.

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
| [`tag-routing-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/tag-routing-autoadd.yml) | `issues: [opened, labeled]` | `contents: read`, `issues: read` | `BUG_PROJECT_TOKEN`. | `add-to-project` (one job per tag) | No. Routes `compass` → #9, `certification` → #2, `wiki` → #16, `maturity` → #15, `project` → #13. Each tag has its own job because matrix-level `if:` referencing `matrix.*` is rejected as an invalid workflow file. |
| [`triage-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/triage-autoadd.yml) | `issues: [opened, labeled]` | `contents: read`, `issues: read` | `BUG_PROJECT_TOKEN`. | `add-to-project` | No. Adds `needs-triage` issues to board #19 (Triage Queue) so the queue stays in sync with the label. [`@triage`](Agents) removes them on disposition. |
| [`board-membership-labeler.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/board-membership-labeler.yml) | `issues: [opened]` | `contents: read`, `issues: write` | `BUG_PROJECT_TOKEN` (probe step only). | `label-converted-issue` | No. Probes board #13 with the PAT, then applies labels with the default `GITHUB_TOKEN` because `BUG_PROJECT_TOKEN` lacks `repo`/`public_repo` scope. |
| [`maturity-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/maturity-autoadd.yml) | `issues: [opened, labeled]` | `contents: read`, `issues: read` | `BUG_PROJECT_TOKEN`. | `add-to-project` | No. Adds `source:repo-hygiene`, `source:github-docs`, or `source:wcag` issues to board #15 (Portfolio Maturity). |

The split-token pattern in `board-membership-labeler.yml` is intentional: `BUG_PROJECT_TOKEN` is a classic PAT scoped to `project` only, so calls like `addLabelsToLabelable` must run under the default `GITHUB_TOKEN` granted `issues: write` via the workflow's `permissions:` block. Do not widen `BUG_PROJECT_TOKEN`'s scope — it is shared across multiple workflows and broader scope expands the blast radius.

## Hygiene scouting

| Workflow | Triggers | Permissions | Secrets | Status check | Required context? |
|----------|----------|-------------|---------|--------------|-------------------|
| [`maturity-scan.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/maturity-scan.yml) | Weekly cron (Mon 14:00 UTC), `workflow_dispatch` (inputs: `max` default 5, `enable_axe_pw` default false) | `contents: read`, `issues: write` | `BUG_PROJECT_TOKEN` (for inline `gh project item-add` to board #15). | `scan` | No. Files repo-hygiene gap issues using templates under [`.github/workflows/templates/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/workflows/templates). See [Maturity-Scout](Maturity-Scout) for the chat-mode counterpart. |
| [`wiki-sync-cron.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/wiki-sync-cron.yml) | Weekly cron (Mon 13:00 UTC), `workflow_dispatch` (input: `force`, default `false`) | `contents: read`, `issues: write`, `pull-requests: write` | None (uses default `GITHUB_TOKEN`). Gated by repo variable `WIKI_SYNC_CRON_ENABLED`. | `file-tracker` | No. Files (or refreshes) an `agent:wiki-sync` tracker issue prompting a maintainer to run `/wiki-sync-run`. Body rendered from [`.github/workflows/templates/wiki-sync-cron-issue-body.md`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/templates/wiki-sync-cron-issue-body.md). |

`maturity-scan.yml` deliberately performs no live network fetches — every check is a deterministic file-existence probe in the checkout plus dedupe against the GitHub API. LLM-judgment checks live in the on-demand `@maturity-scout` chat agent. The workflow now files gaps from multiple producers in a single run:

- **Repo-hygiene file probes** (`source:repo-hygiene`) — the original deterministic checks.
- **Branch-protection drift** (issue #256) — compares the live `gh api repos/.../branches/main/protection` payload against the desired shape declared in [`scripts/apply-branch-protection.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/apply-branch-protection.ps1) and files at most one drift issue per run.
- **Label drift** (issue #261) — compares the live label set against [`scripts/gh/sync-labels.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/gh/sync-labels.ps1).
- **GitHub-docs probes** (`source:github-docs`, issue #259) — deterministic checks against `.github/` conventions documented at docs.github.com.
- **WCAG / axe-core/cli scan** (`source:wcag`, issue #263, #264) — Option B: serves the site with `http-server` and runs `@axe-core/cli` against each public page.
- **WCAG / axe-core/playwright scan** (`source:wcag`, issue #265) — Option C: opt-in via the `enable_axe_pw` input. Disabled by default to avoid double-filing alongside Option B.

All producers share the same `MAX` budget (default 5; `workflow_dispatch` input). When the budget is exhausted in an earlier producer, later producers short-circuit so the run never files more than `MAX` issues per execution.

`wiki-sync-cron.yml` is disabled by default: the `file-tracker` job only runs when the repo variable `WIKI_SYNC_CRON_ENABLED` is set to `"1"`, or when a maintainer dispatches it with `force=true`. CI cannot drive Copilot Chat directly, so the workflow's only output is the tracker issue itself — the `/wiki-sync-run` orchestration (`@wiki-sync` → `@request-intake` → `@board-planner`) runs in chat and closes the tracker when the sweep is done.

### Heredoc indentation pitfall

Issue templates for `maturity-scan.yml` are stored as separate files under `.github/workflows/templates/` and substituted with `sed`. An earlier version embedded the template via a `cat <<EOF ... EOF` heredoc inside a `run: |` block scalar. A column-0 line inside the heredoc body terminated the YAML block scalar early, producing an `Invalid workflow file ... line N` error and a misleading `gh workflow run` HTTP 422 about a missing `workflow_dispatch` trigger. Future template authors should keep bodies in separate `*-issue-body.md` files rather than re-introducing inline heredocs.

## Hosted-agent support

| Workflow | Triggers | Permissions | Secrets | Status check | Required context? |
|----------|----------|-------------|---------|--------------|-------------------|
| [`copilot-setup-steps.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/copilot-setup-steps.yml) | `workflow_dispatch`, `push`/`pull_request` to `main` (path-filtered to itself) | `contents: read` | None. | `copilot-setup-steps` | No. Defines the toolchain (`actions/setup-node`, `npm ci`) the GitHub-hosted Copilot coding agent provisions before each task run. The path filter keeps the job from running on unrelated PRs. See [`AGENTS.md`](https://github.com/marcusjacobson/portfolio/blob/main/AGENTS.md) for the cloud-agent contract. |

## Cross-references

- [Agents](Agents) — chat agents that consume the issues and PRs these workflows produce.
- [Boards](Boards) — Projects v2 boards fed by the boards-automation workflows.
- [Maturity-Scout](Maturity-Scout) — the chat-mode counterpart to `maturity-scan.yml`.
- [GitHub-Pages-Publishing](GitHub-Pages-Publishing) — what `pages-deploy.yml` puts on the live site.
