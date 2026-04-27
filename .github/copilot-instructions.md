# Repo conventions for Copilot

This is a static HTML portfolio site published to GitHub Pages. There is **no build step** for the site itself — every `*.html` page must be browser-runnable as-is from the repo root.

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

## Commit & PR style

- Commit messages: imperative subject, ≤72 chars; body explains *why* if non-obvious.
- PR title: same style as commit subject.
- PR description must include: summary, screenshots for visual changes, and a tested checklist.

## When the user asks to publish, review, or stage

- Publishing → use `/publish-update` prompt or the `@publish-manager` agent.
- Security review → use `/secure-code-review` prompt or `@security-reviewer` agent.
- Issues / Boards / Wiki ops → use `@repo-ops` (uses `gh` CLI and the GitHub MCP server).
- LinkedIn / profile / sync (audit drift between portfolio and LinkedIn) → use the `@linkedin-sync` agent. See [wiki/LinkedIn-Sync.md](../wiki/LinkedIn-Sync.md) for the input contract, gap categories, and run modes.
- Cleanup / sweep stale artefacts → use `/repo-cleanup` or the `@repo-cleanup` agent. Walks generated test outputs, `staging-inbox/` leftovers, merged local branches, stale `.copilot-tracking/` runs, orphaned scripts, and versioned root duplicates one item at a time. Read-only until per-item approval; `keep` produces a remediation so the same item isn't re-flagged.

## Request intake (always-on)

For **any new feature/bug/chore-shaped request** the user makes in this repo, before implementing, route it through the appropriate intake agent. The intake agent classifies the request, drafts a GitHub issue, checks for duplicates, picks a board home, and waits for explicit approval before mutating anything.

Bug-shaped requests (broken, regressed, or buggy behavior — "X is broken on mobile", "the modal scrolls past the viewport", a screenshot of something visibly wrong) route to `@bug-intake` first. It uses a bug-specific template (repro steps, expected/actual, environment, evidence) and routes to a dedicated bug-tracking board. Roadmap-shaped requests (a new portfolio project, capstone, or future security initiative — "add a roadmap item for X", "track a new capstone covering Y", "I want to plan a project for Z") route to `@project-intake`, which creates the item directly as a DraftIssue on the Security Portfolio Roadmap (board #13) and sets `Status=Todo` (plus Pillar, Tier, and Priority). The `Board` label and `board-autoadd` workflow handle real issues filed outside the agent. All other shapes — features, chores, docs, ambiguous asks — route to `@request-intake`. If a specialized intake (`@bug-intake` or `@project-intake`) decides the request isn't its shape, it defers back to `@request-intake`. See [wiki/Terminology.md](../wiki/Terminology.md) for the Project (portfolio) vs Board (GitHub Projects v2) distinction.

Skip intake when:

- The user is asking a question (answer directly).
- The user is mid-flow on an existing issue or PR (continue that flow).
- The user explicitly says `skip intake`, `just do it`, `quick fix`, or names a target file and asks for a direct edit.
- The change is a typo, a single-line content tweak, or a comment edit (use direct edit + branch + PR; no issue needed).

When in doubt, ask once: "Track this as an issue, or handle it inline?" Default to inline if the user already named a file and an action.
