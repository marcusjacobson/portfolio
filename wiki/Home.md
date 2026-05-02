# Marcus Jacobson — Microsoft Security Architecture Portfolio

Welcome to the wiki. This is the source of truth for project notes, runbooks, and reference material backing [the portfolio site](https://marcusjacobson.github.io/portfolio/).

> **Editing note:** This wiki is maintained as code in the `wiki/` folder of the [portfolio repo](https://github.com/marcusjacobson/portfolio). Edits made directly here on github.com **will be overwritten** on the next sync. Open a PR against the repo instead.

## Sections

- [Terminology](Terminology) — "Project" (portfolio) vs "Board" (GitHub Projects v2). Read this first.
- [Repo-Architecture](Repo-Architecture) — Folder map and the chat-prompt-to-merged-PR intake flow.
- [Projects](Projects) — Portfolio showcase Projects (the live site's `ms_security_projects.html`).
- [Boards](Boards) — GitHub Projects v2 audit log, schemas, and sweep history.
- [Agents](Agents) — Local chat-mode agents and the hosted Copilot coding agent that build and maintain this repo.
- [Prompts](Prompts) — Slash-command prompts under `.github/prompts/` and the agents they hand off to.
- [Workflows](Workflows) — GitHub Actions catalog: triggers, permissions, secrets, and which checks block PR merges.
- [Deployment-Rules](Deployment-Rules) — Branch protection, required status contexts, and the Pages deploy contract.
- [Publishing-Workflow](Publishing-Workflow) — How content reaches the live site.
- [Security-Review-Checklist](Security-Review-Checklist) — What gets verified on every PR.
- [Site-Architecture](Site-Architecture) — Page layout and tooling overview.

## Build mechanics

How this repo is wired — the agents, prompts, workflows, and rules that turn a chat request into a merged PR and a published site. Start here if you want to understand or extend the automation rather than the portfolio content itself.

- [Repo-Architecture](Repo-Architecture) — Folder map and the chat-prompt-to-merged-PR intake flow.
- [Agents](Agents) — Local chat-mode agents and the hosted Copilot coding agent that build and maintain this repo.
- [Prompts](Prompts) — Slash-command prompts under `.github/prompts/` and the agents they hand off to.
- [Workflows](Workflows) — GitHub Actions catalog: triggers, permissions, secrets, and which checks block PR merges.
- [Deployment-Rules](Deployment-Rules) — Branch protection, required status contexts, and the Pages deploy contract.
- [Boards](Boards) — GitHub Projects v2 audit log, schemas, and sweep history.
- [Maturity-Scout](Maturity-Scout) — The repo-hygiene scanner that files gap issues against authoritative sources.
- [Squad-Evaluation](Squad-Evaluation) — Evaluation of the bradygaster/squad agent-team CLI against this repo's existing agent system.
- [Terminology](Terminology) — "Project" (portfolio) vs "Board" (GitHub Projects v2). Read this first.
