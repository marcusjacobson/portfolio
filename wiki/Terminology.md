# Terminology

This repo overloads the word "project". To keep prose, code, and tooling unambiguous, the following split is canonical:

## Project (portfolio sense)

A **Project** is a piece of portfolio showcase work — a security architecture engagement, capstone, or tracked initiative that lives on the live site.

- **Example:** an item listed on [`ms_security_projects.html`](../ms_security_projects.html), such as a Zero Trust deployment or a SIEM migration.
- **Exception worth flagging:** the GitHub-side board titled "Microsoft Security Portfolio Roadmap" (board #13) tracks portfolio Projects but is itself a Board. That is the namespace collision this split exists to disarm.

## Board (GitHub Projects v2 sense)

A **Board** is a GitHub Projects v2 board used for planning, triage, or roadmap tracking inside the repo's GitHub org.

- **Example:** the [Board Terminology Split board](https://github.com/users/marcusjacobson/projects/14) — meta, but accurate. It coordinates the very rename this page documents.

## Quick reference

| Phrase | Means | Where it lives |
|--------|-------|----------------|
| "Project Portfolio" | Portfolio (Project) | The live site / [`ms_security_projects.html`](../ms_security_projects.html) |
| `ms_security_projects.html` | Portfolio (Project) | Repo root, served by GitHub Pages |
| "the Bug Tracker board" | Board | GitHub Projects v2 |
| "the Compass v-next board" | Board | GitHub Projects v2 |
| The `Project` label | Board (signals "add this issue to a Board") | Repo labels — currently named `Project`, will be renamed to `Board` in #86. Until then, treat the label name as historical, not authoritative. |
| "Microsoft Security Portfolio Roadmap" (#13) | A Board that tracks Projects | GitHub Projects v2 |

## Why the split

- The word "project" was meaning two different things in the same paragraph, which broke routing in the intake agents and made label/workflow names ambiguous.
- Keeping "Project" exclusive to portfolio work matches how the live site already speaks to readers.
- Renaming GitHub Projects v2 references to "Board" matches the GitHub UI's own visual metaphor (a board with columns).

See [issue #85](https://github.com/marcusjacobson/portfolio/issues/85) for the full history and the 7-issue rollout (#85 → #91).
