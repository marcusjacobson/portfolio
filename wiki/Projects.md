# Projects audit log

Tracks the GitHub Projects (v2) used for portfolio work, plus the redundancy sweeps run by `@project-planner`.

> Projects v2 are owned at the user level. They surface on the repo's **Projects** tab via `gh project link`. All projects below are linked to `marcusjacobson/portfolio`.

## Active projects

| # | Title | Scope |
|---|---|---|
| [2](https://github.com/users/marcusjacobson/projects/2) | Certification/Education Path | Cert pipeline (cross-repo, includes legacy `marcusjacobson_portfolio` items + repo issue #13 for the Certifications page roadmap). Schema: vendor, exam Code, status, vendor Path/Order. |
| [9](https://github.com/users/marcusjacobson/projects/9) | Compass v-next | Coherent next-pass on `ms_security_compass.html`. Issues: #11 sendPrompt fallback, #14 GitHub link granularity, #15 mobile responsiveness. |
| [10](https://github.com/users/marcusjacobson/projects/10) | LinkedIn / Portfolio Sync | Rolling backlog for the `@linkedin-sync` agent build (#24–#30) and any gap-finding issues it generates on later runs. Schema adds **Source** (agent-build / gap-finding / best-practice). |

## Sweep log

### 2026-04-26 — first portfolio sweep (PR #21 follow-up)

Inputs surveyed: 6 open issues (#11–#16), 2 existing projects (#2, #8).

Decisions:
- **Add #13 to project #2** — issue is about visualizing the Certifications page that the project already drives. Regrouping into existing rather than creating a new project.
- **Create project #9 "Compass v-next"** with #11, #14, #15 — single-theme cluster (all touch the Compass HTML), threshold met (≥3 items).
- **Sunset project #8** — empty, untitled, no activity. Deleted.
- **Skip project for #12, #16** — single-theme but below the 3-item threshold or already a meta tracker. Recommended labels/milestone instead.

Redundancy report (post-state):
- 0 issues appear in two or more projects.
- 0 projects with ≥50% item overlap.
- 0 sunset candidates remaining.
- Unattached open issues: #12, #16 (intentionally loose).

### 2026-04-26 — create LinkedIn / Portfolio Sync project (#10)

Inputs: user request — "create an agent to check my portfolio against my LinkedIn profile and create issues that bring the two in line; re-runnable for new gaps."

Decisions:
- **New project #10 "LinkedIn / Portfolio Sync"** — passes the 3-item threshold (7 build issues seeded + an open lane for future agent-generated gap issues).
- **Drafted 7 build issues** (#24 input contract, #25 portfolio claims extractor, #26 gap taxonomy, #27 agent file, #28 best-practice checklist, #29 first live run, #30 docs).
- **Schema extension** — added single-select `Source` (agent-build / gap-finding / best-practice) so future runs can filter "work to build the agent" vs "work the agent found."
- **Linked to repo** so it surfaces on the Projects tab.
- **Fixed** `scripts/gh/add-issue-to-project.ps1` — old `--content-url` flag is gone in gh ≥ 2.x; script now resolves owner+number from the project URL and uses `--url`.

Redundancy report (post-state):
- 0 issues in two or more projects.
- 0 project pairs with ≥50% overlap (project #10 is disjoint from #2 and #9).
- 0 sunset candidates.
