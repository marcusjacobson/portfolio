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

## Index of agent files

For the full list of specialized agents (request-intake, bug-intake, project-intake, issue-resolver, boards-worker, repo-ops, security-reviewer, publish-manager, repo-cleanup, maturity-scout, triage, wiki-sync, linkedin-sync, board-planner) see `.github/agents/` and the [Agents wiki page](wiki/Agents.md). All are chat-mode only — the hosted cloud agent does not load any of these agent files at runtime.

## Path-specific instruction files

Scoped guidance auto-attaches by `applyTo` glob in VS Code; in cloud runs, read them on demand:

- [.github/instructions/html-pages.instructions.md](.github/instructions/html-pages.instructions.md) — `*.html`
- [.github/instructions/wiki-content.instructions.md](.github/instructions/wiki-content.instructions.md) — `wiki/**`
- [.github/instructions/workflows.instructions.md](.github/instructions/workflows.instructions.md) — `.github/workflows/**`
