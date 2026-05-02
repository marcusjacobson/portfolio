# Squad evaluation

Evaluation of [bradygaster/squad](https://github.com/bradygaster/squad) (`@bradygaster/squad-cli`) for integration into this repo. Filed under issue [#309](https://github.com/marcusjacobson/portfolio/issues/309).

- **Evaluated:** 2026-05-01
- **Squad version reviewed:** v0.9.4 (alpha)
- **Recommendation:** **Decline for now.** Re-evaluate when Squad ships v1.0 (out of alpha) AND a concrete gap appears in the existing agent system that Squad would close.

## What Squad is

Squad is an MIT-licensed CLI (`npm install -g @bradygaster/squad-cli`) that scaffolds a "human-led AI agent team" into a repo and runs it through GitHub Copilot. After `squad init`:

- A `.squad/` directory holds team state — `team.md`, `routing.md`, `casting-registry.json`, decision archives, history, and per-member identity files.
- A `squad.agent.md` file registers Squad as a Copilot chat agent, invoked via `copilot --agent squad --yolo` or selected as the **Squad** agent in VS Code Copilot Chat.
- Eleven GitHub Actions workflows are written under `.github/workflows/`: `squad-ci.yml`, `squad-docs.yml`, `squad-heartbeat.yml`, `squad-insider-release.yml`, `squad-issue-assign.yml`, `squad-label-enforce.yml`, `squad-preview.yml`, `squad-promote.yml`, `squad-release.yml`, `squad-triage.yml`, `sync-squad-labels.yml`.
- A 17-command CLI surface (`init`, `upgrade`, `status`, `triage`/`watch`, `copilot`, `doctor`, `link`, `externalize`, `internalize`, `shell`, `export`, `import`, `plugin`, `upstream`, `nap`, `aspire`, `scrub-emails`).
- A polling daemon (`squad triage` / `squad watch`) that scans for `squad:*`-labeled issues and dispatches Copilot agent sessions to work them, with optional `--execute --yolo --autopilot` execution posture.

The team-as-files concept is the central idea: each agent ("Ripley", "Ralph", a Lead, a Scribe, etc.) is a Markdown file under `.squad/`, persisted in the working tree, and labels like `squad:ripley` route an issue to a specific member via `squad-issue-assign.yml`.

## How this repo is wired today

This repo already runs a bespoke agent ecosystem catalogued in [Agents](Agents), [Prompts](Prompts), and [Repo-Architecture](Repo-Architecture):

- **14+ local chat agents** under [`.github/agents/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/agents) — `@request-intake`, `@bug-intake`, `@project-intake`, `@cert-intake`, `@issue-resolver`, `@boards-worker`, `@board-planner`, `@triage`, `@wiki-sync`, `@maturity-scout`, `@security-reviewer`, `@publish-manager`, `@repo-ops`, `@repo-cleanup`. Each is a Markdown spec invoked from VS Code Copilot Chat.
- **Hosted Copilot coding agent** governed by [AGENTS.md](https://github.com/marcusjacobson/portfolio/blob/main/AGENTS.md) — resolver-only contract, **one issue → one PR**, MCP allow-list closed by default (only GitHub MCP and Playwright MCP), no `gh pr merge --admin`, all required checks must pass.
- **Custom triage flow** — `needs-triage` label, board #19 Triage Queue, [`@triage`](https://github.com/marcusjacobson/portfolio/blob/main/.github/agents/triage.agent.md) chat agent. Maintainer triages locally, then optionally assigns the hosted cloud agent.
- **Wiki-as-code** — `wiki/*.md` synced one-way to the GitHub wiki, governed by [`@wiki-sync`](https://github.com/marcusjacobson/portfolio/blob/main/.github/agents/wiki-sync.agent.md) and [wiki-content instructions](https://github.com/marcusjacobson/portfolio/blob/main/.github/instructions/wiki-content.instructions.md).
- **Maturity scanner** — [`@maturity-scout`](Maturity-Scout) and [`maturity-scan.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/maturity-scan.yml) file gap issues onto board #15.

## Overlap and conflict

| Squad feature | This repo today | Verdict |
|---|---|---|
| `team.md` + per-member files in `.squad/` | `.github/agents/*.agent.md` catalogued in [Agents](Agents) | **Duplicate concept, different spec.** Squad's team format and our agent frontmatter are not interoperable. Adopting Squad means maintaining both, or rewriting all 14 agents into Squad's format. |
| `squad triage` / `watch --execute --yolo` polling daemon | `@triage` chat agent + [`needs-triage`](Boards) label + board #19 + maintainer-in-the-loop | **Conflicts with the cloud-agent contract.** AGENTS.md mandates one issue → one PR with all required checks green, never `--admin`, never `--no-verify`. Squad's `--yolo --autopilot` posture is the opposite stance. |
| `squad-issue-assign.yml` (label-routes `squad:<member>` to a member) | Existing routing through intake agents + `@copilot` assignment + [`tag-routing-autoadd.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/tag-routing-autoadd.yml) | **Adds an 11-workflow surface** that needs audit, pinning, `permissions:` review, and conflict-checking against existing label-routing. |
| `squad-label-enforce.yml` + `sync-squad-labels.yml` | Existing label set in [Boards](Boards) (`bug`, `chore`, `agent:*`, `area:*`, `priority:*`, `source:*`, `triage:*`, etc.) plus [`scripts/gh/sync-labels.ps1`](https://github.com/marcusjacobson/portfolio/blob/main/scripts/gh/sync-labels.ps1) | **Conflicting label namespaces.** Squad introduces `squad:*` labels and a label-enforce workflow that will fight with our existing label discipline. |
| `squad-release.yml`, `squad-promote.yml`, `squad-preview.yml`, `squad-npm-publish.yml`, `squad-insider-release.yml` | This repo has no release/publish pipeline beyond Pages. The site is static HTML with no build step. | **Not applicable.** These workflows assume Squad's own development lifecycle (npm package releases) and have no use here. |
| `casting-registry.json`, `casting-history.json`, `casting-policy.json`, "Ripley", "Ralph", thematic name cast | None — agents have plain functional names | **Stylistic mismatch.** This repo's agents are deliberately functional (`@issue-resolver`, `@boards-worker`). Adopting Squad's casting convention would obscure rather than clarify. |
| `nap` (context compression), `externalize`/`internalize` (move state outside working tree), `aspire` (Aspire dashboard) | Not applicable | Useful primitives in principle, but solve problems this repo doesn't have. State already lives under `wiki/` and `.github/`, both of which are explicitly version-controlled. |
| Decision archive in `.squad/` | `wiki/*.md` (Boards, Deployment-Rules, sweep logs) | **Duplicate.** A Squad install would split institutional memory between `.squad/` and `wiki/`. |

## Hard-rule checkpoints

Each is a hard rule from [.github/copilot-instructions.md](https://github.com/marcusjacobson/portfolio/blob/main/.github/copilot-instructions.md) and [AGENTS.md](https://github.com/marcusjacobson/portfolio/blob/main/AGENTS.md). Squad is checked against each.

- **No build step for the site.** Squad is dev-time only — npm CLI, agent state files, workflows. It does not introduce a build step for `*.html` pages and does not break this rule. **Pass.**
- **`*.html` browser-runnable from the repo root.** Squad does not write into HTML pages. **Pass.**
- **Pinned Action versions, `permissions:` on every workflow.** Squad's templated workflows use `actions/checkout@v4` and `actions/github-script@v7` — major-tag pinned, acceptable for first-party actions, but each of the 11 workflows still needs an individual review for `permissions:` minimization, secret usage, and trigger hygiene under [workflows.instructions.md](https://github.com/marcusjacobson/portfolio/blob/main/.github/instructions/workflows.instructions.md). **Costly to vet, not a blocker.**
- **No secrets/PATs in the repo; gitleaks runs on every PR.** Squad's `watch --execute` mode requires `gh auth login` and shells out to `gh copilot` with credentials. The credentials live on the operator's machine, not in the repo. The `--auth-user` flag is a username, not a token. **Pass on file-content, but the `watch` daemon's runtime auth posture would need a runbook.**
- **Pinned-version discipline vs alpha churn.** Squad is explicitly v0.9.4 alpha, with `squad upgrade --self` as the documented update path and a CHANGELOG that warns of breaking changes between releases. The repo's pinning discipline (Action SHAs, etc.) reflects a strong preference for stable surfaces. Adopting an alpha as core agent infrastructure would invert that preference. **Fail.**
- **MCP allow-list closed by default.** Squad does not require new MCP servers — it dispatches `gh copilot` sessions, which use whatever the operator has configured locally. Cloud-agent MCP scope is unaffected. **Pass.**
- **One issue → one PR, all required checks green, no `--admin`.** Squad's `watch --execute` is built around an autonomous polling loop that runs Copilot in `--yolo --autopilot` mode against issue queues. This is structurally incompatible with the resolver-only cloud-agent contract that requires a human or a tightly-scoped agent to land each PR through the standard merge gate. **Fail.**

## Recommendation: decline (with re-evaluation triggers)

Squad solves a problem this repo has already solved, in a shape that conflicts with the repo's review-gated execution posture. The cost to adopt — rewriting 14 agents, auditing 11 workflows, reconciling label namespaces, accepting an alpha dependency for core infrastructure — is high. The benefit is unclear because the existing system is working: intake → triage → resolver → review → merge is exercised on most PRs landed in 2026.

**Decline for now.** This issue closes `not planned` and the page records the decision.

### Re-evaluation triggers

Re-open this evaluation if **all** of the following become true:

1. Squad ships **v1.0** (or otherwise leaves alpha) and publishes a stability commitment for the `.squad/` state schema and the workflow templates.
2. A **concrete gap** appears in the existing agent system that Squad would close — for example, repeatable cross-repo agent state portability, or a polling/watch loop that the local chat agents cannot provide.
3. The cloud-agent contract evolves to allow a `--yolo`-style autonomous loop, **or** Squad ships a non-yolo, review-gated execution mode compatible with one-issue-one-PR.

Until then, observe Squad's evolution from outside. The closest local equivalent for "agent state as files" is already [`.github/agents/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/agents); the closest equivalent for "decision archive" is [`wiki/`](https://github.com/marcusjacobson/portfolio/tree/main/wiki); the closest equivalent for "watch loop" is [`maturity-scan.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/maturity-scan.yml) plus chat-driven `@triage`.

## What was *not* changed under this issue

Per the issue's spike-only scope:

- No `npm install` of `@bradygaster/squad-cli`.
- No `squad init` run against the working tree.
- No commit of `.squad/`, `squad.agent.md`, or any squad-templated workflow under `.github/workflows/`.
- No new MCP servers added to the cloud-agent allow-list.
- No new GitHub labels created for `squad:*` routing.

If this evaluation is later reversed, each of the above becomes a separate issue under the standard intake → resolver flow.
