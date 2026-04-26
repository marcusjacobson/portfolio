# Microsoft Security Architecture Portfolio

A static HTML portfolio site for Microsoft security architecture tools, frameworks, and certifications. No build step required — every page is a self-contained HTML file.

🔗 **Live site:** [https://marcusjacobson.github.io/portfolio/](https://marcusjacobson.github.io/portfolio/)

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

The site is hosted via [GitHub Pages](https://pages.github.com/) using the modern **GitHub Actions** Pages source. Pushes to `main` deploy via [.github/workflows/pages-deploy.yml](.github/workflows/pages-deploy.yml).

## Quick start

1. Open the Claude "Portfolio" project, download the files into `staging-inbox/` (gitignored).
2. Run [scripts/migrate-from-claude.ps1](scripts/migrate-from-claude.ps1) `-DryRun` to preview, then again without `-DryRun` to copy.
3. `npm install` (one-time) so the linters and Playwright are available locally.
4. Open a feature branch, commit, push, open a PR — the preview URL is auto-commented on the PR.
5. After all required checks have a green run on `main` at least once, run [scripts/apply-branch-protection.ps1](scripts/apply-branch-protection.ps1) to lock down direct pushes.

## Repo layout

| Path | Purpose |
|------|---------|
| `*.html` | The site. Served as-is by GitHub Pages. |
| [.github/workflows/](.github/workflows/) | CI: deploy, PR previews, link/HTML/CSS/visual checks, CodeQL, gitleaks, wiki sync, labeler. |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) + [.github/instructions/](.github/instructions/) | Repo-wide and scoped Copilot guidance. |
| [.github/prompts/](.github/prompts/) | Slash-command tasks: `/publish-update`, `/secure-code-review`, `/stage-preview`, `/triage-issue`, `/groom-backlog`. |
| [.github/agents/](.github/agents/) | Chat agents: `@publish-manager`, `@security-reviewer`, `@repo-ops`. |
| [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/) + [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) | Templates for repeatable intake. |
| [.github/labels.yml](.github/labels.yml) | Canonical label set. Synced via [scripts/gh/sync-labels.ps1](scripts/gh/sync-labels.ps1). |
| [scripts/](scripts/) | PowerShell ops: migration, branch protection, gh CLI helpers. |
| [tests/](tests/) | Lychee link-check config, Playwright config, visual specs and committed snapshots. |
| [wiki/](wiki/) | Wiki-as-code source. Synced one-way to the GitHub wiki on push to `main`. |
| [.vscode/mcp.json](.vscode/mcp.json) | Workspace GitHub MCP server config (PAT prompted at runtime, never committed). |
| `staging-inbox/` | Gitignored drop zone for the Claude project export. |

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `pages-deploy.yml` | push to `main` | Builds and deploys the site via the modern Pages Actions flow. |
| `pr-preview.yml` | PR open/sync/close | Pushes each PR to a `pr-N/` folder on the `gh-pages-previews` branch and comments the URL on the PR. |
| `link-check.yml` | PR + weekly cron | Lychee link checker; opens a `link-rot` issue on scheduled failures. |
| `html-css-lint.yml` | PR (paths) | `htmlhint` + `stylelint`. |
| `visual-regression.yml` | PR (paths) | Playwright snapshots across mobile/tablet/desktop. |
| `codeql.yml` | PR + push + weekly | Static analysis. |
| `gitleaks.yml` | PR + push | Blocks secrets. |
| `labeler.yml` | PR | Path-based auto-labeling from `.github/labeler.yml`. |
| `wiki-sync.yml` | push to `main` (paths: `wiki/**`) | Mirrors `wiki/` to the GitHub wiki. |

> **PR preview hosting note.** GitHub Pages can only serve from one source. With `pages-deploy.yml` set to "GitHub Actions" source, the `gh-pages-previews` branch is **not** auto-served. Two options:
>
> 1. **Recommended (single repo, single host):** switch Pages source to "Deploy from a branch" (`main` root for production, plus `gh-pages-previews` for previews via a custom subpath strategy), OR
> 2. Host previews on a second target (Cloudflare Pages, Netlify Drop, a sibling repo). The `pr-preview.yml` workflow's branch-push step can be retargeted with minor edits.
>
> Decide before applying branch protection so the required checks list matches reality.

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

- Type `/` and pick `publish-update`, `secure-code-review`, `stage-preview`, `triage-issue`, or `groom-backlog`.
- In the agent picker, choose `publish-manager`, `security-reviewer`, or `repo-ops`.
- The GitHub MCP server (defined in [.vscode/mcp.json](.vscode/mcp.json)) prompts for a PAT on first use; the token is never written to disk.

