# Maturity Scout

`@maturity-scout` audits this repository and the live portfolio against current external best-practice sources, then surfaces tracked work onto the **Portfolio Maturity** board (#15). It is the audit counterpart to `@request-intake`: instead of waiting for the user to notice a gap, it goes looking for them.

The agent is read-only by default. It never files an issue, attaches to a board, or edits a label without explicit user approval in the same chat turn — same contract as every other intake-style agent in this repo.

A companion weekly workflow (`.github/workflows/maturity-scan.yml`) runs the deterministic subset on a schedule and files candidates with the `needs-triage` label so the user can sweep them later from chat.

## When to use it

Reach for `@maturity-scout` when you want to:

- Run a one-off audit against a specific source ("scan against MS Learn", "scan repo hygiene").
- Refresh the Portfolio Maturity board after publishing a new portfolio page or claim.
- Sweep the latest weekly run and triage what the workflow filed.

Skip it when:

- You already know the gap — file the issue directly through `@request-intake` or hand it to `@issue-resolver`.
- You want to stand up a *new* board — that's `@board-planner`.
- You want to drain an existing board — that's `@boards-worker`.

## Sources in scope

| Source label | What it covers |
|---|---|
| `source:ms-learn` | Microsoft Learn pages for the security technologies actively claimed on the portfolio: Defender for Cloud, Entra ID, Sentinel, Purview, and the Azure security baseline. Scope tracks the live pages `ms_security_*.html`, `skills_inventory.html`, and `certification_strategy.html`. |
| `source:github-docs` | GitHub docs for Actions hardening, Pages, Projects v2, branch protection, CodeQL, gitleaks, dependency review, secret scanning, and repo settings. |
| `source:owasp` | OWASP Top 10 and ASVS controls applicable to a static HTML site — XSS, CSP, SRI, link-target hardening, mixed content. |
| `source:wcag` | WCAG 2.2 AA success criteria for the live portfolio pages. |
| `source:repo-hygiene` | GitHub-recommended community-health files, Dependabot, license, branch-protection completeness, and similar repo metadata. |

The five `source:*` labels are defined in [`.github/labels.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/labels.yml) and synced via `scripts/gh/sync-labels.ps1`.

## Filed-issue shape

Every issue the agent (or workflow) files has exactly four sections:

1. `## Source` — URL plus a 1–2 sentence excerpt.
2. `## Why it matters` — plain-language statement of the gap and why fixing it raises the maturity bar.
3. `## Suggested change` — short paragraph or bullet list naming the specific file or page to change.
4. `## Acceptance criteria` — 1–3 checkbox items.

Labels: `needs-triage`, exactly one `source:*` value, `Board` (chat-mode only — the workflow attaches to board #15 directly to avoid accidentally hitting board #13), and any applicable `area:*` label that already exists in `gh label list`. Project field defaults: `Status=Backlog`, `Priority=p2`, `Source=<MS Learn|GitHub Docs|OWASP|WCAG|Repo Hygiene>`.

## Dedupe rules

A candidate is suppressed (and reported under `Suppressed (dedupe)`) when any of the following matches an existing item:

- Open issue with ≥70% topical overlap on title + body keywords.
- Issue closed as completed within the last 90 days with ≥70% overlap.
- Any item (open or closed) on the Portfolio Maturity board (#15) with ≥70% overlap.

Topical overlap requires:

1. Same `source:*` label.
2. ≥3 distinguishing keywords match (no stop-words; "Azure" and "GitHub" alone don't count).
3. Same affected file or page.

The user can override a suppression by replying `edit <n>: <changes>` and the agent will re-print and re-ask.

## Weekly automation contract

The `.github/workflows/maturity-scan.yml` workflow runs on:

- `workflow_dispatch` — for manual smoke tests.
- A weekly cron (`0 14 * * 1` — Mondays at 14:00 UTC).

What it does:

- Scope is restricted to `source:repo-hygiene`, `source:github-docs`, and `source:wcag`. The other sources require LLM judgment for relevance and dedupe and stay in on-demand chat mode.
- `source:github-docs` v1 covers the action SHA-pin audit only — it scans every `.github/workflows/*.yml` file and files **one consolidated issue** per run when any `uses:` ref is not pinned to a 40-character commit SHA. Other github-docs checks (CODEOWNERS shape, branch-protection doc completeness) remain on-demand under `@maturity-scout` until added in a follow-up.
- `source:wcag` v1 covers three regex-only static checks across the six top-level `*.html` portfolio pages: `html-has-lang` (WCAG 3.1.1), `link-name` (WCAG 4.1.2), and `heading-order` (WCAG 1.3.1). Each rule files at most one consolidated issue per run, listing every page that fails. Broader DOM-aware coverage — color contrast, landmark/region rules, full WCAG 2.2 AA — is tracked in #126 (`@axe-core/cli`) and #127 (Playwright + axe-core), and stays out of this v1 scan by design.
- Runs deterministic file-existence checks against the checkout (no live external fetches).
- Performs the same dedupe pass against open issues and board items via `gh`.
- Files each surviving candidate with `needs-triage`, the matching `source:*` label, and the matching `area:*` label.
- Uses `actions/add-to-project` (pinned by SHA) with the shared `BUG_PROJECT_TOKEN` classic PAT to attach to board #15. The default `GITHUB_TOKEN` cannot write Projects v2; the PAT scope-split is documented in the repo's stored agent memory.
- Caps filings at `max` per run (default 5 for the cron, overridable via `workflow_dispatch` input).
- Posts a `Filed: <n>; Suppressed: <m>` summary to the workflow run log.

Network egress: the unattended job intentionally performs no live fetches against Microsoft Learn, GitHub docs, OWASP, or WCAG. If that scope expands later, add a separate workflow with explicit egress allow-listing rather than widening this one.

## Hard rules (mirrors the agent file)

- Read-only by default. No mutations without same-turn approval.
- One scan per invocation.
- No code edits — implementation hand-off goes to `@issue-resolver` or `@boards-worker`.
- Never invent labels.
- Default cap of 10 candidates per chat run, 5 per weekly cron.
- Dedupe is mandatory.
- Filed issues must have all four body sections.

## See also

- [Boards](Boards.md) — audit log entry for board #15.
- [Terminology](Terminology.md) — Project (portfolio) vs Board (Projects v2).
- Agent file: `.github/agents/maturity-scout.agent.md`.
- Workflow: `.github/workflows/maturity-scan.yml`.
