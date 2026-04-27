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

## Operator runbook

Manual operations against the weekly workflow. Use this when smoke-testing changes, replaying after a failed cron, or sweeping a backlog of freshly filed candidates.

### Manual dispatch

The workflow is `.github/workflows/maturity-scan.yml`. Its only `workflow_dispatch` input is `max` (string, default `5`) — the cap on total issues filed across **all** scan steps combined (repo-hygiene + github-docs + wcag share the counter).

```pwsh
gh workflow run maturity-scan.yml -f max=5 --ref main
```

Bump `max` only when intentionally draining a known backlog; the cron default of 5 exists to keep the `needs-triage` queue surveyable.

### Watching the run

```pwsh
gh run list --workflow=maturity-scan.yml --limit 5
gh run view <run-id>
gh run view <run-id> --log        # full log on failure
gh run view <run-id> --log-failed # just failed steps
```

The job name is `scan` (also a required PR check elsewhere in this repo — different workflow, same string). If the run never starts, confirm the ref exists on `origin/main` and that `BUG_PROJECT_TOKEN` is still valid (see token note below).

### Reading the summary

Each run writes a `$GITHUB_STEP_SUMMARY` block with one section per source it scanned: `repo-hygiene`, `github-docs`, and (post-#113) `wcag`. Each section reports:

- **Filed:** `<n>` — issues created this run, each with a link.
- **Suppressed (dedupe):** `<m>` — candidates that matched an existing open issue, a recently-closed completed issue (90-day window), or a board #15 item under the dedupe rules above. A `Suppressed (dedupe)` line is **expected and healthy** on a steady-state repo; it confirms the dedupe pass ran. A run with `Filed: 0; Suppressed: 0` means the source check found no gaps at all (also fine), not that dedupe was skipped.

If `Filed` plus `Suppressed` together equal the `max` cap, the scan likely truncated — re-run with a higher `max` or wait for the next cron.

### Verifying board attachment

`maturity-autoadd.yml` uses `actions/add-to-project` with `BUG_PROJECT_TOKEN` to attach freshly filed `needs-triage` issues to board #15 automatically. Verify:

```pwsh
# Find issues filed by this run (adjust date to the run start, ISO-8601)
gh issue list --label needs-triage --search 'created:>=2026-04-26' `
  --json number,title,labels,url

# Confirm each appears on board #15
gh project item-list 15 --owner marcusjacobson --format json
```

If an issue is missing from the board (autoadd failed mid-run, token rotated, etc.), reattach manually:

```pwsh
pwsh scripts/gh/add-issue-to-board.ps1 -IssueNumber <n>
```

Do **not** edit the issue's labels to "retrigger" autoadd unless you've confirmed the workflow's `on: issues` trigger is wired for `[opened, labeled]` — toggling labels otherwise just churns the audit log.

### BUG_PROJECT_TOKEN scope callout

`BUG_PROJECT_TOKEN` is a **classic PAT** with the `project` scope only. It can attach Projects v2 items (the `addProjectV2ItemById` mutation `actions/add-to-project` calls under the hood) but it **cannot** mutate issue labels — `addLabelsToLabelable` requires `public_repo` or `repo`, which this PAT deliberately does not have.

If `maturity-scan.yml` ever needs to label issues itself (today it relies on `gh issue create --label` running under the default `GITHUB_TOKEN`, which has `issues: write` from the workflow's `permissions:` block), keep the two-token split: probe / attach with `BUG_PROJECT_TOKEN`, label with `secrets.GITHUB_TOKEN`. See PR #83 for the canonical pattern. **Do not widen the PAT scope** — it is shared with `bug-autoadd.yml`, `project-autoadd.yml`, and `project-converted-issue.yml`, and broader scope expands the blast radius across all four workflows.

The same constraint is captured in the repo's stored agent memory under "BUG_PROJECT_TOKEN classic PAT scope limits".

## See also

- [Boards](Boards.md) — audit log entry for board #15.
- [Terminology](Terminology.md) — Project (portfolio) vs Board (Projects v2).
- Agent file: `.github/agents/maturity-scout.agent.md`.
- Workflow: `.github/workflows/maturity-scan.yml`.
