# Repo conventions for Copilot

> **No build step.** Static HTML portfolio on GitHub Pages. Every `*.html` page must be browser-runnable as-is from the repo root. `npm` is dev-time tooling only (lint, link-check, visual regression). Do not invent a `build` step.

> **Two contexts.** This file is the always-on guide for **VS Code Copilot Chat**. The hosted **cloud agent** loads [AGENTS.md](../AGENTS.md) — that is the resolver-only contract. Local agents (`@*`) and slash-prompts (`/*`) only exist in chat.

## Hard rules

- **Never push directly to `main`.** Open a PR; required checks must be green.
- **Never edit `tests/visual/__snapshots__/` by hand.** Regenerate via `npm run test:visual:update`.
- **Pin Action versions** in `.github/workflows/*.yml` (major tag minimum; SHA for third-party).
- **`permissions:` is required** on every workflow. Default `contents: read`; elevate per job.
- **No secrets, PATs, or personal data** in the repo. `gitleaks` runs on every PR.
- All `<img>` tags need `alt` attributes (`htmlhint` enforces).
- Commit subject: imperative, ≤72 chars. PR description: summary + screenshots for visual changes + tested checklist.

## Verified commands

`npm ci` · `npm run lint` · `npm run test:visual` · `npm run test:visual:update` · `npx lychee --config tests/lychee.toml .`

## Where to look (load on demand, not preloaded)

| Context | File |
|---------|------|
| HTML page authoring | [.github/instructions/html-pages.instructions.md](instructions/html-pages.instructions.md) (auto-attaches to `*.html`) |
| Wiki authoring | [.github/instructions/wiki-content.instructions.md](instructions/wiki-content.instructions.md) (auto-attaches to `wiki/**`) |
| Workflow authoring | [.github/instructions/workflows.instructions.md](instructions/workflows.instructions.md) (auto-attaches to `.github/workflows/**`) |
| PowerShell ops scripts | [.github/instructions/scripts-powershell.instructions.md](instructions/scripts-powershell.instructions.md) (auto-attaches to `scripts/**/*.ps1`) |
| Playwright tests | [.github/instructions/tests-playwright.instructions.md](instructions/tests-playwright.instructions.md) (auto-attaches to `tests/**/*.ts`) |
| Agent / prompt / instruction authoring | [.github/agents/README.md](agents/README.md), [.github/prompts/README.md](prompts/README.md) |
| External best-practice URLs (MDN, OWASP, WCAG, GitHub docs, MS Learn) | [.github/instructions/grounding-sources.instructions.md](instructions/grounding-sources.instructions.md) |
| Cloud-agent contract | [AGENTS.md](../AGENTS.md) |
| Repo governance | [SECURITY.md](../SECURITY.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [.github/CODEOWNERS](CODEOWNERS), [LICENSE](../LICENSE) |
| Folder map, full architecture | [wiki/Repo-Architecture.md](../wiki/Repo-Architecture.md) |
| Full agent catalog + handoffs | [wiki/Agents.md](../wiki/Agents.md) |

## Request intake (always-on)

For any **new feature/bug/chore-shaped request**, route through an intake agent before implementing. The intake agent classifies, drafts an issue, picks a board, and waits for explicit approval. Skip intake for: pure questions, mid-flow on an existing issue/PR, the user says `skip intake` / `just do it` / `quick fix`, or a typo / single-line / comment edit on a named file.

| Shape | Agent | Notes |
|-------|-------|-------|
| Bug ("X is broken", screenshot of broken UI) | `@bug-intake` | Bug-tracking board; defers to `@request-intake` if not actually a bug. |
| New portfolio project / capstone / roadmap initiative | `@project-intake` | Drafts on Projects Roadmap board #13. After triage, `@projects-publishing` lands the card on `ms_security_projects.html`. |
| New certification / education-path goal | `@cert-intake` | Researches vendor exam (skills, prereqs, retirement). Files with `certification` label → board #2. |
| Anything else (feat / chore / docs / ambiguous) | `@request-intake` | Generic front door. Specialized intakes defer here if shape doesn't match. |

When in doubt, ask once: "Track this as an issue, or handle it inline?" Default to inline if the user named a file and an action.

## Other entry points

- Publish a portfolio update → `/publish-update` or `@publish-manager`. The publish-manager runs `./scripts/preview-pr.ps1 -Pr <N>` after PR checks go green and **refuses to recommend merge until you sign off on the rendered preview**. This is the canonical agent for routine page edits in your working tree.
- Security review of a PR → `/secure-code-review` or `@security-reviewer`.
- Issues / Boards / Wiki ops via `gh` → `@repo-ops`.
- Triage `needs-triage` queue → `@triage` (chat-only; one issue at a time; `apply` / `dismiss` / `edit:` / `cancel`).
- Sweep stale artefacts (test outputs, `staging-inbox/`, merged branches) → `/repo-cleanup` or `@repo-cleanup`.

See [wiki/Agents.md](../wiki/Agents.md) for the full catalog and handoff diagram.

## Staging preview (PR-side)

Every PR runs [`pages-build.yml`](workflows/pages-build.yml) (the same reusable workflow that powers production deploy) and uploads the rendered site as a `site-preview` artifact. To preview a PR locally before recommending merge, run `./scripts/preview-pr.ps1 -Pr <N>` — it downloads the artifact to `staging-inbox/pr-<N>/` and serves it on `http://localhost:8080/`. The preview is bit-identical to what `pages-deploy.yml` publishes on merge. `@publish-manager` automates this gate; reach for `@issue-resolver` (or the hosted `@copilot`) only when there is no uncommitted working-tree state to preview.
