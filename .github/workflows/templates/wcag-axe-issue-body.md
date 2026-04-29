## Context

WCAG 2.2 axe-core scan flagged the rule **`__RULE__`** on __COUNT__ portfolio page(s). The scan is the v2 (DOM-aware) pass run by `.github/workflows/maturity-scan.yml`; it boots a local static server, runs `@axe-core/cli` against each top-level `*.html` portfolio page, and filters out rule ids already enforced by `htmlhint` in the PR `lint` job and the v1 (regex-only) checks shipped in #113.

## Why it matters

`axe-core` flags a violation against WCAG 2.2 / Section 508 success criteria. Each occurrence affects assistive-technology users on the live portfolio:

- Rule documentation: <__HELP_URL__>
- Impact level reported by axe: **__IMPACT__**

`htmlhint` does not enforce this rule in the PR lint, and the v1 (regex-only) `source:wcag` scan from #113 does not cover it either, so it would otherwise ship unchecked.

## Acceptance criteria

- [ ] Every page listed below passes the rule when re-scanned by `@axe-core/cli` (no remaining violation for `__RULE__`).
- [ ] Fix does not introduce any new `htmlhint` failures in the PR `lint` job.
- [ ] Fix does not introduce any new violations for the v1 `source:wcag` rules (`html-has-lang`, `link-name`, `heading-order`).
- [ ] Visual-regression snapshots updated only if the fix changes rendered output.

Findings (__COUNT__):

__FINDINGS__

## Notes

This is the WCAG v2 (axe-core) scan added in #126. It complements but does not replace the v1 regex-only scan from #113. Playwright + axe-core integration tracked separately in #127 — do not retrofit those checks into this v2 scan.
