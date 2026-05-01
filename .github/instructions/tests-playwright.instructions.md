---
description: "Use when authoring or editing Playwright test specs under tests/. Covers visual snapshot rules, axe accessibility scans, and the local http-server baseURL contract."
applyTo: "tests/**/*.ts"
---

# Playwright test rules

## Snapshot discipline

- **Never edit `tests/visual/__snapshots__/` by hand.** Regenerate via `npm run test:visual:update` and commit the diff alongside the visual change that justified it.
- Snapshot filenames embed `testInfo.project.name` (`desktop`, `mobile`, `tablet`). When adding a new viewport, update `tests/playwright.config.ts` projects — do not hand-name snapshots.
- Visual specs live in `tests/visual/`; one `for (const page of PAGES)` loop per spec keeps the snapshot set predictable.

## Page list source of truth

Both `tests/visual/pages.spec.ts` and `tests/a11y/axe.spec.ts` enumerate the top-level `*.html` files. The a11y spec discovers them at runtime (`readdirSync(repoRoot).filter(*.html)`); the visual spec uses a hard-coded array. When adding a new top-level page, update **both**:

1. Append the filename to the `PAGES` array in `tests/visual/pages.spec.ts`.
2. Run `npm run test:visual:update` to seed snapshots for the new page across all projects.
3. The a11y spec picks the page up automatically — no edit needed.

## baseURL contract

- Tests load pages by relative filename (`pw.goto('index.html')`). The `baseURL` is set by `tests/playwright.config.ts` (and the maturity-scan workflow boots a local `http-server` on `:8080` before invoking the spec).
- Do **not** hardcode `http://localhost:8080` or absolute URLs in specs — they break under different ports and the GitHub Pages preview environment.

## Wait conditions

- Use `await pw.waitForLoadState('networkidle')` before screenshots so external fonts/CDN preconnects settle. `domcontentloaded` is too early; `load` misses lazy-loaded fonts.
- Avoid `page.waitForTimeout()` for stabilization — it's flaky across CI runners. Wait on a real signal (selector, network state, font readiness).

## axe accessibility scans

- The a11y spec writes JSON results to `.axe-pw-reports/<page-slug>.json` for the workflow to aggregate. Do not change that path without updating `.github/workflows/maturity-scan.yml`.
- Tag set is `['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']` — keep aligned with the `@axe-core/cli` (Option B) tag set so cross-scan rule comparisons stay valid.
- New rules or tag changes belong in a follow-up issue against board #15 (Portfolio Maturity), not buried in an unrelated PR.

## Imports

- Prefer named imports from `@playwright/test` (`import { test, expect } from '@playwright/test'`).
- Node built-ins use the `node:` prefix (`import { mkdirSync } from 'node:fs'`).
- Don't add new runtime dependencies for tests — everything must work from the existing `package.json` devDependencies.

## Local run

```pwsh
npm ci
npm run test:visual          # asserts against existing snapshots
npm run test:visual:update   # regenerates snapshots (only sanctioned way)
```

The a11y spec runs in CI via `maturity-scan.yml` — it is not part of the default `npm test` flow because it requires the http-server side-car.
