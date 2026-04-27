## Source

GitHub Actions security hardening — <https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions>

> Pinning an action to a full length commit SHA is currently the only way to use an action as an immutable release. Pinning to a particular SHA helps mitigate the risk of a bad actor adding a backdoor to the action's repository.

## Why it matters

This repo's `.github/copilot-instructions.md` already states "SHAs preferred for third-party actions." A scan of `.github/workflows/*.yml` found __COUNT__ `uses:` reference(s) where the ref after `@` is not a 40-character commit SHA. Tag-pinned third-party actions can be retargeted by the upstream maintainer (or an attacker who compromises the maintainer) without any change in this repo, which silently expands the supply-chain trust boundary.

## Suggested change

Replace each tag/branch ref below with the commit SHA of the release that tag currently points to, and add a trailing `# v<x.y.z>` comment so the version is still legible during review. Example: `uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2`.

Findings:

__FINDINGS__

## Acceptance criteria

- [ ] Every `uses:` line for a third-party action in `.github/workflows/*.yml` is pinned to a 40-character commit SHA.
- [ ] Each pinned line carries a trailing `# v<tag>` comment so the human-readable version is still visible.
- [ ] No regressions in required PR checks after the repin.

## Notes

`actions/*` (first-party GitHub) lines are also flagged for consistency with the repo convention; downgrade to `wontfix` per line if the reviewer decides tag pinning is acceptable for first-party actions only.
