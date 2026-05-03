# AGENTS.md — guidance for the hosted Copilot cloud agent

This file is loaded automatically by the GitHub Copilot cloud (coding) agent when it runs against this repository. Keep it brief; it is loaded into every agent run's context.

For VS Code Copilot Chat conventions, the canonical source remains [.github/copilot-instructions.md](.github/copilot-instructions.md) and the path-scoped files under [.github/instructions/](.github/instructions/). This file summarizes — it does not duplicate.

## What this repo is

- Static HTML portfolio site published to GitHub Pages. **No build step** for the site.
- Pages live at the repo root: `index.html`, `ms_security_compass.html`, `ms_security_roles.html`, `ms_security_projects.html`, `certification_strategy.html`, `skills_inventory.html`. Keep the filename scheme; no version suffixes.
- Tooling layout, intake/triage flow, agent and prompt indexes: see [.github/copilot-instructions.md](.github/copilot-instructions.md).

## Hard rules (do not break)

- **Never push directly to `main`.** Always work on a branch and open a PR. Required checks must be green.
- **Never edit `tests/visual/__snapshots__/` by hand.** Regenerate with `npm run test:visual:update`.
- **Pin Action versions** in `.github/workflows/*.yml` (major tag minimum; SHA preferred for third-party).
- **`permissions:` is required** on every workflow. Default to `contents: read` and elevate per job.
- **No secrets, PATs, or personal data** in the repo. `gitleaks` runs on every PR.
- All `<img>` tags need `alt` attributes (`htmlhint` enforces this).

## Commands

- Lint: `npm run lint` (runs `htmlhint` + `stylelint`).
- Visual regression: `npm run test:visual` (update snapshots: `npm run test:visual:update`).
- Link check: configured in `tests/lychee.toml`; runs in CI via `Link Check/lychee`.

## Staging preview (informational — not a cloud-agent step)

Every PR runs `.github/workflows/pages-build.yml` and uploads the rendered site as a `site-preview` artifact. Maintainers preview that artifact locally via `scripts/preview-pr.ps1` before merging routine page changes. The cloud agent does **not** run the preview script — it has no interactive surface to gate merge on, and the required PR checks (`pages-build`, lint, visual regression, link-check) are the merge gate for cloud-agent PRs. Just make sure your PR's `pages-build` check is green; the maintainer will preview the artifact before merging.

## Commit and PR style

- Commit subject: imperative, ≤72 chars. Body explains *why* if non-obvious.
- PR title: same style as commit subject.
- PR description: summary, screenshots for visual changes, tested checklist.

## Cloud-agent contract

When you are assigned to an issue, follow the **resolver flow**: read the issue body, branch, implement, lint, commit, and open **one PR per issue**. One issue → one PR.

Triage of `needs-triage` issues happens **in the maintainer's local Copilot Chat**, not in the cloud agent. If a maintainer wants you to take a `needs-triage` issue, they will first triage it in chat (which removes `needs-triage` and adds the appropriate routing label) and then assign you. Do not try to triage labels yourself.

## Budget note

Expect roughly **one premium request per task**. If your first attempt fails:

- Diagnose, then try a different approach.
- **Do not retry the same approach more than twice.** If the second attempt fails the same way, post a comment on the issue explaining the blocker and stop. The maintainer will route the issue elsewhere or refine scope.

## MCP allow-list and firewall posture

The cloud agent is allowed to call only the MCP servers explicitly listed below. Any tool not on this list is out of scope for an autonomous run; if a task appears to require one, comment on the issue and stop instead of guessing.

**Approved MCP servers (default-on, do not remove):**

- **GitHub MCP** — issue/PR/file operations on this repo. Use this for any read or write that has a `gh` CLI equivalent.
- **Playwright MCP** — browser automation for `tests/visual/`. Used by visual regression; do not invoke for general scraping.

**Not approved without re-review** (do not enable, even if the repo settings UI offers them):

- Any MCP server that touches secrets, credentials, or the keychain.
- Any MCP server that mutates infrastructure (Azure, AWS, GCP, Kubernetes, Terraform Cloud, etc.).
- Any MCP server that calls third-party APIs (Slack, Jira, Stripe, social media, AI providers other than the GitHub-hosted model).
- Any MCP server that executes arbitrary shell on a remote host.

If a maintainer wants to add a new server to this list, the change goes through the normal PR flow against this file *and* repo Settings → Copilot → MCP servers. Both must agree.

**Firewall posture:**

- The integrated GitHub-managed firewall stays **ON** (the default). The cloud agent runs on GitHub-hosted ephemeral runners only; we do not use self-hosted runners and have no need to whitelist additional egress targets.
- If a task seems to need outbound access beyond the default allow-list (e.g., fetching from an internal mirror, calling a private artifact feed), comment on the issue and stop. Do not edit firewall rules from inside an agent run.

Reference: [Extend Copilot coding agent with MCP](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/extend-cloud-agent-with-mcp).

## Index of agent files

For the full list of specialized agents (request-intake, bug-intake, project-intake, issue-resolver, boards-worker, repo-ops, security-reviewer, publish-manager, repo-cleanup, maturity-scout, triage, wiki-sync, board-planner) see `.github/agents/` and the [Agents wiki page](wiki/Agents.md). All are chat-mode only — the hosted cloud agent does not load any of these agent files at runtime.

## Path-specific instruction files

Scoped guidance auto-attaches by `applyTo` glob in VS Code; in cloud runs, read them on demand:

- [.github/instructions/html-pages.instructions.md](.github/instructions/html-pages.instructions.md) — `*.html`
- [.github/instructions/wiki-content.instructions.md](.github/instructions/wiki-content.instructions.md) — `wiki/**`
- [.github/instructions/workflows.instructions.md](.github/instructions/workflows.instructions.md) — `.github/workflows/**`
