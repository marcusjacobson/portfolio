# Repo conventions for Copilot

> **No build step.** This is a static HTML portfolio site published to GitHub Pages. Every `*.html` page must be browser-runnable as-is from the repo root. There is no bundler, no transpiler, no `npm run build` for the site itself. The `npm` toolchain (under `package.json`) is purely dev-time tooling for lint, link-check, and visual regression.

> **Two contexts, one repo.** This file is the canonical guide for **VS Code Copilot Chat** (interactive, has access to local agents, prompts, and slash-commands). The hosted **Copilot cloud (coding) agent** loads [AGENTS.md](../AGENTS.md) instead. When working as the cloud agent, follow [AGENTS.md](../AGENTS.md) — it is the smaller, resolver-only contract. Do not assume slash-prompts or named local agents are available in cloud runs.

## Site authoring

- Pages live at the repo root: `index.html`, `ms_security_compass.html`, `ms_security_roles.html`, `ms_security_projects.html`, `certification_strategy.html`, `skills_inventory.html`. Keep this filename scheme (no version suffixes).
- Inline CSS and JS are acceptable for self-contained pages; if you extract assets, place them under `assets/` and reference with relative paths.
- Every page must have `<!DOCTYPE html>`, `<html lang="en">`, a `<title>`, and a meta viewport tag.
- All `<img>` tags must have `alt` attributes (enforced by `htmlhint`).
- Prefer system fonts; if you load an external font, use `rel="preconnect"` and `display=swap`.
- Do not commit secrets, PATs, or personal data. `gitleaks` runs on every PR.

## Tooling layout

| Folder | Purpose |
|--------|---------|
| `AGENTS.md` (root) | Cloud-agent contract loaded by the hosted Copilot cloud agent on every run. Resolver-only: any assigned issue → branch + one PR. Triage stays in local chat. |
| `.github/workflows/` | CI: deploy, previews, link-check, lint, visual regression, CodeQL, gitleaks, wiki sync |
| `.github/instructions/` | Scoped Copilot guidance (auto-attaches by `applyTo`) |
| `.github/prompts/` | Slash-command tasks (publish, secure review, staging, triage) |
| `.github/agents/` | Specialized chat agents (publish-manager, security-reviewer, repo-ops) |
| `scripts/` | PowerShell ops scripts (migration, branch protection, gh CLI helpers) |
| `tests/` | Lychee config, Playwright config, visual specs and snapshots |
| `wiki/` | Wiki-as-code source. Synced one-way to the GitHub wiki by `wiki-sync.yml` |
| `staging-inbox/` | Gitignored drop zone for the Claude project export |

## Hard rules

- **Never edit `tests/visual/__snapshots__/` by hand.** Regenerate with `npm run test:visual:update`.
- **Never push directly to `main`.** Open a PR; checks must be green.
- **Pin Action versions** in `.github/workflows/*.yml`. Use major version tags (`@v4`) at minimum; SHAs preferred for third-party actions.
- **`permissions:` is required** on every workflow. Default to `contents: read` and elevate per job only as needed.

## Verified shell commands

These commands are known to work in both the local dev environment and the ephemeral cloud-agent runner (after `copilot-setup-steps` has primed Node 20 and dependencies):

| Command | Purpose |
|---------|---------|
| `npm ci` | Install dev dependencies (idempotent; required after `package-lock.json` changes). |
| `npm run lint` | Runs `htmlhint` against `*.html` and `stylelint` against `**/*.css`. |
| `npm run test:visual` | Playwright visual regression. Snapshots live in `tests/visual/__snapshots__/`. |
| `npm run test:visual:update` | Regenerate visual snapshots. The **only** sanctioned way to change them. |
| `npx lychee --config tests/lychee.toml .` | Local link-check (CI runs the same via `link-check.yml`). |

The cloud agent does not have a separate `npm run build` step because the site has no build. Do not invent one.

## When working as the cloud (hosted) agent

If you are running as the GitHub-hosted Copilot coding agent (assigned to an issue from the Agents tab or via `@copilot`), follow [AGENTS.md](../AGENTS.md) as the primary contract. Key cloud-agent specifics that override or narrow the rules above:

- **One issue → one branch → one PR.** Never bundle multiple issues into a single PR. Triage is **not** your job; if an issue is unclear, comment on it and stop.
- **Triage stays in local chat.** If you are assigned a `needs-triage` issue, the maintainer triaged it in local chat first and removed that label before assigning you. Do not edit triage labels yourself.
- **Budget discipline.** Expect roughly one premium request per task. If the first attempt fails, diagnose and try a different approach. Do not retry the same approach more than twice — comment on the issue with the blocker and stop.
- **No interactive prompts.** You cannot ask the maintainer questions mid-run. If you need confirmation (destructive action, ambiguous AC, schema change), post a comment and stop instead of guessing.
- **Local agents and slash-prompts are not available** in cloud runs. References in this file to `@publish-manager`, `@security-reviewer`, `@repo-ops`, `/publish-update`, `/secure-code-review`, etc. only apply in VS Code chat.

## Commit & PR style

- Commit messages: imperative subject, ≤72 chars; body explains *why* if non-obvious.
- PR title: same style as commit subject.
- PR description must include: summary, screenshots for visual changes, and a tested checklist.

## When the user asks to publish, review, or stage

- Publishing → use `/publish-update` prompt or the `@publish-manager` agent.
- Security review → use `/secure-code-review` prompt or `@security-reviewer` agent.
- Issues / Boards / Wiki ops → use `@repo-ops` (uses `gh` CLI and the GitHub MCP server).
- Triage of `needs-triage` issues (confirm for work or dismiss) → use the `@triage` agent in local Copilot Chat. Operates one issue at a time. Presents a proposal and waits for `apply` / `dismiss` / `edit:` / `cancel`. Triage is **chat-only**; the hosted cloud agent does not run triage.
- Cleanup / sweep stale artefacts → use `/repo-cleanup` or the `@repo-cleanup` agent. Walks generated test outputs, `staging-inbox/` leftovers, merged local branches, stale `.copilot-tracking/` runs, orphaned scripts, and versioned root duplicates one item at a time. Read-only until per-item approval; `keep` produces a remediation so the same item isn't re-flagged.

## Request intake (always-on)

For **any new feature/bug/chore-shaped request** the user makes in this repo, before implementing, route it through the appropriate intake agent. The intake agent classifies the request, drafts a GitHub issue, checks for duplicates, picks a board home, and waits for explicit approval before mutating anything.

Bug-shaped requests (broken, regressed, or buggy behavior — "X is broken on mobile", "the modal scrolls past the viewport", a screenshot of something visibly wrong) route to `@bug-intake` first. It uses a bug-specific template (repro steps, expected/actual, environment, evidence) and routes to a dedicated bug-tracking board. New-project-shaped requests (a new portfolio project, capstone, or future security initiative — "onboard a new project for X", "track a new capstone covering Y", "I want to plan a project for Z") route to `@project-intake`, which asks clarifying questions about the project (technologies, purpose, where to ground research) and files a real issue with the `project` + `needs-triage` labels so the auto-add workflows place it on both the Projects Roadmap (board #13) and the Triage Queue (board #19). Once triaged and ready to publicise, `@projects-publishing` lands the card on `ms_security_projects.html`. Cert-shaped requests (a new certification or education-path goal — "study for SC-401", "track CompTIA CySA+ for Q3", "plan an exam path for AZ-500 → SC-500") route to `@cert-intake`, which researches the vendor exam requirements (skills outline, prerequisites, retirement notices) and files a real issue with the `certification` label so the tag-routing workflow places it on the Certification/Education Path board (#2); the agent then sets the board's Vendor, Exam Code, Start, and End fields. The `Board` label and `board-autoadd` workflow handle real issues filed outside the agent. All other shapes — features, chores, docs, ambiguous asks — route to `@request-intake`. If a specialized intake (`@bug-intake`, `@project-intake`, or `@cert-intake`) decides the request isn't its shape, it defers back to `@request-intake`. See [wiki/Terminology.md](../wiki/Terminology.md) for the Project (portfolio) vs Board (GitHub Projects v2) distinction.

Skip intake when:

- The user is asking a question (answer directly).
- The user is mid-flow on an existing issue or PR (continue that flow).
- The user explicitly says `skip intake`, `just do it`, `quick fix`, or names a target file and asks for a direct edit.
- The change is a typo, a single-line content tweak, or a comment edit (use direct edit + branch + PR; no issue needed).

When in doubt, ask once: "Track this as an issue, or handle it inline?" Default to inline if the user already named a file and an action.
