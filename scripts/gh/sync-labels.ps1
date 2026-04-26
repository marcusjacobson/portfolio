#Requires -Version 7.0
<#
.SYNOPSIS
    Sync the canonical label set in .github/labels.yml to the GitHub repo.
.DESCRIPTION
    Creates missing labels, updates color/description on existing labels,
    and (with -Prune) deletes labels not in the manifest.
.PARAMETER Repo
    owner/name. Defaults to current repo.
.PARAMETER Prune
    Delete labels that exist in GitHub but not in labels.yml.
.PARAMETER DryRun
    Show actions without applying.
#>
[CmdletBinding()]
param(
    [string]$Repo,
    [switch]$Prune,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "gh CLI required." }
if (-not $Repo) { $Repo = (gh repo view --json nameWithOwner -q .nameWithOwner) }

$manifestPath = Join-Path $PSScriptRoot '..\..\.github\labels.yml' | Resolve-Path
$lines = Get-Content $manifestPath
$entries = @()
$current = $null
foreach ($line in $lines) {
    if ($line -match '^\s*#') { continue }
    if ($line -match '^- name:\s*(.+?)\s*$') {
        if ($current) { $entries += [pscustomobject]$current }
        $current = @{ name = $Matches[1].Trim('"').Trim("'"); color = ''; description = '' }
    } elseif ($line -match '^\s+color:\s*(.+?)\s*$') {
        $current.color = $Matches[1].Trim('"').Trim("'")
    } elseif ($line -match '^\s+description:\s*(.+?)\s*$') {
        $current.description = $Matches[1].Trim('"').Trim("'")
    }
}
if ($current) { $entries += [pscustomobject]$current }

Write-Host "Manifest: $($entries.Count) labels" -ForegroundColor Cyan

$existing = gh label list --repo $Repo --limit 200 --json name,color,description | ConvertFrom-Json
$existingMap = @{}
foreach ($l in $existing) { $existingMap[$l.name] = $l }

foreach ($e in $entries) {
    if ($existingMap.ContainsKey($e.name)) {
        $cur = $existingMap[$e.name]
        if ($cur.color -ne $e.color -or $cur.description -ne $e.description) {
            Write-Host "UPDATE $($e.name)" -ForegroundColor Yellow
            if (-not $DryRun) {
                gh label edit $e.name --repo $Repo --color $e.color --description $e.description | Out-Null
            }
        } else {
            Write-Host "OK     $($e.name)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "CREATE $($e.name)" -ForegroundColor Green
        if (-not $DryRun) {
            gh label create $e.name --repo $Repo --color $e.color --description $e.description | Out-Null
        }
    }
}

if ($Prune) {
    $manifestNames = $entries | ForEach-Object { $_.name }
    foreach ($l in $existing) {
        if ($manifestNames -notcontains $l.name) {
            Write-Host "DELETE $($l.name)" -ForegroundColor Red
            if (-not $DryRun) {
                gh label delete $l.name --repo $Repo --yes | Out-Null
            }
        }
    }
}
