# CLAUDE.md

Guidance for Claude sessions working in this repo. The rules live in
[AGENTS.md](AGENTS.md), [CONTRIBUTING.md](CONTRIBUTING.md) and
[.github/copilot-instructions.md](.github/copilot-instructions.md); read them first; they
win any conflict with this file. Path-scoped rules are in
[.github/instructions/](.github/instructions/).

## Essentials

- Never push to `main`. One logical change → one branch → one PR using the PR template.
- Run `npm ci` then `npm run lint` before pushing.
- User-visible changes need a `CHANGELOG.md` entry. Don't hand-edit `LAST_UPDATED` markers.
- Never edit `tests/visual/__snapshots__/` by hand. A red `playwright` after a visible change
  is expected; refresh baselines by dispatching `visual-regression.yml` with
  `update_snapshots=true` and commit only the baselines that changed.
- Required checks take a few minutes to register after a rebase. Never bypass branch protection.

## Content

- Pages are the root `*.html` files; no version suffixes.
- Voice is implied-subject and outcome-first ("Built", "Configured"); claims need project evidence.
- In `ms_security_compass.html`, every clickable node needs a matching entry in the `D` object.
