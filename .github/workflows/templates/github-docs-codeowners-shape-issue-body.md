## Source

GitHub docs — About code owners — <https://docs.github.com/en/repositories/managing-your-repositories-settings-and-features/customizing-your-repository/about-code-owners>

> Each line in a CODEOWNERS file consists of a pattern followed by one or more owners. Owners must be listed using their GitHub username (prefixed with `@`) or an email address.

## Why it matters

A malformed `CODEOWNERS` file is silently ignored by GitHub for the offending lines, which means review routing breaks without any warning in the UI. A scan of the repo's `CODEOWNERS` file found __COUNT__ non-comment, non-blank line(s) that don't match the expected `<glob> @<owner>[ @<owner>...]` shape.

## Suggested change

Fix each line listed below so it parses as a glob followed by one or more `@owner` (or email) entries. Comments must start with `#`. Blank lines are allowed.

Findings:

__FINDINGS__

## Acceptance criteria

- [ ] Every non-comment, non-blank line in `CODEOWNERS` matches `<glob> @<owner>[ @<owner>...]`.
- [ ] The file still routes the intended reviewers for each path (sanity-check by opening a PR touching one of the affected globs).

## Notes

The scan does not flag overlapping globs (later rule shadowing earlier rule for the same path). Audit those manually if review routing seems off.
