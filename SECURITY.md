# Security policy

This repository hosts a static HTML portfolio site published to GitHub Pages. There is no server, no database, no user authentication, and no build pipeline that produces executable artifacts. The realistic security surface is limited to:

- The static pages served from `main` via GitHub Pages.
- The GitHub Actions workflows under [.github/workflows/](.github/workflows/) that lint, test, and deploy the site.
- Repository metadata and automation (labels, agents, scripts under [scripts/](scripts/)).

## Reporting a vulnerability

If you believe you have found a security issue in this repository — for example, a secret accidentally committed, a workflow that could be abused to leak tokens, or a page that loads attacker-controlled content — please report it privately via **GitHub's private vulnerability reporting**:

1. Open <https://github.com/marcusjacobson/portfolio/security/advisories/new>.
2. Describe the issue, the affected file or workflow, and the impact you observed or expect.
3. Include reproduction steps if possible. A minimal proof-of-concept is more useful than a long write-up.

Please do **not** open a public issue for suspected vulnerabilities. Public issues are appropriate for general bugs, broken links, or visual regressions.

I aim to acknowledge reports within a few business days and to coordinate on a fix or disclosure timeline from there. Because this is a personal portfolio maintained by one person, response times are best-effort rather than guaranteed.

## Out of scope

The following are not treated as vulnerabilities for this repository:

- Reports generated solely by automated scanners against the static HTML pages with no demonstrated impact.
- Missing security headers on the GitHub Pages domain that are controlled by GitHub, not by this repository.
- Findings against forks, mirrors, or unofficial copies of the site.
- Social-engineering scenarios that require an attacker to already control the maintainer's GitHub account.

## Secrets and credentials

This repository must never contain secrets, personal access tokens, or customer data. [`gitleaks`](.github/workflows/) runs on every pull request and on pushes to `main`. If a secret is committed by accident, treat it as compromised: rotate the credential immediately, then open a private report so the commit history can be cleaned up.

## Supported versions

Only the current `main` branch is supported. There are no released versions of the site; what is on `main` is what is deployed.
