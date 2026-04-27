# Boards audit log

Tracks the GitHub Projects (v2) **boards** used for portfolio work, plus the redundancy sweeps run by `@board-planner`.

> See [Terminology](Terminology) for the **Project** (portfolio) vs **Board** (GitHub Projects v2) distinction. Portfolio showcase Projects are documented in [Projects](Projects).

> Boards are owned at the user level. They surface on the repo's **Projects** tab via `gh project link`. All boards below are linked to `marcusjacobson/portfolio`.

## Active boards

| # | Title | Scope |
|---|---|---|
| [2](https://github.com/users/marcusjacobson/projects/2) | Certification/Education Path | Cert pipeline (cross-repo, includes legacy `marcusjacobson_portfolio` items + repo issue #13 for the Certifications page roadmap). Schema: vendor, exam Code, status, vendor Path/Order. |
| [9](https://github.com/users/marcusjacobson/projects/9) | Compass v-next | Coherent next-pass on `ms_security_compass.html`. Issues: #11 sendPrompt fallback, #14 GitHub link granularity, #15 mobile responsiveness. |
| [10](https://github.com/users/marcusjacobson/projects/10) | LinkedIn / Portfolio Sync | Rolling backlog for the `@linkedin-sync` agent build (#24–#30) and any gap-finding issues it generates on later runs. Schema adds **Source** (agent-build / gap-finding / best-practice). |
| [11](https://github.com/users/marcusjacobson/projects/11) | Cloud Agent Enablement | One-shot deliverable to enable the GitHub-hosted Copilot cloud agent (Agents tab + `@copilot` assignment): `AGENTS.md`, `copilot-setup-steps.yml`, `agent-task` template, MCP allow-list, smoke test, docs. Issues #32–#40. Schema adds **Source** (config / docs / smoke-test). Complementary to board #10 via Option B manual handoff: LinkedIn-Sync emits gap issues in the `agent-task` template; humans triage and assign `@copilot`. |
| [12](https://github.com/users/marcusjacobson/projects/12) | Bug Tracker | Rolling backlog for every issue tagged `bug`. Schema adds **Priority** (p0–p3), **Severity** (Critical/Major/Minor/Trivial), **Area** (html/css/docs/wiki/workflow), **Reported** (date). Status: Backlog → Triaged → In progress → In review → Done. Auto-seeded by the `Bug auto-add to project` workflow (`.github/workflows/bug-autoadd.yml`); the `@bug-intake` agent files the issue with the `bug` label and the workflow adds it to board #12. First item: #57 (tagline width). |
| [13](https://github.com/users/marcusjacobson/projects/13) | Microsoft Security Portfolio Roadmap | Rolling roadmap for the 16 forward-looking labs and capstones described in `staging-inbox/ms_security_projects_roadmap_v1.html`. Schema adds **Priority** (p0–p3), **Pillar** (Capstone / Cross-pillar / Purview / Defender + Sentinel / Entra / Azure / Security Copilot), **Tier** (Capstone / Standard), **Target date**. Hybrid item strategy: 3 Active items as tracking issues (#73, #74, #75) so they show up in repo issue search; 5 capstones + 10 standard Planned items as draft items (work lives in dedicated repos, not here). |

## Secrets

- **`BUG_PROJECT_TOKEN`** — **classic PAT** with the `project` scope (full control). Used by `.github/workflows/bug-autoadd.yml` to add issues to user-scope board #12. A classic token is required because fine-grained PATs do not currently support user-owned Projects v2 (only org-owned), and the default `GITHUB_TOKEN` cannot write Projects v2 at all. Include `repo` scope as well if the repo ever goes private. Rotate every 12 months or sooner; if expired, the workflow run errors (the issue itself shows no symptom). Repository secret name: `BUG_PROJECT_TOKEN` (name retained for back-compat — do not rename).

## Sweep log

### 2026-04-26 — projects-worker session: Board Terminology Split (#14)

- **Branch:** `projects-worker/board-terminology-split-20260426-1507` — PR pending
- **Operator:** projects-worker agent
- **Queue at start (Ready):** #85, #86, #87, #88, #89, #90, #91 (sequential, --max=7)
- **Status field options captured:** Ready=`f75ad846`, In progress=`47fc9ee4`, In review=`2aee1b22`, Done=`98236657`
- **Schema mutations applied:** rename Todo→Ready (id `f75ad846`), rename "In Progress"→"In progress" (id `47fc9ee4`), add new option "In review" (id `2aee1b22`). Single `updateProjectV2Field` GraphQL mutation against fieldId `PVTSSF_lAHOBvMdD84BVzd8zhRMjT0`. Approved by user message "go 1" on 2026-04-26 (handoff to `@project-planner`, executed and reported back before this session opened).
- **Per-issue transitions:**
  - #85 Ready → In progress at 2026-04-26T15:08:36-07:00
  - #85 In progress → Done — PR #92, merge `77d9b7e`
  - #86 Ready → In progress at 2026-04-26T18:20:08-07:00
  - #86 In progress → Done — PR #93, merge `a8251df` (smoke: issue #94, run 24972232517, item `PVTI_lAHOBvMdD84BVzLBzgrD-hI` on board #13)
  - #87 Ready → In progress at 2026-04-26T18:28:13-07:00
  - #87 In progress → Done — PR #95, merge `e84ba2f`
- **Scope corrections:**
  - 2026-04-26 mid-flight on #87 — `project-intake` excluded from the agent rename. Its mission is to triage *portfolio projects* the user is working on (capstones, security initiatives) and seed them onto board #13. Its noun is "Project" in the portfolio sense — the very noun this initiative preserves. Only `project-planner` → `board-planner` and `projects-worker` → `boards-worker` rename. Issue #87 body updated and a comment posted.
- **Outcome:** _(in flight)_

### 2026-04-26 — create Microsoft Security Portfolio Roadmap board (#13)

Inputs: user request via `@project-planner` — "create me a project plan for this sample page I created for upcoming and in-progress projects" (`staging-inbox/ms_security_projects_roadmap_v1.html`). 16 forward-looking items: 5 capstones, 1 cross-pillar, 2 Purview, 4 Defender + Sentinel, 3 Entra, 2 Azure, 1 Security Copilot. 3 of those 16 are Active (Purview-as-Code Repo, Azure-as-Code Comprehensive IaC Repo, Security Copilot On-Demand Lab Toggle); the rest are Planned.

Decisions:

- **New board #13 "Microsoft Security Portfolio Roadmap"** — 16 items easily clears the 3-item threshold; no overlap with #2, #9, #10, #11, #12.
- **Schema:** custom fields `Priority` (p0/p1/p2/p3), `Pillar` (Capstone / Cross-pillar / Purview / Defender + Sentinel / Entra / Azure / Security Copilot), `Tier` (Capstone / Standard), `Target date` (date). Default `Status` (Todo / In Progress / Done) kept.
- **Hybrid item strategy (Option C):**
  - 3 Active roadmap entries → tracking issues in `marcusjacobson/portfolio` so they're visible in repo issue search and can be linked from PRs: #73 Purview-as-Code Repo, #74 Azure-as-Code, #75 Security Copilot On-Demand Lab Toggle. All three labeled `priority:p1` and seeded into board #13 with `Status=In Progress`, `Tier=Standard`, the matching `Pillar`, and `Priority=p1`.
  - 13 Planned/Capstone roadmap entries → draft items in board #13 only. The actual implementation lives in dedicated repos (existing or future) — no need to file a stub issue against `portfolio` for each.
- **Field values applied to all 18 items** via `.tmp/set-fields.ps1` (built from captured field IDs and option IDs, then deleted with the rest of `.tmp/`). 5 capstones get `Tier=Capstone, Pillar=Capstone`; everything else `Tier=Standard` with the matching pillar.
- **Views:** default `Status` board ships with the board. Custom `Pillar` table view and `Target date` roadmap view need to be added in the UI — `gh project` has no view-create command. Captured as a follow-up.
- **Linked to repo** — appears on the Projects tab.

Redundancy report (post-state):

- 0 issues appear in two or more boards (#73/#74/#75 are only in #13).
- 0 board pairs with ≥50% item overlap (board #13 is disjoint from #2, #9, #10, #11, #12).
- 0 sunset candidates.
- Roadmap source page `staging-inbox/ms_security_projects_roadmap_v1.html` is still in the staging inbox — promoting it to a top-level page is out of scope for this sweep.

### 2026-04-26 — create Bug Tracker board (#12)

Inputs: user request via `@project-planner` — "I want a project to track any issues that are tagged as bugs." First bug filed under the new `@bug-intake` agent (#57) needed a board home.

Decisions:
- **New board #12 "Bug Tracker"** — rolling backlog, threshold met because the `bug` label is now part of the routine intake flow (every `@bug-intake` invocation seeds here).
- **Schema:** custom fields `Priority` (p0/p1/p2/p3), `Severity` (Critical/Major/Minor/Trivial), `Area` (html/css/docs/wiki/workflow), `Reported` (date). Default `Status` field kept (Backlog → Triaged → In progress → In review → Done — option rename deferred to first triage pass).
- **Linked to repo** — appears on the Projects tab.
- **Seeded #57** (Hero tagline box width vs card grid) via `scripts/gh/add-issue-to-project.ps1`.
- **Follow-up suggested (not filed yet):** small workflow to auto-add any newly-opened `bug`-labeled issue to board #12 so future `@bug-intake` runs don't have to seed manually.

Redundancy report (post-state):
- 0 issues in two or more boards (#57 is only in #12).
- 0 board pairs with ≥50% overlap (Bug Tracker is disjoint from #2, #9, #10, #11).
- 0 sunset candidates.

### 2026-04-26 — projects-worker session: Compass v-next resume (#9)

- **Branch:** `projects-worker/compass-v-next-20260426-resume`
- **Operator:** projects-worker agent (first session under the audit-log contract from PR #44)
- **Queue at start:** #14 (In review, returning to flight), #15 (Ready, deferred per user — visual snapshots required)
- **Status field options:** Ready=`f75ad846`, In Progress=`47fc9ee4`, In review=`84ddce89`, Done=`98236657`
- **Schema mutations applied:** none (schema stable from earlier session)
- **Follow-up issues filed:** #45 "Migrate 6 project cards to dedicated repos" — rollup tracker for the 6 cards on `ms_security_projects.html` that have no dedicated repo (Fabric Purview Governance Sim, Purview Skills Ramp, Purview Discovery Methods Sim, Entra Zero Trust RBAC, SC-300 Masterclass, Sentinel-as-Code). Labeled `content-update area:html priority:p3`, seeded into board #9. Filed before #14 ships so the resolution comment can reference it.
- **Per-issue transitions:**
  - #14 In review → In progress at 2026-04-26T19:10Z (resumed under user mapping option 1: minimal — update 2 cards, tag 4 repos, defer 6 to #45)
  - #14 In progress → Done — PR [#46](https://github.com/marcusjacobson/portfolio/pull/46), merge `bfe2fce`. Side effect: added `tests/lychee.toml` exclude for private lab repos.
  - #15 Ready → In progress at 2026-04-26T19:30Z
  - #15 In progress → Done — PR [#47](https://github.com/marcusjacobson/portfolio/pull/47), merge `2d70ca2`. First-time visual baseline lock approved verbatim by user: "update snapshots — lock baselines and ship #15". Scope creep documented in PR: Playwright config ESM→CJS fix and `pages.spec.ts` compass addition were necessary to make AC3 runnable at all.
- **Outcome:** clean drain. 2/2 worked this session (#14, #15). Combined with prior session: 3/3 of original Compass v-next queue done. Board #9 has 1 open follow-up: #45 (rollup tracker for 6 cards needing dedicated repos, p3, no SLA).

### 2026-04-26 — projects-worker session: Compass v-next (#9)

- **Branch:** `agent/projects-worker-audit-log` (retroactive — pre-dates the audit-log requirement landing in the agent file)
- **Operator:** projects-worker agent
- **Queue at start (Ready):** #11, #14, #15
- **Status field options captured:** Ready=`f75ad846` (renamed from `Todo`), In Progress=`47fc9ee4`, In review=`84ddce89` (added), Done=`98236657`
- **Schema mutations applied:** `updateProjectV2Field` on Status field `PVTSSF_lAHOBvMdD84BVx88zhRLP10` — renamed `Todo`→`Ready` (preserves item placement) and added `In review`. User approval: "Hand off to project-planner to add Ready + In review first" → operator opted to apply inline since the change was a rename plus single option-add and the board was empty of in-flight work. Should have routed through project-planner per the agent contract — captured here as a deviation for future reference.
- **Per-issue transitions:**
  - #11 Ready → In progress at 2026-04-26T18:24Z
  - #11 In progress → Done — PR [#43](https://github.com/marcusjacobson/portfolio/pull/43), merge `4dc360b`
  - #14 Ready → In progress at 2026-04-26T18:31Z
  - #14 In progress → In review — blocker: 6 of 9 cards have no dedicated repo; issue-resolver halted with mapping proposal awaiting user pick (option 1 / 2 / 3+mapping)
  - #15 untouched (batch halted before its turn)
- **Outcome:** worked 1/3, blocked on #14 awaiting user mapping decision. Drove the original "operate from `main` with no audit trail" gap that motivated the agent-file update in this PR.

### 2026-04-26 — first portfolio sweep (PR #21 follow-up)

Inputs surveyed: 6 open issues (#11–#16), 2 existing boards (#2, #8).

Decisions:
- **Add #13 to board #2** — issue is about visualizing the Certifications page that the board already drives. Regrouping into existing rather than creating a new board.
- **Create board #9 "Compass v-next"** with #11, #14, #15 — single-theme cluster (all touch the Compass HTML), threshold met (≥3 items).
- **Sunset board #8** — empty, untitled, no activity. Deleted.
- **Skip board for #12, #16** — single-theme but below the 3-item threshold or already a meta tracker. Recommended labels/milestone instead.

Redundancy report (post-state):
- 0 issues appear in two or more boards.
- 0 boards with ≥50% item overlap.
- 0 sunset candidates remaining.
- Unattached open issues: #12, #16 (intentionally loose).

### 2026-04-26 — create LinkedIn / Portfolio Sync board (#10)

Inputs: user request — "create an agent to check my portfolio against my LinkedIn profile and create issues that bring the two in line; re-runnable for new gaps."

Decisions:
- **New board #10 "LinkedIn / Portfolio Sync"** — passes the 3-item threshold (7 build issues seeded + an open lane for future agent-generated gap issues).
- **Drafted 7 build issues** (#24 input contract, #25 portfolio claims extractor, #26 gap taxonomy, #27 agent file, #28 best-practice checklist, #29 first live run, #30 docs).
- **Schema extension** — added single-select `Source` (agent-build / gap-finding / best-practice) so future runs can filter "work to build the agent" vs "work the agent found."
- **Linked to repo** so it surfaces on the Projects tab.
- **Fixed** `scripts/gh/add-issue-to-project.ps1` — old `--content-url` flag is gone in gh ≥ 2.x; script now resolves owner+number from the board URL and uses `--url`.

Redundancy report (post-state):
- 0 issues in two or more boards.
- 0 board pairs with ≥50% overlap (board #10 is disjoint from #2 and #9).
- 0 sunset candidates.

### 2026-04-26 — create Cloud Agent Enablement board (#11)

Inputs: user request — populate the GitHub Agents tab and follow best practices for the hosted Copilot cloud agent on this repo.

Eligibility check: `copilot-swe-agent` is in `marcusjacobson/portfolio`'s `suggestedActors(capabilities: [CAN_BE_ASSIGNED])` list — confirms a paid Copilot tier with cloud agent enabled. Premium-request budget for the smoke test (#39): ~1 request + ~5 Actions minutes, comfortably inside any paid tier's monthly allowance.

Decisions:
- **New board #11 "Cloud Agent Enablement"** — one-shot deliverable, 9 issues, passes the 3-item threshold.
- **Drafted 9 issues** covering: `AGENTS.md` (#32), audit `.github/copilot-instructions.md` (#33), `.github/workflows/copilot-setup-steps.yml` (#34), MCP allow-list / firewall posture (#35), `agent-task` label + issue template (#36), `wiki/Agents.md` mapping (#37), `README.md` Agents section (#38), end-to-end smoke test (#39), this audit-log entry (#40).
- **Schema extension** — added single-select `Source` (config / docs / smoke-test) so progress against the three workstreams is filterable.
- **Linked to repo** so it surfaces on the Projects tab.
- **LinkedIn-Sync integration: Option B (manual handoff)** — issue #36 explicitly aligns the `agent-task` template with the gap-issue format that board #10's `@linkedin-sync` agent will emit. No mutation to board #10. Humans stay in the loop on every `@copilot` assignment.

Redundancy report (post-state):
- 0 issues in two or more boards (board #11 is disjoint from #2, #9, #10).
- 0 board pairs with ≥50% overlap.
- 0 sunset candidates.
