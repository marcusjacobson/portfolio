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

## Coverage matrix

This is the canonical answer to "why did the weekly scan find so few things?" Audit performed in #135.

| `source:*` lane | Producer | Rules wired today | Known gaps | Decision |
|---|---|---|---|---|
| `source:repo-hygiene` | `maturity-scan.yml` steps `scan` (file-existence), `scan_branch_protection_drift`, `scan_label_drift` | 7 file-existence checks: `SECURITY.md`, `CONTRIBUTING.md`, `CODEOWNERS`, `.github/ISSUE_TEMPLATE`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/dependabot.yml`, `LICENSE`. Branch-protection drift: compares `scripts/apply-branch-protection.ps1` baseline vs. the live `/branches/main/protection` API state field-by-field (string-exact on context names — `analyze (javascript-typescript)` is NOT normalized to `analyze`). Label drift: diffs `.github/labels.yml` against `gh label list` for missing-in-repo, extra-in-repo, and color/description mismatches. Each drift check files at most one consolidated issue per run. | Stale-workflow detection (referenced action no longer exists upstream); auto-merge baseline drift; PR-review settings beyond the seven fields currently compared. | **Drift producers shipped** in #256. Remaining gaps tracked separately if/when they become a priority. |
| `source:github-docs` | `maturity-scan.yml` step `scan_github_docs` | 1 rule: action SHA-pin audit across `.github/workflows/*.yml` | CODEOWNERS shape validation (path globs cover the surfaces they need to); branch-protection doc completeness (does the wiki match what's enforced?); `permissions:` block presence on every workflow; concurrency block hygiene; `pull_request_target` usage audit | **Expand** — follow-up #257 filed for `permissions:`-presence, CODEOWNERS shape, and reusable-workflow pin checks. |
| `source:wcag` | `maturity-scan.yml` steps `scan_wcag` (v1, regex), `scan_wcag_axe` (v2 / Option B, axe-core CLI against a local static server), and `scan_wcag_axe_pw` (Option C, axe-core driven via Playwright — disabled by default) | v1: 3 regex rules — `html-has-lang` (3.1.1), `link-name` (4.1.2), `heading-order` (1.3.1). Option B (#126): every `@axe-core/cli` rule under tags `wcag2a,wcag2aa,wcag21a,wcag21aa,wcag22aa`, minus rules already covered by `htmlhint` and v1. Option C (#127): same tag set and exclusion list run via `@axe-core/playwright` so computed-style rules (e.g. `color-contrast`) can fire. All three pass scope to the 6 top-level `*.html` portfolio pages. | Multi-page flow checks, keyboard navigation, focus-trap interaction — anything that needs cross-page Playwright-driven DOM interaction rather than a single static load. | **v1 + Option B + Option C shipped** in #113, #126, and #127. Option C is gated behind a `workflow_dispatch` flag pending a head-to-head comparison run; see [Option B vs. Option C](#option-b-vs-option-c-coexistence) below. |
| `source:owasp` | `maturity-scan.yml` step `scan_owasp` | 4 regex rules across the top-level `*.html` portfolio pages: `sri-external-script` (SRI on cross-origin `<script>`), `sri-external-style` (SRI on cross-origin `<link rel=stylesheet>`), `target-blank-noopener` (`<a target="_blank">` without `rel="noopener"`/`noreferrer`), and `mixed-content` (any `http://` reference in `src`/`href`/`action`). Each rule files at most one consolidated issue per run; all four share the run-wide `MAX` cap with the earlier scan steps via step outputs. | CSP-policy posture (presence of a CSP `<meta>` or response header, allowed sources); inline `<script>` accounting vs. that policy; per-asset SRI hash freshness when external assets are upgraded; cross-page CSRF / `Referrer-Policy` audits. | **Shipped** in #255. CSP and inline-script accounting deliberately out of scope for this regex pass; track those separately if they become a priority. |
| `source:ms-learn` | None — unwired (by design) | None | Microsoft Learn page coverage for the security technologies claimed on the portfolio — every check requires LLM judgment to map a Learn page to a portfolio claim and assess whether the claim is current. | **Defer indefinitely — keep chat-mode only.** Adding a deterministic producer for this lane is not viable; the value is in the LLM-driven `@maturity-scout` chat audits already documented above. No follow-up issue. If a future deterministic check is identified (e.g. "the cert badge URL on `certification_strategy.html` resolves and matches the claimed exam code"), file it then. |

Notes from the #135 audit:

- The repo defines **five** `source:*` labels, not six. The original #135 framing referenced a `source:linkedin-sync` label that does not exist in `.github/labels.yml` and never has — the LinkedIn alignment claim lives in the portfolio chat-mode tooling, not as a maturity source.
- The `repo-hygiene` lane was originally claimed to cover "roughly 4 file paths"; the wired check list is in fact 7 paths. Of those 7, only `CODEOWNERS` is currently a gap on disk — the rest were closed out via #117, #118, and the v1 batch.
- No inline implementation was added in the #135 audit PR. Rationale: every gap above either (a) needs network/API access (branch-protection drift, label drift) and deserves token-scope review in its own PR, or (b) is a different lane (`source:owasp`) that needs its own producer step rather than being tacked onto `repo-hygiene`. The audit deliberately scoped to documentation + follow-up filings to keep the change reviewable.

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

- Scope is restricted to `source:repo-hygiene`, `source:github-docs`, `source:wcag`, and `source:owasp`. The other sources require LLM judgment for relevance and dedupe and stay in on-demand chat mode.
- `source:github-docs` v1 covers the action SHA-pin audit only — it scans every `.github/workflows/*.yml` file and files **one consolidated issue** per run when any `uses:` ref is not pinned to a 40-character commit SHA. Other github-docs checks (CODEOWNERS shape, branch-protection doc completeness) remain on-demand under `@maturity-scout` until added in a follow-up.
- `source:wcag` v1 covers three regex-only static checks across the six top-level `*.html` portfolio pages: `html-has-lang` (WCAG 3.1.1), `link-name` (WCAG 4.1.2), and `heading-order` (WCAG 1.3.1). Each rule files at most one consolidated issue per run, listing every page that fails.
- `source:wcag` v2 (added in #126) extends coverage via `@axe-core/cli` against a local `http-server` instance booted in CI. The step runs after v1, filters out rule ids already enforced by `htmlhint` (`alt-require`, `title-require`, `id-unique`, `tagname-lowercase`, `attr-no-duplication`, `src-not-empty`, `doctype-html5`) and the three v1 rules, dedupes against open `source:wcag` issues by rule id in title, and files **one issue per remaining failing rule id** with the same `needs-triage,source:wcag,area:html` label set. The v1 + v2 + earlier scan steps share a single MAX cap (chained via step outputs). Network egress: the step installs `@axe-core/cli` from the cached `npm ci` plus loads the locally served pages; no live external service is queried.
- `source:wcag` Option C (added in #127) extends coverage further via `@axe-core/playwright` driving a real Chromium load of each page, which is the prerequisite for any rule that needs computed styles (notably `color-contrast`). Option C is **disabled by default** to avoid double-filing alongside Option B; it runs only when the workflow is dispatched manually with `enable_axe_pw=true`. Both Option B and Option C use the same issue title format (`Fix axe-core violation: <rule> on portfolio pages`), the same exclusion list, and the same MAX cap chain — so even if both ever ran in the same run, the title-prefix dedupe pass would suppress the second filing for any rule already covered by the first. See the [Option B vs. Option C](#option-b-vs-option-c-coexistence) section below for the consolidation plan.
- `source:owasp` (added in #255) covers four regex-only static checks across the top-level `*.html` portfolio pages: `sri-external-script` (SRI on cross-origin `<script>`), `sri-external-style` (SRI on cross-origin `<link rel=stylesheet>`), `target-blank-noopener` (`<a target="_blank">` without `rel="noopener"`/`noreferrer`), and `mixed-content` (any `http://` reference in `src`/`href`/`action`). Each rule files at most one consolidated issue per run with `needs-triage,source:owasp,area:html`, listing every occurrence that fails. The step runs after `scan_wcag_axe` and shares the run-wide MAX cap with the earlier scan steps via step outputs.
- Playwright + axe-core integration is shipped as Option C above (#127). The runtime tradeoff (Option B is fast and CLI-only; Option C needs `npx playwright install --with-deps chromium` and a real browser load per page) is the reason Option C stays manual-dispatch only for now.
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

Each run writes a `$GITHUB_STEP_SUMMARY` block with one section per source it scanned: `repo-hygiene`, `github-docs`, `wcag` (post-#113), and `OWASP` (post-#255). Each section reports:

- **Filed:** `<n>` — issues created this run, each with a link.
- **Suppressed (dedupe):** `<m>` — candidates that matched an existing open issue, a recently-closed completed issue (90-day window), or a board #15 item under the dedupe rules above. A `Suppressed (dedupe)` line is **expected and healthy** on a steady-state repo; it confirms the dedupe pass ran. A run with `Filed: 0; Suppressed: 0` means the source check found no gaps at all (also fine), not that dedupe was skipped.

If `Filed` plus `Suppressed` together equal the `max` cap, the scan likely truncated — re-run with a higher `max` or wait for the next cron.

### Verifying board attachment

`maturity-scan.yml` attaches each filed issue to board #15 **inline** within the same step, using `BUG_PROJECT_TOKEN`. The board-attach is therefore deterministic and same-run — expect the issue on board #15 by the time the workflow run reports `success`.

This inline pattern exists because GitHub Actions does not trigger downstream workflows from events caused by the default `GITHUB_TOKEN`. The sibling `maturity-autoadd.yml` workflow remains as a fallback for `source:*` issues filed manually or by other automation, but `maturity-scan.yml` does not depend on it. See issue #133 for the original failure mode and fix.

Verify:

```pwsh
# Find issues filed by this run (adjust date to the run start, ISO-8601)
gh issue list --label needs-triage --search 'created:>=2026-04-26' `
  --json number,title,labels,url

# Confirm each appears on board #15
gh project item-list 15 --owner marcusjacobson --format json
```

If an issue is missing from the board (e.g. `BUG_PROJECT_TOKEN` rotated mid-run, network blip on the project-add call), reattach manually:

```pwsh
pwsh scripts/gh/add-issue-to-board.ps1 -IssueNumber <n>
```

Do **not** edit the issue's labels to "retrigger" the fallback `maturity-autoadd.yml` — toggling labels just churns the audit log, and the inline path is the source of truth.

### BUG_PROJECT_TOKEN scope callout

`BUG_PROJECT_TOKEN` is a **classic PAT** with the `project` scope only. It can attach Projects v2 items (the `addProjectV2ItemById` mutation `actions/add-to-project` calls under the hood) but it **cannot** mutate issue labels — `addLabelsToLabelable` requires `public_repo` or `repo`, which this PAT deliberately does not have.

If `maturity-scan.yml` ever needs to label issues itself (today it relies on `gh issue create --label` running under the default `GITHUB_TOKEN`, which has `issues: write` from the workflow's `permissions:` block), keep the two-token split: probe / attach with `BUG_PROJECT_TOKEN`, label with `secrets.GITHUB_TOKEN`. See PR #83 for the canonical pattern. **Do not widen the PAT scope** — it is shared with `bug-autoadd.yml`, `project-autoadd.yml`, and `project-converted-issue.yml`, and broader scope expands the blast radius across all four workflows.

The same constraint is captured in the repo's stored agent memory under "BUG_PROJECT_TOKEN classic PAT scope limits".

## Option B vs. Option C coexistence

Both the `@axe-core/cli` scan (Option B, #126) and the `@axe-core/playwright` scan (Option C, #127) currently live in `maturity-scan.yml`. The decision in #127 was to **keep both checked in but only run one unattended** until we have a side-by-side comparison from a real run.

| | Option B — `scan_wcag_axe` | Option C — `scan_wcag_axe_pw` |
|---|---|---|
| Tool | `@axe-core/cli` against `http://localhost:8080/<page>` | `@axe-core/playwright` driving a real Chromium load |
| When it runs | Every scheduled cron + every `workflow_dispatch` | Only when dispatched with `enable_axe_pw=true` |
| Computed-style rules (e.g. `color-contrast`) | No — CLI loads pages without a real layout engine | Yes — full Chromium with computed styles |
| CI cost | Light — `npm ci` is already cached | Heavier — adds `npx playwright install --with-deps chromium` |
| Title format | `Fix axe-core violation: <rule> on portfolio pages` | Same — verbatim |
| Body template | `.github/workflows/templates/wcag-axe-issue-body.md` | `.github/workflows/templates/wcag-axe-pw-issue-body.md` |
| Exclusion list | htmlhint-covered rules + v1 regex rules | Identical to Option B |
| MAX cap | Shares the chain — consumes `scan_wcag.outputs.filed_total`, emits its own | Shares the chain — consumes `scan_wcag_axe.outputs.filed_total`, emits its own |

Why both stay in the repo for now:

- Option C is the only path to `color-contrast` findings, which is the single biggest gap Option B can't close.
- Running Option C on every cron without first comparing its output to Option B risks a flood of duplicate filings on first contact (e.g. when one scan reports `nested-interactive` against a page the other reports `aria-allowed-role` against the same selector).
- Title-format parity means the Option C dedupe pass will silently suppress any rule Option B already filed in an earlier step of the same run, so the worst case is a no-op rather than double-filing.

Consolidation plan (follow-up issue to be filed once the comparison run is in hand):

1. Dispatch `Maturity Scout` manually with `enable_axe_pw=true` and `max=20` so both scans run end-to-end on the same DOM.
2. Diff the two filed-issue sets by rule id. Triage any rule Option C reports but Option B doesn't (likely `color-contrast`, possibly `aria-hidden-focus` or `nested-interactive`).
3. If Option C is a strict superset, retire Option B (delete the `scan_wcag_axe` step + `wcag-axe-issue-body.md`, drop `@axe-core/cli` from `package.json`) and flip `enable_axe_pw` to default-true (or remove the gate entirely).
4. If Option B has its own unique rule coverage worth keeping, leave both wired and drop Option C's `if:` gate so it runs every cron — the title-prefix dedupe is already proved out by step 1.

## See also

- [Boards](Boards.md) — audit log entry for board #15.
- [Terminology](Terminology.md) — Project (portfolio) vs Board (Projects v2).
- Agent file: `.github/agents/maturity-scout.agent.md`.
- Workflow: `.github/workflows/maturity-scan.yml`.
