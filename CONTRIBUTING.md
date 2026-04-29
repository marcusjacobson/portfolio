# Contributing

Thanks for taking a look. This is a personal portfolio site, so most contributions come from me — but issues, fixes, and small content corrections from outside contributors are welcome. This guide explains how the repo expects work to flow.

For the security-reporting path, see [SECURITY.md](SECURITY.md). For broader repo conventions, see [.github/copilot-instructions.md](.github/copilot-instructions.md) and [AGENTS.md](AGENTS.md).

## Filing an issue

Use the templates in [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/):

- **Bug** — something on the live site is broken or visually regressed.
- **Content update** — a fact, link, or wording change on an existing page.
- **New page** — a proposal to add a new page or major section.
- **Link rot** — a broken external link surfaced by the link checker.

Maintainer-side intake (e.g. `@request-intake`, `@bug-intake`, `@project-intake`) runs in the maintainer's local Copilot Chat and is not something external contributors need to invoke. File via the templates and the right routing labels will be applied during triage.

Please do not file public issues for suspected security vulnerabilities — use the private channel described in [SECURITY.md](SECURITY.md).

## Branch and PR workflow

The repo enforces a single, simple flow:

- **One issue → one branch → one PR.** Do not bundle unrelated changes.
- **Never push directly to `main`.** All changes land via pull request, with required checks green.
- Branch from the latest `main`. Suggested naming: `<type>/<short-slug>-<issue-number>` (e.g. `docs/contributing-md-118`, `fix/visual-overflow-99`).
- PR descriptions should include a short summary, screenshots for visual changes, and reference the issue with `Closes #N`.

## Local validation

The site itself has no build step — every `*.html` page runs as-is in a browser. The `npm` toolchain is dev-time only (lint, link-check, visual regression).

```powershell
npm ci                       # install dev dependencies
npm run lint                 # htmlhint + stylelint
npm run test:visual          # Playwright visual regression
npm run test:visual:update   # regenerate snapshots (the only sanctioned way)
```

Hard rules:

- **Never edit `tests/visual/__snapshots__/` by hand.** Regenerate with `npm run test:visual:update` and commit the result.
- All `<img>` tags must have `alt` attributes (`htmlhint` enforces this).
- No secrets, PATs, or personal data — `gitleaks` runs on every PR.
- Workflow files under [.github/workflows/](.github/workflows/) must pin action versions and declare a `permissions:` block (default `contents: read`, elevate per job).

## Commit and PR style

- Commit subject: imperative mood, ≤72 characters. Body explains *why* if non-obvious.
- PR title: same shape as the commit subject.
- Reference the issue from the PR body with `Closes #N` so it auto-closes on merge.

## Code of conduct

Be civil, be specific, and assume good intent. The maintainer reserves the right to close or lock threads that drift off-topic for a personal portfolio repo.
