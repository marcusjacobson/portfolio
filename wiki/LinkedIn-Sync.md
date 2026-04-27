# LinkedIn Sync

`@linkedin-sync` is a chat-mode agent that compares the claims on this portfolio (HTML pages, certs, projects, skills) against a snapshot of the user's LinkedIn profile and files **gap issues** for anything that is missing, stale, or misaligned. It also runs a static best-practice checklist on every invocation.

The agent is designed to be re-run safely. Reruns with no new gaps create zero new issues.

## Purpose

Keep the public portfolio and the public LinkedIn profile telling the same story:

- Every active certification on `certification_strategy.html` is also visible on LinkedIn.
- Featured items, headline freshness, and project recency stay above defined thresholds.
- Drift between the two surfaces shows up as actionable GitHub issues, not as something the user has to remember to audit by hand.

## Input contract

The agent expects one normalized claim set from each side: portfolio and LinkedIn.

### Portfolio side

Extracted from the static HTML pages by the claims extractor (see [issue #25](https://github.com/marcusjacobson/portfolio/issues/25)). No user action required.

### LinkedIn side

Pick **one** of the supported ingestion paths (see [issue #24](https://github.com/marcusjacobson/portfolio/issues/24) for the field-mapping decision):

| Path | How to provide | Notes |
|------|----------------|-------|
| Manual paste | Paste profile sections into the chat when prompted. | Lowest friction; good for one-off runs. |
| Data export ZIP | Download from LinkedIn → *Settings → Get a copy of your data*; drop into `staging-inbox/linkedin/` (gitignored). | Most complete; reads `Profile.csv`, `Skills.csv`, `Certifications.csv`, `Positions.csv`. |
| Public profile URL | `linkedin.com/in/<slug>` — only with explicit opt-in for the user's own profile. | Subject to LinkedIn ToS / robots.txt; off by default. |

The agent **fails closed** if no input is provided — no silent zero-gap reports.

Sample fixtures live (or will live) under `tests/fixtures/linkedin/` with PII redacted.

## Gap categories

Findings are emitted as GitHub issues labeled `source:linkedin-sync` plus one of the `gap:*` labels below. See [issue #26](https://github.com/marcusjacobson/portfolio/issues/26) for the diff algorithm.

| Category | Meaning | Default severity |
|----------|---------|------------------|
| `gap:missing-on-linkedin` | Portfolio asserts X; LinkedIn does not. | p2 (p1 if cert or current title) |
| `gap:missing-on-portfolio` | LinkedIn asserts X; portfolio does not. | p2 |
| `gap:stale-date` | Same item, dates disagree by more than 30 days. | p2 |
| `gap:title-mismatch` | Same item, name differs (Levenshtein ≤ 3 or token-set ratio ≥ 0.85). | p1 |
| `gap:cert-status` | Cert appears active on one side, expired or in-progress on the other. | p1 |
| `gap:order-suggestion` | Pinned / featured order differs. | p3 |
| `gap:best-practice` | Static-rule check failed (recency, headline length, cert visibility, etc.). | p3 |

## How to run

```text
@linkedin-sync
```

The agent will:

1. Prompt for LinkedIn input (or detect the export under `staging-inbox/linkedin/`).
2. Extract portfolio claims from the HTML pages.
3. Compute the gap set.
4. Run the best-practice checklist (see below).
5. Present a **numbered proposal block** of findings.
6. Wait for explicit approval — `yes`, an edited subset (`yes 1,3,5`), or `cancel`.
7. File the approved findings as issues and append a run summary to the [Audit log](#audit-log).

### Read-only mode

```text
@linkedin-sync --report
```

Prints the gap table and best-practice findings without creating any issues. Safe to run any time.

## Best-practice checklist

Static rules that run every invocation, independent of the LinkedIn input. See [issue #28](https://github.com/marcusjacobson/portfolio/issues/28) for the full table.

| ID | Rule | Severity |
|----|------|----------|
| `bp-headline-fresh` | Portfolio headline edited within last 90 days. | p3 |
| `bp-cert-visibility` | Every active cert on `certification_strategy.html` appears on `index.html`. | p2 |
| `bp-project-recency` | At least one project on `ms_security_projects.html` updated within last 180 days. | p3 |
| `bp-skills-decay` | Skills with `lastUsed` > 24 months get an "archive" suggestion. | p3 |
| `bp-featured-parity` | LinkedIn featured-items count ≥ portfolio featured-items count. | p3 |
| `bp-headline-length` | LinkedIn headline ≤ 220 chars. | p3 |
| `bp-open-to-work-consistency` | Portfolio availability matches LinkedIn `Open to work`. | p2 |

Each rule emits at most one issue per run (deduped by rule id + finding hash).

## How to interpret findings

- **One finding = one issue.** Title pattern: `[linkedin-sync] <category>: <short summary>`.
- Issue body includes the diff, both source values, the proposed fix, and a link back to this wiki page.
- All findings carry `source:linkedin-sync`. Filter the issues view with that label to see the full backlog.
- Severity drives the priority label (`priority:p1` / `p2` / `p3`).
- Use `@issue-resolver` (or hand off to `@boards-worker`) to drain the backlog.
- Closing the issue without a code change is fine — the next run won't re-file it unless the underlying gap returns.

## Audit log

Every run appends a row here. The agent writes the row automatically; do not hand-edit.

| Date | Mode | Findings (total / new / dedup) | Top categories | Run summary |
|------|------|--------------------------------|----------------|-------------|
| _(no runs yet)_ | — | — | — | — |

## See also

- [Agents](Agents) — full chat-agent catalog and handoff diagram.
- [Boards](Boards) — board topology where `source:linkedin-sync` issues land.
- [Terminology](Terminology) — Project (portfolio) vs Board (GitHub Projects v2).
- Issues that built this agent: [#24](https://github.com/marcusjacobson/portfolio/issues/24), [#25](https://github.com/marcusjacobson/portfolio/issues/25), [#26](https://github.com/marcusjacobson/portfolio/issues/26), [#27](https://github.com/marcusjacobson/portfolio/issues/27), [#28](https://github.com/marcusjacobson/portfolio/issues/28), [#29](https://github.com/marcusjacobson/portfolio/issues/29).
