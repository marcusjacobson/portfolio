#Requires -Version 7.0
<#
.SYNOPSIS
    DEPRECATED shim. Forwards to scripts/gh/add-issue-to-board.ps1.
.DESCRIPTION
    Renamed as part of the GitHub Projects v2 → "board" terminology split.
    The -ProjectUrl parameter is renamed to -BoardUrl in the new script;
    this shim still accepts -ProjectUrl for back-compat and forwards it.
    This shim will be removed on or after 2026-07-01 (tracked in issue #91).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectUrl,
    [Parameter(Mandatory)][string]$ItemUrl
)

Write-Warning "scripts/gh/add-issue-to-project.ps1 is deprecated and will be removed on or after 2026-07-01. Use scripts/gh/add-issue-to-board.ps1 with -BoardUrl instead."

$forward = Join-Path $PSScriptRoot 'add-issue-to-board.ps1'
& $forward -BoardUrl $ProjectUrl -ItemUrl $ItemUrl
