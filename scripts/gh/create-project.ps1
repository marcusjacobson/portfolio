#Requires -Version 7.0
<#
.SYNOPSIS
    Create the "Portfolio" GitHub Project (v2) for the repo if it doesn't exist
    and link it to the repo.
.PARAMETER Owner
    User or org owner. Defaults to the current repo owner.
.PARAMETER Title
    Project title. Default: "Portfolio".
#>
[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Title = 'Portfolio'
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "gh CLI required." }
if (-not $Owner) { $Owner = (gh repo view --json owner -q .owner.login) }

$existing = gh project list --owner $Owner --format json | ConvertFrom-Json
$match = $existing.projects | Where-Object { $_.title -eq $Title }

if ($match) {
    Write-Host "Project '$Title' already exists: $($match.url)" -ForegroundColor Yellow
} else {
    Write-Host "Creating project '$Title' under $Owner..."
    $created = gh project create --owner $Owner --title $Title --format json | ConvertFrom-Json
    Write-Host "Created: $($created.url)" -ForegroundColor Green
}
