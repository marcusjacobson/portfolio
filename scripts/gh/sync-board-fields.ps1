#Requires -Version 7.0
<#
.SYNOPSIS
    Sync GitHub Projects v2 board field values from issue labels.

.DESCRIPTION
    Reads each item on a Projects v2 board and sets the board's Priority
    single-select field from the matching `priority:p*` label on the item.
    Idempotent: only mutates items whose current Priority differs from the
    label-derived target. Items without any `priority:p*` label are skipped
    (Priority is not cleared).

    Size is intentionally left manual per AC of issue #123 (no label source).

.NOTES
    `gh project item-list` on user-owned Projects v2 has been observed to
    return stale or empty results during indexing incidents. The GraphQL
    ground truth is `repository.issue.projectItems`. This script logs a
    warning if item-list returns 0 items so the operator can re-run.

    `gh project item-edit` flag shape (gh >= 2.x): --project-id <PVT_...>,
    --id <PVTI_...>, --field-id <PVTSSF_...>, --single-select-option-id <id>.

.PARAMETER Owner
    Project owner login. Defaults to marcusjacobson.

.PARAMETER BoardNumber
    Projects v2 board number. Defaults to 15 (Portfolio Maturity).

.PARAMETER ProjectId
    Project node id (PVT_*). Required for item-edit calls.

.PARAMETER PriorityFieldId
    Priority single-select field id (PVTSSF_*).

.PARAMETER DryRun
    Print intended mutations without calling item-edit.

.EXAMPLE
    pwsh ./scripts/gh/sync-board-fields.ps1
.EXAMPLE
    pwsh ./scripts/gh/sync-board-fields.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [string]$Owner = 'marcusjacobson',
    [int]$BoardNumber = 15,
    [string]$ProjectId = 'PVT_kwHOBvMdD84BV0V-',
    [string]$PriorityFieldId = 'PVTSSF_lAHOBvMdD84BV0V-zhRNVks',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

# Priority label suffix -> single-select option id (board #15)
$priorityOptions = @{
    'p0' = 'a67c8044'
    'p1' = 'ebd15b3d'
    'p2' = '3251be61'
    'p3' = 'b437bf9f'
}

Write-Host "Reading items from board #$BoardNumber (owner: $Owner)..."
$itemsJson = gh project item-list $BoardNumber --owner $Owner --format json --limit 200
if ($LASTEXITCODE -ne 0) { throw "gh project item-list failed (exit $LASTEXITCODE)" }
$items = ($itemsJson | ConvertFrom-Json).items

if (-not $items -or $items.Count -eq 0) {
    Write-Warning "item-list returned 0 items. This may be CLI staleness on user-owned Projects v2 (see repo memory). Re-run, or cross-check via repository.issue.projectItems GraphQL."
    return
}

$set = 0; $unchanged = 0; $skipped = 0

foreach ($item in $items) {
    $num = $item.content.number
    if (-not $num) { $skipped++; continue }

    $priorityLabel = $item.labels | Where-Object { $_ -match '^priority:(p[0-3])$' } | Select-Object -First 1
    if (-not $priorityLabel) {
        Write-Host "  #$num`: no priority:* label, skipped"
        $skipped++; continue
    }
    $target = ($priorityLabel -split ':')[1]
    $targetOptionId = $priorityOptions[$target]

    # `priority` only appears on the item when set; absent means empty.
    $current = $item.priority
    if ($current -eq $target) {
        Write-Host "  #$num`: already $target (unchanged)"
        $unchanged++; continue
    }

    $was = if ($current) { $current } else { '<empty>' }
    Write-Host "  #$num`: set Priority -> $target (was $was)"
    if (-not $DryRun) {
        gh project item-edit --project-id $ProjectId --id $item.id --field-id $PriorityFieldId --single-select-option-id $targetOptionId | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "item-edit failed for #$num (exit $LASTEXITCODE)" }
    }
    $set++
}

# TODO: Size is manual today (no label source). If a `size:*` label convention
# is introduced, extend this script to map it to the Size field
# (PVTSSF_lAHOBvMdD84BV0V-zhRNVkw) the same way Priority is handled.

Write-Host ""
Write-Host "Summary: set=$set unchanged=$unchanged skipped=$skipped"
