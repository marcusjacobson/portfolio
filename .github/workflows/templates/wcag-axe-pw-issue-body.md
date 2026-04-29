## Source

WCAG 2.2 axe-core scan (Playwright + `@axe-core/playwright`) flagged the rule **`__RULE__`** on __COUNT__ portfolio page(s). This is the **Option C** pass run by `.github/workflows/maturity-scan.yml` step `scan_wcag_axe_pw`: it boots a local static server, drives each top-level `*.html` portfolio page through Playwright (full DOM + computed styles), and runs `@axe-core/playwright` against the rendered page. Unlike the Option B `@axe-core/cli` scan (#126), this pass can resolve `color-contrast` against actual computed CSS.

Rules already enforced by `htmlhint` (PR `lint`) and the v1 regex pass from #113 (`html-has-lang`, `link-name`, `heading-order`) are filtered out before any issue is filed.

## Why it matters

`axe-core` flags a violation against WCAG 2.2 / Section 508 success criteria. Each occurrence affects assistive-technology users on the live portfolio:

- Rule documentation: <__HELP_URL__>
- Impact level reported by axe: **__IMPACT__**

The Option B CLI scan cannot reliably surface this rule (or surfaces it without enough DOM context to act on it); the Playwright pass loads the page in a real browser engine, which is the prerequisite for `color-contrast` and any rule that depends on computed styles or layout.

## Suggested change

Address every page listed below so the rule no longer fires. Re-run the Option C scan locally to confirm:

```bash
npx http-server -p 8080 -s . &
AXE_BASE_URL=http://localhost:8080/ npm run test:a11y
```

The fix should not introduce new `htmlhint` failures in the PR `lint` job and should not regress the v1 `source:wcag` rules.

## Acceptance criteria

- [ ] Every page listed below passes the rule when re-scanned by `@axe-core/playwright` (no remaining violation for `__RULE__`).
- [ ] Fix does not introduce any new `htmlhint` failures in the PR `lint` job.
- [ ] Fix does not introduce any new violations for the v1 `source:wcag` rules (`html-has-lang`, `link-name`, `heading-order`).
- [ ] Visual-regression snapshots updated only if the fix changes rendered output.

Findings (__COUNT__):

__FINDINGS__

## Notes

This is the WCAG Option C (Playwright + `@axe-core/playwright`) scan added in #127. Option B (`@axe-core/cli`, #126) and Option C currently coexist: Option B runs on every scheduled cron; Option C runs only when the workflow is manually dispatched with `enable_axe_pw=true`. Both pass shapes file under the same title format (`Fix axe-core violation: <rule> on portfolio pages`) so the dedupe pass keeps either scan from double-filing if both ever run unattended in the same run. See `wiki/Maturity-Scout.md` for the coexistence decision and the planned consolidation.
