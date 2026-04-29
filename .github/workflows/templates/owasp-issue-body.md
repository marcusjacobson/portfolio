## Source

OWASP Top 10 (A05:2021 — Security Misconfiguration) and OWASP ASVS V14.4 (HTTP Security Headers / Content Loading) recommend integrity-pinning external script and stylesheet loads, hardening cross-origin link targets, and forbidding mixed-content references for any HTTPS-served page. See <https://owasp.org/Top10/A05_2021-Security_Misconfiguration/> and the MDN SRI guidance at <https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity>.

The OWASP static-checks scan flagged the rule **`__RULE__`** on __COUNT__ occurrence(s) across the top-level `*.html` portfolio pages. The scan is the deterministic pass run by `.github/workflows/maturity-scan.yml` using regex-only checks; it intentionally avoids any rule already enforced by `htmlhint` in the PR `lint` job.

## Why it matters

Each rule maps to a concrete attack surface on the live portfolio:

- `sri-external-script` — A cross-origin `<script src="https://...">` without `integrity=` and `crossorigin=` lets a compromised CDN ship arbitrary JS to every visitor. Subresource Integrity pins the served bytes to a hash you control.
- `sri-external-style` — Same risk as scripts: a compromised stylesheet can exfiltrate data via `background:url(...)` callbacks or rewrite the page via injected `@import`. SRI plus `crossorigin=` is the documented mitigation.
- `target-blank-noopener` — `<a target="_blank">` without `rel="noopener"` (or `noreferrer`) gives the destination page a `window.opener` handle, enabling reverse-tabnabbing redirects on the originating tab.
- `mixed-content` — Any `http://` reference in `src`, `href`, or `action` on an HTTPS page will be blocked by modern browsers (or downgrade-attacked if the user clicks through), breaking the page silently.

`htmlhint` does not enforce any of these four rules in the PR lint, so they would otherwise ship unchecked.

## Suggested change

For each finding listed below, apply the rule-specific mitigation:

- `sri-external-script` / `sri-external-style` — add `integrity="sha384-…"` and `crossorigin="anonymous"` to the tag. Generate the hash with `openssl dgst -sha384 -binary <file> | openssl base64 -A` or via the [SRI Hash Generator](https://www.srihash.org/).
- `target-blank-noopener` — add `rel="noopener noreferrer"` to the anchor (or just `rel="noopener"` if the referrer must be preserved).
- `mixed-content` — switch the URL to `https://` (verify the destination supports TLS) or host the asset locally under `assets/`.

## Acceptance criteria

- [ ] Every occurrence listed below passes the rule when re-scanned.
- [ ] Fix does not introduce any new `htmlhint` failures in the PR `lint` job.
- [ ] Visual-regression snapshots updated only if the fix changes rendered output.

Findings (__COUNT__):

__FINDINGS__

## Notes

OWASP `source:owasp` static checks scan added in #255. Scope is the six top-level `*.html` portfolio pages plus `changelog.html`. CSP-policy posture and inline-script accounting are deliberately out of scope for this regex pass; track those separately if they become a priority.
