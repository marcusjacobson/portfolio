## Source

GitHub repository labels — <https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels> — and the repo's canonical label manifest at `.github/labels.yml`, synced via `scripts/gh/sync-labels.ps1`.

> Labels are a way to categorize and filter issues, pull requests, and discussions. You can use the default labels in a repository, or create your own custom labels.

## Why it matters

`.github/labels.yml` is the source-of-truth for the portfolio's label vocabulary — every intake agent (`@request-intake`, `@bug-intake`, `@project-intake`, `@triage`) is told to "never invent labels" and pulls from this manifest. When the live repo label set drifts (a label was renamed in the UI, a new label was created ad-hoc by a workflow, or a color/description edit didn't make it back into the YAML), the agents either silently skip the label or apply something the maintainer didn't intend. The maturity-scout job diffed `.github/labels.yml` against `gh label list --limit 200`. **__COUNT__** divergence(s) found.

The check categorizes each divergence as one of:

- **missing in repo** — declared in YAML but no live label with that name. The next `sync-labels.ps1` run would create it; until then, intake agents will silently fail to apply it.
- **extra in repo** — exists in the repo but not in YAML. A `sync-labels.ps1` run **will not delete it** (the script is additive), so it will linger until removed by hand or added to YAML.
- **color mismatch** — same name, different 6-char hex.
- **description mismatch** — same name, different description text (empty string counts as a value).

## Suggested change

For each finding listed below:

- If the YAML is correct, run `pwsh scripts/gh/sync-labels.ps1` to push YAML back onto the repo (this fixes color/description mismatches and creates missing-in-repo labels). Extra-in-repo labels must be deleted manually with `gh label delete <name>` after confirming nothing references them.
- If the live state is the new intended vocabulary, update `.github/labels.yml` to match (preserve the existing section ordering and comments).

Findings (__COUNT__):

__FINDINGS__

## Acceptance criteria

- [ ] Every finding above is reconciled — either by editing `.github/labels.yml` or by re-running the sync.
- [ ] `gh label list --json name,color,description --limit 200` matches `.github/labels.yml` field-by-field for every label name in either set.
- [ ] No open issue or PR is left referencing a deleted label (check via `gh issue list --label <removed-name>` and `gh pr list --label <removed-name>`).

## Notes

Producer: `.github/workflows/maturity-scan.yml` step `scan_label_drift`. Color comparison is **string-exact** on the lowercase 6-char hex returned by the GitHub API; the YAML must use the same form (no leading `#`).
