## Context

WCAG 2.2 static-a11y scan flagged the rule **`__RULE__`** on __COUNT__ portfolio page(s). The scan is the deterministic v1 pass run by `.github/workflows/maturity-scan.yml`; it uses regex-only checks across the six top-level `*.html` portfolio pages and intentionally avoids any rule already enforced by `htmlhint` in the PR `lint` job.

## Why it matters

Each rule maps to a WCAG 2.2 success criterion that affects assistive-technology users on the live portfolio:

- `html-has-lang` — WCAG 3.1.1 (Language of Page). Screen readers need the document language to pick the right voice + pronunciation.
- `link-name` — WCAG 4.1.2 (Name, Role, Value). Empty or icon-only links read as "link" with no destination, breaking link-list navigation.
- `heading-order` — WCAG 1.3.1 (Info and Relationships). Heading-level skips (e.g., `h1` → `h3`) corrupt the document outline used by screen-reader heading navigation.

`htmlhint` does not enforce any of these three rules in the PR lint, so they would otherwise ship unchecked.

## Acceptance criteria

- [ ] Every page listed below passes the rule when re-scanned.
- [ ] Fix does not introduce any new `htmlhint` failures in the PR `lint` job.
- [ ] Visual-regression snapshots updated only if the fix changes rendered output.

Findings (__COUNT__):

__FINDINGS__

## Notes

This is the WCAG v1 (regex-only) scan. Broader DOM-aware coverage — color contrast, landmark/region rules, form-label association, and full WCAG 2.2 AA — is tracked in #126 (`@axe-core/cli` integration) and #127 (Playwright + axe-core). Do not retrofit those rules into this v1 scan.
