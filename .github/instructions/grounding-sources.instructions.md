---
description: "Canonical external best-practice URLs for grounding repo decisions. Load when reviewing PRs, drafting maturity gaps, validating workflow security, or citing best-practice sources. Not auto-attached — referenced from copilot-instructions.md and the maturity-scout / security-reviewer agents."
---

# Grounding sources

When an agent or PR needs to cite "current best practice" for the static-portfolio domain, use these URLs as ground truth. Do not invent or paraphrase recommendations from training data — fetch the live page and link the section. Each URL is intentionally the **stable docs landing page**, not a deep-link, so agents resolve to the latest content.

## Web platform — HTML, CSS, accessibility

| Topic | Source |
|---|---|
| HTML semantics, elements, forms | <https://developer.mozilla.org/en-US/docs/Web/HTML> |
| ARIA roles, states, properties | <https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA> |
| WCAG 2.2 success criteria (target conformance: AA) | <https://www.w3.org/WAI/WCAG22/quickref/> |
| WAI-ARIA Authoring Practices (patterns) | <https://www.w3.org/WAI/ARIA/apg/patterns/> |
| Subresource Integrity (SRI) for CDN scripts | <https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity> |
| Content Security Policy basics | <https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP> |

## GitHub Actions security & operations

| Topic | Source |
|---|---|
| Actions security hardening (top of stack) | <https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions> |
| `permissions:` reference (least privilege) | <https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs> |
| `pull_request_target` security model | <https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request_target> |
| Pinning third-party actions to SHAs | <https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions> |
| GITHUB_TOKEN permissions | <https://docs.github.com/en/actions/security-guides/automatic-token-authentication> |

## GitHub repo & Pages governance

| Topic | Source |
|---|---|
| Branch protection rules | <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches> |
| GitHub Pages — building from a branch / Actions | <https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages> |
| CODEOWNERS syntax | <https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners> |
| `SECURITY.md` policy | <https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository> |
| Dependabot configuration | <https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file> |
| CodeQL setup options | <https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/about-code-scanning-with-codeql> |
| Secret scanning + push protection | <https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning> |

## GitHub Projects v2 (boards)

| Topic | Source |
|---|---|
| Projects v2 overview | <https://docs.github.com/en/issues/planning-and-tracking-with-projects> |
| GraphQL API for ProjectV2 | <https://docs.github.com/en/graphql/reference/objects#projectv2> |
| `gh project` CLI reference | <https://cli.github.com/manual/gh_project> |

## Application security (static-site scope)

| Topic | Source |
|---|---|
| OWASP Top 10 (current) | <https://owasp.org/www-project-top-ten/> |
| OWASP Cheat Sheets index | <https://cheatsheetseries.owasp.org/> |
| OWASP HTML5 Security Cheat Sheet | <https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html> |

## Microsoft technology grounding

These ground the **content** of the portfolio pages (claims about Defender, Entra, Sentinel, Purview, etc.). When `@maturity-scout` runs `source:ms-learn`, fetch the relevant page below and compare against the live site copy.

| Topic | Source |
|---|---|
| Microsoft Learn — Security documentation hub | <https://learn.microsoft.com/en-us/security/> |
| Microsoft Defender for Cloud overview | <https://learn.microsoft.com/en-us/azure/defender-for-cloud/> |
| Microsoft Sentinel documentation | <https://learn.microsoft.com/en-us/azure/sentinel/> |
| Microsoft Entra ID documentation | <https://learn.microsoft.com/en-us/entra/> |
| Microsoft Purview documentation | <https://learn.microsoft.com/en-us/purview/> |
| Azure Security Benchmark | <https://learn.microsoft.com/en-us/security/benchmark/azure/> |

## Usage rules

- **Always fetch the live page** before citing — recommendations change. Do not rely on cached training data.
- **Link to a heading anchor** when possible (`#section-id`), not just the page root.
- **Cite once per finding** — agents should quote ≤2 sentences and link out, not mirror the source.
- If a recommendation conflicts with a hard rule in `copilot-instructions.md`, the repo rule wins; file a maturity issue if the conflict looks unintentional.
