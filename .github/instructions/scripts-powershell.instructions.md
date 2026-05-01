---
description: "Use when authoring or editing PowerShell ops scripts under scripts/. Covers strict-mode requirements, gh CLI flag-shape gotchas, Projects v2 token scope, and idempotency conventions."
applyTo: "scripts/**/*.ps1"
---

# PowerShell ops script rules

## Required header

```powershell
#Requires -Version 7.0
<#
.SYNOPSIS
    One-line summary.
.DESCRIPTION
    What it does, when to run it, side effects.
#>
[CmdletBinding()]
param( ... )
$ErrorActionPreference = 'Stop'
```

- All scripts run on PowerShell 7+ (matches the GitHub Actions `windows-latest` and our local pwsh).
- Use `[CmdletBinding()]` + typed `param()` blocks. No positional bareword args.
- Always set `$ErrorActionPreference = 'Stop'` so a failed `gh` call aborts the script instead of silently continuing.
- Prefer `-DryRun` switches for any script that mutates GitHub state (issues, labels, branch protection, project items).

## `gh` CLI flag-shape gotchas (verified gh ≥ 2.90)

These are easy to get wrong. The failure modes are silent or misleading — keep them straight.

| Command | Correct shape | Wrong shape that fails silently or misleadingly |
|---------|---------------|-------------------------------------------------|
| `gh project item-add` | `<number> --owner <owner> --url <issue-or-pr-url>` | `--content-url` (removed in 2.x) |
| `gh project item-create` | `<number> --owner <owner> --title '...' --body $bodyText` (read with `Get-Content -Raw`) | `--body-file` (does not exist on `item-create`; only on `gh issue create`) |
| `gh project item-delete` | `<number> --owner <owner> --id <PVTI_...>` | `--project-id <PVT_...>` (only valid on `item-edit`, not `item-delete`) |
| `gh project item-edit` | `--project-id <PVT_...> --id <PVTI_...> --field-id <PVTSSF_...> --single-select-option-id <...>` | mixing project number with `--project-id` |
| `gh api` boolean fields | `@{ enabled = $true } | ConvertTo-Json | gh api ... --input -` | `-f enabled=true` (sends string `"true"` → 422) |

When in doubt, run `gh <verb> <noun> --help` before guessing flags.

## GitHub Projects v2 token scope

- The default `GITHUB_TOKEN` in workflows **cannot** write Projects v2 fields. Use the repo secret `BUG_PROJECT_TOKEN` (classic PAT, `project` scope; `repo` if private).
- **Fine-grained PATs do not work** for user-owned Projects v2. The "Projects" account permission is unreliable and fails with `Resource not accessible by personal access token`. Stick to classic PATs.
- `BUG_PROJECT_TOKEN` is intentionally narrow: `project` scope only. It **cannot** mutate issue labels (`addLabelsToLabelable` requires `public_repo` or `repo`). Workflows that need both must split: probe with `BUG_PROJECT_TOKEN`, edit issue state with the default `secrets.GITHUB_TOKEN` + `permissions: issues: write`. Do **not** widen the PAT.

## Listing project items — `item-list` is unreliable

`gh project item-list <n> --owner <owner>` returns `totalCount: 0` even when items exist (verified gh 2.90.0, 2026-04). The same lag is reproducible across boards and during GitHub Projects v2 indexing incidents. Do not trust empty results.

Canonical ground truth — query from the issue side:

```powershell
gh api graphql -f query='
  query($owner:String!,$name:String!,$num:Int!){
    repository(owner:$owner,name:$name){
      issue(number:$num){ projectItems(first:20){ nodes{ project{ number title } } } }
    }
  }' -f owner=marcusjacobson -f name=portfolio -F num=$IssueNumber
```

## Idempotency

- A script that adds an item to a board, applies a label, or syncs a config must be safe to re-run. Check existence before mutating; treat "already there" as success.
- Branch protection (`apply-branch-protection.ps1`): only run after each required check has reported on `main` at least once, or GitHub rejects contexts that have never registered.

## Required-status-check naming

When updating `apply-branch-protection.ps1`'s required-context list:

- Matrix jobs render as `<jobname> (<matrix-param>)`. Example: `analyze (javascript-typescript)`, **not** `analyze`.
- A workflow with a `paths:` filter that sometimes doesn't run (e.g., `build` from `pages-deploy.yml` on docs-only PRs) **cannot** be a required context, or PRs deadlock waiting for a check that never registers.

## Output

- Use `Write-Host` for human-facing progress, `Write-Output` only for values you intend to be captured by callers.
- Echo the resolved values (resolved owner/number, payload preview) before mutating, especially in `-DryRun` mode.
