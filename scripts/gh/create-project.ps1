#Requires -Version 7.0
<#
.SYNOPSIS
    DEPRECATED shim. Forwards to scripts/gh/create-board.ps1.
.DESCRIPTION
    Renamed as part of the GitHub Projects v2 → "board" terminology split.
    This shim will be removed on or after 2026-07-01 (tracked in issue #91).
#>
[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Title = 'Portfolio'
)

Write-Warning "scripts/gh/create-project.ps1 is deprecated and will be removed on or after 2026-07-01. Use scripts/gh/create-board.ps1 instead."

$forward = Join-Path $PSScriptRoot 'create-board.ps1'
$splat = @{ Title = $Title }
if ($Owner) { $splat.Owner = $Owner }
& $forward @splat
