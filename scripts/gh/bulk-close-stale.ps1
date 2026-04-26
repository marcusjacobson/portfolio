#Requires -Version 7.0
<#
.SYNOPSIS
    Close stale open issues (no update in N days) with a polite comment.
.PARAMETER Days
    Staleness threshold. Default 90.
.PARAMETER DryRun
    List the issues that WOULD be closed without closing.
#>
[CmdletBinding()]
param(
    [int]$Days = 90,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$cutoff = (Get-Date).AddDays(-$Days).ToString('yyyy-MM-dd')
$stale = gh issue list --state open --search "updated:<$cutoff" --limit 100 --json number,title,updatedAt | ConvertFrom-Json

if (-not $stale) { Write-Host "No stale issues older than $Days days." -ForegroundColor Green; return }

foreach ($i in $stale) {
    Write-Host "#$($i.number) ($($i.updatedAt)): $($i.title)"
    if (-not $DryRun) {
        gh issue comment $i.number --body "Closing as stale (no update in $Days+ days). Reopen if still relevant."
        gh issue close $i.number --reason "not planned"
    }
}
if ($DryRun) { Write-Host "[DryRun] No issues closed." -ForegroundColor Yellow }
