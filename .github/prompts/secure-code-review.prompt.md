---
description: "Secure code review of a PR diff: scans for XSS, secret leakage, supply-chain risk, and unsafe inline scripts; integrates CodeQL and gitleaks results."
argument-hint: "PR number (or 'current branch')"
agent: "agent"
---

# Secure code review

You are reviewing a pull request for security issues before merge. Static HTML site context — the threat model is XSS via inline scripts, third-party CDN trust, leaked secrets, and unsafe workflow permissions.

## Inputs

- PR number from `$ARGUMENTS`. If "current branch", use `gh pr view --json number -q .number`.
- Diff: `gh pr diff <PR>`.
- CodeQL results: `gh api repos/:owner/:repo/code-scanning/alerts?pr=<PR>` (best effort).
- Gitleaks check: read the workflow run summary via `gh run list --workflow=gitleaks.yml --branch=<branch>`.

## Checklist (apply to every changed file)

### HTML / inline JS
- [ ] No `innerHTML` / `document.write` with user-influenced strings.
- [ ] No inline event handlers (`onclick=`) using untrusted data.
- [ ] External `<script>` / `<link>` from CDN have `integrity=` (SRI) and `crossorigin=`.
- [ ] No `target="_blank"` without `rel="noopener noreferrer"`.
- [ ] No data URIs containing scripts.

### Secrets & data
- [ ] No tokens, API keys, connection strings, emails, or phone numbers in diffs.
- [ ] No internal URLs / hostnames that shouldn't be public.

### Workflows
- [ ] `permissions:` is least-privilege.
- [ ] Third-party actions pinned to SHA (or at minimum `@vN`).
- [ ] No `pull_request_target` with checked-out PR head running untrusted code.
- [ ] No `${{ github.event.* }}` interpolation directly into shell `run:` blocks (script injection).

### Dependencies
- [ ] `package.json` / lockfile changes are dev-only and from known publishers.
- [ ] No new postinstall scripts.

## Output format

```
## Secure code review — PR #<n>

**Verdict:** APPROVE | REQUEST CHANGES | COMMENT

### Findings
| Severity | File | Line | Issue | Fix |
|----------|------|------|-------|-----|
| ...      | ...  | ...  | ...   | ... |

### Notes
- CodeQL: <pass/fail/N alerts>
- Gitleaks: <pass/fail>
- Dependabot context: <if relevant>
```

## Constraints

- DO NOT modify code. This is review-only.
- If you spot a critical issue (live secret, RCE-class workflow injection), call it out at the top with **STOP — do not merge** and explain.
