# Repo Architecture

This page explains how the [portfolio repo](https://github.com/marcusjacobson/portfolio) is organized and how a request travels from chat prompt to merged PR. The user's intent: "I want one page that shows where things live and how the agents, workflows, and boards fit together."

For the agents that drive the flow, see [Agents](Agents). For the workflows that gate it, see [Workflows](Workflows). For the boards that track it, see [Boards](Boards).

## Folder map

| Path | Purpose |
|------|---------|
| Root `*.html` | Browser-runnable portfolio pages: [`index.html`](https://github.com/marcusjacobson/portfolio/blob/main/index.html), [`ms_security_compass.html`](https://github.com/marcusjacobson/portfolio/blob/main/ms_security_compass.html), [`ms_security_roles.html`](https://github.com/marcusjacobson/portfolio/blob/main/ms_security_roles.html), [`ms_security_projects.html`](https://github.com/marcusjacobson/portfolio/blob/main/ms_security_projects.html), [`certification_strategy.html`](https://github.com/marcusjacobson/portfolio/blob/main/certification_strategy.html), [`skills_inventory.html`](https://github.com/marcusjacobson/portfolio/blob/main/skills_inventory.html). No build step — what's in the repo is what GitHub Pages serves. |
| [`.github/agents/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/agents) | Chat-mode agent specs (`*.agent.md`). One file per agent. See [Agents](Agents). |
| [`.github/prompts/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/prompts) | Slash-command prompts (`/publish-update`, `/secure-code-review`, etc.). |
| [`.github/instructions/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/instructions) | Scoped Copilot guidance auto-attached by `applyTo` glob. Covers HTML pages, wiki content, and workflows. |
| [`.github/workflows/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/workflows) | GitHub Actions: deploy, lint, link-check, CodeQL, gitleaks, visual regression, board automation, wiki sync, hygiene scout. See [Workflows](Workflows). |
| [`.github/ISSUE_TEMPLATE/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/ISSUE_TEMPLATE) | Issue templates used by intake agents and humans alike. |
| [`.github/copilot-instructions.md`](https://github.com/marcusjacobson/portfolio/blob/main/.github/copilot-instructions.md) | Repo-wide Copilot rules — including the always-on intake routing. |
| [`scripts/`](https://github.com/marcusjacobson/portfolio/tree/main/scripts) | PowerShell ops scripts. `apply-branch-protection.ps1` is the source of truth for required PR contexts. `gh/` holds Projects v2 helpers (`create-board.ps1`, `add-issue-to-board.ps1`, `bulk-close-stale.ps1`, `sync-labels.ps1`). |
| [`tests/`](https://github.com/marcusjacobson/portfolio/tree/main/tests) | Lychee config, Playwright config, and visual specs. `tests/visual/__snapshots__/` is regenerated only via `npm run test:visual:update` — never hand-edit. |
| [`wiki/`](https://github.com/marcusjacobson/portfolio/tree/main/wiki) | This wiki. Source of truth, mirrored one-way to the GitHub wiki by [`wiki-sync.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/wiki-sync.yml). Direct edits on github.com are overwritten on the next sync. |
| [`staging-inbox/`](https://github.com/marcusjacobson/portfolio/tree/main/staging-inbox) | Gitignored drop zone for the Claude project export. Nothing here ships to the live site. |
| [`package.json`](https://github.com/marcusjacobson/portfolio/blob/main/package.json) | Dev tooling only (`htmlhint`, `stylelint`, `lychee` runner, Playwright). The site itself has no runtime dependencies. |

## Request intake flow

Every feature/bug/chore-shaped chat request is routed through an intake agent before any mutation happens. The intake agent classifies the request, drafts an issue, picks a board, and waits for approval. The issue then drives a branch, a PR, and the gating checks listed in [Workflows](Workflows).

```mermaid
sequenceDiagram
    autonumber
    actor User as User (chat)
    participant Intake as @request-intake / @bug-intake / @project-intake
    participant GH as GitHub (Issues + Boards + Branch)
    participant Worker as @issue-resolver or human author
    participant CI as Required PR checks
    participant Pages as Pages + wiki sync

    User->>Intake: prompt ("add X", "Y is broken", "track project Z")
    Intake->>Intake: classify shape and pick board
    Intake->>User: propose issue draft + board home
    User-->>Intake: approve
    Intake->>GH: file issue, apply labels, add to board
    Worker->>GH: branch from main (issue-NNN/...)
    Worker->>GH: implement, lint, commit, push, open PR (Closes #NNN)
    CI-->>GH: lint / lychee / analyze (javascript-typescript) / scan
    Worker->>GH: squash-merge once required checks are green
    GH->>Pages: pages-deploy.yml ships HTML; wiki-sync.yml mirrors wiki/**
    Pages-->>User: live site + wiki updated
```

The intake-to-board mapping is documented in [Boards](Boards). The required-context list that gates step 7 lives in [`scripts/apply-branch-protection.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/apply-branch-protection.ps1) and is summarized in [Workflows](Workflows#required-pr-checks).

## Issue first, always

Default rule: **no commit lands on `main` without a tracking issue and a PR.** The issue is what the boards, the labels, the changelog, and the audit trail hang off. Even single-line content tweaks usually deserve an issue, because that's the only way the work shows up on a board.

The intake agents enforce this by drafting the issue *before* touching code. `@request-intake` will not open a branch until the user approves the proposed issue. `@issue-resolver` refuses to start without an explicit `#N`.

### Trivial-edit carveout

The intake step is skipped only when **all** of the following hold:

- The user names the target file and the exact change (e.g. "fix the typo on line 42 of `index.html`").
- The change is a typo, a single-line content tweak, or a comment edit.
- The change does not affect site behavior, accessibility, or security posture.

In that case the worker still opens a branch and a PR — direct pushes to `main` are blocked by branch protection — but does not file an issue. The PR description must explicitly call out "trivial edit, no issue" so the audit trail is honest. Anything larger goes back through intake.

The full carveout list (asking a question, mid-flow on an existing issue or PR, explicit `skip intake` / `just do it` overrides) is in [`.github/copilot-instructions.md`](https://github.com/marcusjacobson/portfolio/blob/main/.github/copilot-instructions.md). When in doubt, file the issue.

## Cross-references

- [Agents](Agents) — the chat agents that drive the intake-to-merge flow.
- [Workflows](Workflows) — the GitHub Actions that gate every PR and ship the result.
- [Boards](Boards) — the Projects v2 boards each intake variant feeds.
- [Terminology](Terminology) — Project (portfolio) vs Board (GitHub Projects v2).
- [GitHub-Pages-Publishing](GitHub-Pages-Publishing) — what `pages-deploy.yml` puts on the live site.
