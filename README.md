# Microsoft Security Architecture Portfolio

A static HTML portfolio site for Microsoft security architecture tools, frameworks, and certifications. No build step required — every page is a self-contained HTML file.

🔗 **Live site:** [https://marcusjacobson.github.io/portfolio/](https://marcusjacobson.github.io/portfolio/)

> **Terminology note:** "Project" means portfolio showcase work; "Board" means a GitHub Projects v2 board. See [wiki/Terminology.md](wiki/Terminology.md) for the full split.

## Pages

| Page | File | Description |
|------|------|-------------|
| Security Compass | [`index.html`](index.html) | Interactive compass for navigating the Microsoft security ecosystem — Entra ID, Defender, Purview, Sentinel, Zero Trust, and Azure Security domains |
| Security Roles Reference | [`ms_security_roles.html`](ms_security_roles.html) | Searchable, filterable reference for Microsoft Entra ID built-in security roles with permissions, scope, and use cases |
| Projects Portfolio | [`ms_security_projects.html`](ms_security_projects.html) | Portfolio of Microsoft security architecture engagements — Zero Trust deployments, SIEM migrations, DLP frameworks, and more |
| Certification Strategy | [`certification_strategy.html`](certification_strategy.html) | Structured roadmap for Microsoft security certifications (SC-900 through SC-100) with study strategy and progress tracking |

## Topics

`microsoft-security` · `github-pages` · `purview` · `defender` · `entra` · `zero-trust`

## Usage

Clone the repository and open any `.html` file directly in a browser — no server or build tool needed.


```bash
git clone https://github.com/marcusjacobson/portfolio.git
cd portfolio
open index.html   # macOS
# or: start index.html  (Windows)
```

## Hosting

The site is hosted via [GitHub Pages](https://pages.github.com/) using the modern **GitHub Actions** Pages source. Pushes to `main` deploy via [.github/workflows/pages-deploy.yml](.github/workflows/pages-deploy.yml), which calls the reusable [.github/workflows/pages-build.yml](.github/workflows/pages-build.yml) workflow to render the site (Last-updated stamps + CHANGELOG injection) before publishing.

## Staging preview (PR-side)

Every PR against `main` runs the same `pages-build.yml` workflow and uploads the rendered site as a `site-preview` artifact (14-day retention). Reviewers preview the **exact build that will deploy on merge** locally — no third-party hosting required:

```powershell
./scripts/preview-pr.ps1 -Pr <pr-number>
# downloads site-preview artifact to staging-inbox/pr-<N>/ and serves at http://localhost:8080/
```

[`@publish-manager`](.github/agents/publish-manager.agent.md) runs this script automatically and **refuses to recommend merge until you sign off on the rendered preview**. See [wiki/GitHub-Pages-Publishing.md](wiki/GitHub-Pages-Publishing.md) for the full flow.

## Quick start

1. Open the Claude "Portfolio" project, download the files into `staging-inbox/` (gitignored).
2. Run [scripts/migrate-from-claude.ps1](scripts/migrate-from-claude.ps1) `-DryRun` to preview, then again without `-DryRun` to copy.
3. `npm install` (one-time) so the linters and Playwright are available locally.
4. Open a feature branch, commit, push, open a PR — quality checks run automatically. Open the changed HTML files locally to review.
5. After all required checks have a green run on `main` at least once, run [scripts/apply-branch-protection.ps1](scripts/apply-branch-protection.ps1) to lock down direct pushes.

## Repo layout

| Path | Purpose |
|------|---------|
| `*.html` | The site. Served as-is by GitHub Pages. |
| [.github/workflows/](.github/workflows/) | CI: deploy, link/HTML/CSS/visual checks, CodeQL, gitleaks, wiki sync, labeler. |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) + [.github/instructions/](.github/instructions/) | Repo-wide and scoped Copilot guidance. |
| [.github/prompts/](.github/prompts/) | Slash-command tasks: `/publish-update`, `/secure-code-review`, `/triage-issue`, `/groom-backlog`. |
| [.github/agents/](.github/agents/) | Chat agents: `@publish-manager`, `@security-reviewer`, `@repo-ops`. See [wiki/Agents.md](wiki/Agents.md) for the full catalog. |
| [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/) + [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) | Templates for repeatable intake. |
| [.github/labels.yml](.github/labels.yml) | Canonical label set. Synced via [scripts/gh/sync-labels.ps1](scripts/gh/sync-labels.ps1). |
| [scripts/](scripts/) | PowerShell ops: migration, branch protection, gh CLI helpers. |
| [tests/](tests/) | Lychee link-check config, Playwright config, visual specs and committed snapshots. |
| [wiki/](wiki/) | Wiki-as-code source. Synced one-way to the GitHub wiki on push to `main`. |
| [.vscode/mcp.json](.vscode/mcp.json) | Workspace GitHub MCP server config (PAT prompted at runtime, never committed). |
| `staging-inbox/` | Gitignored drop zone for the Claude project export. |
| [`LICENSE`](LICENSE) | MIT License — terms under which the code and content may be reused. |
| [`SECURITY.md`](SECURITY.md) | How to report a security issue privately, plus what is in and out of scope. |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Issue intake, branch + PR workflow, local validation, and commit style. |
| [`.github/CODEOWNERS`](.github/CODEOWNERS) | Routes review requests to the maintainer for every path in the repo. |

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `pages-build.yml` | PR to `main` + `workflow_call` | Reusable build: renders site, uploads `site-preview` artifact for PR review and (when called by `pages-deploy`) the Pages deploy artifact. |
| `pages-deploy.yml` | push to `main` | Thin caller for `pages-build.yml` that promotes the build to production via `actions/deploy-pages`. |
| `link-check.yml` | PR + weekly cron | Lychee link checker; opens a `link-rot` issue on scheduled failures. |
| `html-css-lint.yml` | PR (paths) | `htmlhint` + `stylelint`. |
| `visual-regression.yml` | PR (paths) | Playwright snapshots across mobile/tablet/desktop. |
| `codeql.yml` | PR + push + weekly | Static analysis. |
| `gitleaks.yml` | PR + push | Blocks secrets. |
| `labeler.yml` | PR | Path-based auto-labeling from `.github/labeler.yml`. |
| `wiki-sync.yml` | push to `main` (paths: `wiki/**`) | Mirrors `wiki/` to the GitHub wiki. |

> **PR preview via artifact.** PRs publish the rendered site as a `site-preview` workflow artifact rather than a hosted URL. Run [`scripts/preview-pr.ps1`](scripts/preview-pr.ps1) to download and serve it locally — no third-party hosting required. The preview is bit-identical to what `pages-deploy.yml` will publish on merge.

## Local commands

```powershell
# Lint
npm run lint

# Visual tests
npm run test:visual
npm run test:visual:update   # accept new baselines

# Sync labels to GitHub
./scripts/gh/sync-labels.ps1 -DryRun

# Apply branch protection (after first green runs)
./scripts/apply-branch-protection.ps1 -DryRun
```

## Copilot usage

In VS Code chat:

- Type `/` and pick `publish-update`, `secure-code-review`, `triage-issue`, or `groom-backlog`.
- In the agent picker, choose `publish-manager`, `security-reviewer`, or `repo-ops`.
- The GitHub MCP server (defined in [.vscode/mcp.json](.vscode/mcp.json)) prompts for a PAT on first use; the token is never written to disk.

### Which agent for which task?

| Situation | Agent | Why |
|-----------|-------|-----|
| Routine page edit you have in your working tree (content tweak, layout fix, screenshot refresh) | [`@publish-manager`](.github/agents/publish-manager.agent.md) | Chat-only; runs `preview-pr.ps1` and refuses to recommend merge until you sign off on the rendered preview. Sees uncommitted local changes. |
| A scoped GitHub issue ready to ship end-to-end (branch → implement → PR → merge) | [`@issue-resolver`](.github/agents/issue-resolver.agent.md) | Synchronous, cloud-hardened. Use locally for orchestration; assign `@copilot` for unattended cloud runs. |
| New feature, page, or backlog idea raised in chat | [`@request-intake`](.github/agents/request-intake.agent.md) (or `@bug-intake` / `@project-intake` / `@cert-intake`) | Drafts the issue and routes to a board before implementation. |
| PR security review (XSS, secrets, supply-chain, workflow permissions) | [`@security-reviewer`](.github/agents/security-reviewer.agent.md) | Read-only diff review with repo-specific rules. |
| Drain a board column in batch | [`@boards-worker`](.github/agents/boards-worker.agent.md) | Loops `@issue-resolver` over board items. |
| Ad-hoc `gh` / Issues / Wiki / Labels work | [`@repo-ops`](.github/agents/repo-ops.agent.md) | Generic side-channel; use when nothing else fits. |

The staging-preview gate (`preview-pr.ps1`) is a `@publish-manager` responsibility. `@issue-resolver` runs in cloud-agent context where there is no human in the loop, so it cannot honor an interactive preview gate — its required green checks (lint, visual regression, link-check, `pages-build`) are the merge gate instead. See [wiki/Agents.md](wiki/Agents.md#decision-guide-local-or-hosted) for the full local-vs-hosted decision guide.

## Agents

This repo combines **local VS Code agents** (chat-mode personas under [.github/agents/](.github/agents/)) with the **GitHub Copilot cloud agent** for asynchronous, issue-driven work. Local agents handle interactive flows like publishing, security review, and intake triage; the cloud agent picks up labeled issues and opens PRs in the background. Work in flight is tracked on GitHub Projects v2 boards (Portfolio Roadmap, Bug Tracker, etc.).

- [Projects tab](https://github.com/marcusjacobson/portfolio/projects) — live boards for roadmap, bugs, and intake.
- [wiki/Agents.md](wiki/Agents.md) — full catalog of local and cloud agents with their tools and routing.
- [AGENTS.md (planned — issue #32)](https://github.com/marcusjacobson/portfolio/issues/32) — top-level cloud-agent guidance for the hosted Copilot agent.


## License

This project is licensed under the [MIT License](LICENSE).
