# Projects

Portfolio showcase **Projects** — the security architecture engagements, capstones, and tracked initiatives that live on the public site.

> See [Terminology](Terminology) for the **Project** (portfolio) vs **Board** (GitHub Projects v2) distinction. For the GitHub Projects v2 audit log (boards, schemas, sweep history), see [Boards](Boards).

## Where Projects live

The canonical, browser-rendered list of portfolio Projects is the live page:

- [`ms_security_projects.html`](../ms_security_projects.html) — Microsoft Security Projects landing page (active and planned work).
- `staging-inbox/ms_security_projects_roadmap_v1.html` — staging copy of the forward-looking roadmap (16 labs and capstones). Promoted into the live site in batches as items move from Planned to Active.

## How Projects are tracked

Each portfolio Project has at most one of:

1. A **dedicated implementation repo** under `marcusjacobson/*` (e.g. `Purview-as-Code-MarcusJ-Lab`), where the actual lab/IaC work lives.
2. A **tracking issue** in `marcusjacobson/portfolio` for Projects that need cross-cutting visibility before a dedicated repo exists (e.g. #73 Purview-as-Code Repo, #74 Azure-as-Code, #75 Security Copilot On-Demand Lab Toggle).
3. A **draft item** on the [Microsoft Security Portfolio Roadmap board (#13)](https://github.com/users/marcusjacobson/projects/13) for Planned/Capstone Projects whose work has not yet started.

The roadmap board (#13) is itself a **Board** — see [Boards](Boards) — but its purpose is to track Projects. The terminology split keeps the noun "Project" exclusive to portfolio work; the board it lives on is named accordingly.

## Triage flow for new Projects

When the user wants to add a new portfolio Project (capstone, security initiative, lab idea), the request routes through the [`@project-intake`](../.github/agents/project-intake.agent.md) agent. The agent:

1. Classifies the request as a portfolio Project (vs a feature/bug/chore).
2. Creates a draft item directly on board #13 with `Status=Todo`, `Pillar`, `Tier`, and `Priority` set.
3. Waits for explicit user approval before any further mutation.

For all non-Project intake (features, bugs, chores), see [`@request-intake`](../.github/agents/request-intake.agent.md) and [`@bug-intake`](../.github/agents/bug-intake.agent.md).

## Note on the audit log move

The GitHub Projects v2 audit log (every Board on this user account, including internal-tooling boards like **Cloud Agent Enablement** (#11) — Source field `config / docs / smoke-test`, seeded issues #32–#40) now lives in [Boards](Boards). It used to live here, until the terminology split (PR #98) gave Boards their own page. This page now covers portfolio Projects only.

## See also

- [Boards](Boards) — GitHub Projects v2 audit log, schemas, and sweep history.
- [Terminology](Terminology) — canonical vocabulary.
- [`ms_security_projects.html`](../ms_security_projects.html) — the live portfolio Projects page.
