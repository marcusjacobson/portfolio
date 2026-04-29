## Source

GitHub Actions security hardening — <https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions>

> Pinning an action to a full length commit SHA is currently the only way to use an action as an immutable release. Pinning to a particular SHA helps mitigate the risk of a bad actor adding a backdoor to the action's repository.

## Why it matters

The same SHA-pin guidance applies to **reusable workflow** references (`uses: <owner>/<repo>/.github/workflows/<wf>.yml@<ref>`), not just composite/Docker actions. A scan of `.github/workflows/*.yml` found __COUNT__ reusable-workflow `uses:` reference(s) where the ref after `@` is not a 40-character commit SHA. Tag-pinned reusable workflows can be retargeted by the upstream maintainer (or an attacker who compromises the maintainer) without any change in this repo.

## Suggested change

Replace each tag/branch ref below with the commit SHA of the release that tag currently points to, and add a trailing `# v<x.y.z>` comment so the version is still legible during review.

Findings:

__FINDINGS__

## Acceptance criteria

- [ ] Every reusable-workflow `uses:` reference in `.github/workflows/*.yml` is pinned to a 40-character commit SHA.
- [ ] Each pinned line carries a trailing `# v<tag>` comment so the human-readable version is still visible.
- [ ] No regressions in required PR checks after the repin.
