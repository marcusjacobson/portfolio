## Source

GitHub branch protection — <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches> — and the repo's own enforcement script `scripts/apply-branch-protection.ps1`.

> Protected branches ensure that collaborators in your repository cannot make irrevocable changes to branches. Working with protected branches, you can also enforce certain workflows or requirements before a collaborator can push changes to a branch in your repository.

## Why it matters

`scripts/apply-branch-protection.ps1` is the source-of-truth for `main`'s branch protection. When the live API state drifts from that baseline (a setting was toggled in the GitHub UI, a required-status-check context was renamed by a workflow change, or a new contributor flipped a knob), the script can no longer be re-run idempotently and the rollout intent encoded in the script is silently broken. The maturity-scout job re-fetched `/repos/${{ github.repository }}/branches/main/protection` and compared it field-by-field against the script. **__COUNT__** setting(s) diverged.

Required-status-check contexts are compared **string-exact** — matrix-rendered names like `analyze (javascript-typescript)` will not match `analyze`. That asymmetry is a known stored-memory gotcha for this repo and a frequent root-cause of "merge blocked despite all checks green" deadlocks.

## Suggested change

For each finding listed below, decide whether the **baseline** or the **live** value is correct, then:

- If the live value is the new intended state, update `scripts/apply-branch-protection.ps1` so a fresh run reproduces it.
- If the baseline is correct, re-run `pwsh scripts/apply-branch-protection.ps1` (with the appropriate `-Reviewers` value) to push the script back onto `main`.

Findings (__COUNT__):

__FINDINGS__

## Acceptance criteria

- [ ] Every finding above is either reconciled in `scripts/apply-branch-protection.ps1` or re-applied to the live branch protection.
- [ ] A dry-run of the script (`pwsh scripts/apply-branch-protection.ps1 -DryRun`) prints a payload that matches the live API state for every field listed above.
- [ ] No required PR check is broken by the reconciliation (verified by a follow-up PR running the full required-checks matrix).

## Notes

Producer: `.github/workflows/maturity-scan.yml` step `scan_branch_protection_drift`. Read access to `/branches/main/protection` requires only the default `GITHUB_TOKEN` granted via the workflow's `permissions:` block. No PAT widening required.
