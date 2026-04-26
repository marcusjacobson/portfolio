#Requires -Version 7.0
<#
.SYNOPSIS
    Migrates HTML/CSS/JS content from the Claude "Portfolio" project into the repo root.

.DESCRIPTION
    Claude projects do not expose a programmatic export API, so the workflow is:
      1. Manually download the project files from Claude.
      2. Drop them into the repo's `staging-inbox/` folder (gitignored).
      3. Run this script to validate, diff, and copy them into place.

    The script:
      - Validates each .html file is well-formed (basic tag balance check).
      - Diffs against the existing file (if any) and prints a per-file summary.
      - Copies into the repo root, preserving the existing filename scheme.
      - Stages copied files with `git add -N` so you can review hunks before committing.

.PARAMETER Source
    Path to the staging folder containing the Claude export.
    Defaults to `<repo>/staging-inbox`.

.PARAMETER DryRun
    Show what would happen without modifying any files.

.PARAMETER Force
    Overwrite without prompting on filename conflicts.

.EXAMPLE
    ./scripts/migrate-from-claude.ps1 -DryRun

.EXAMPLE
    ./scripts/migrate-from-claude.ps1 -Source ./staging-inbox -Force
#>
[CmdletBinding()]
param(
    [string]$Source,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $Source) { $Source = Join-Path $repoRoot 'staging-inbox' }

if (-not (Test-Path $Source)) {
    throw "Source folder not found: $Source"
}

$files = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object { $_.Extension -in '.html', '.htm', '.css', '.js', '.svg', '.png', '.jpg', '.jpeg', '.webp', '.ico', '.txt', '.md' }

if (-not $files) {
    Write-Warning "No migratable files found under $Source"
    return
}

Write-Host "Found $($files.Count) candidate file(s) in $Source" -ForegroundColor Cyan

function Test-HtmlBalance {
    param([string]$Path)
    $content = Get-Content -Raw -Path $Path
    if ([string]::IsNullOrWhiteSpace($content)) { return @{ Ok = $false; Reason = 'empty file' } }
    $openCount = ([regex]::Matches($content, '(?i)<html\b')).Count
    $closeCount = ([regex]::Matches($content, '(?i)</html>')).Count
    if ($openCount -ne $closeCount) {
        return @{ Ok = $false; Reason = "html open/close mismatch ($openCount/$closeCount)" }
    }
    if ($openCount -eq 0) {
        return @{ Ok = $false; Reason = 'no <html> tag' }
    }
    return @{ Ok = $true }
}

$summary = [System.Collections.Generic.List[object]]::new()

foreach ($file in $files) {
    $relative = $file.FullName.Substring($Source.Length).TrimStart([char]'\', [char]'/')
    $destination = Join-Path $repoRoot $relative

    $status = 'new'
    $reason = ''

    if ($file.Extension -in '.html', '.htm') {
        $check = Test-HtmlBalance -Path $file.FullName
        if (-not $check.Ok) {
            $status = 'invalid'
            $reason = $check.Reason
        }
    }

    if ($status -ne 'invalid' -and (Test-Path $destination)) {
        $existingHash = (Get-FileHash -Path $destination -Algorithm SHA256).Hash
        $newHash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        if ($existingHash -eq $newHash) {
            $status = 'unchanged'
        } else {
            $status = 'updated'
        }
    }

    $summary.Add([pscustomobject]@{
        File = $relative
        Status = $status
        Reason = $reason
        Source = $file.FullName
        Destination = $destination
    })
}

Write-Host ''
$summary | Format-Table File, Status, Reason -AutoSize

$invalid = $summary | Where-Object Status -eq 'invalid'
if ($invalid) {
    Write-Error "$($invalid.Count) file(s) failed validation. Aborting before any copy."
    return
}

$toCopy = $summary | Where-Object Status -in 'new', 'updated'
if (-not $toCopy) {
    Write-Host 'Nothing to copy. All files are unchanged.' -ForegroundColor Green
    return
}

if ($DryRun) {
    Write-Host ''
    Write-Host "[DryRun] Would copy $($toCopy.Count) file(s). Re-run without -DryRun to apply." -ForegroundColor Yellow
    return
}

if (-not $Force) {
    $confirm = Read-Host "Copy $($toCopy.Count) file(s) into the repo? (y/N)"
    if ($confirm -notin 'y', 'Y') { Write-Host 'Aborted.' -ForegroundColor Yellow; return }
}

foreach ($entry in $toCopy) {
    $destDir = Split-Path -Parent $entry.Destination
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -Path $entry.Source -Destination $entry.Destination -Force
    Write-Host "  $($entry.Status.PadRight(9)) $($entry.File)" -ForegroundColor Green
}

Push-Location $repoRoot
try {
    git add -N -- $($toCopy | ForEach-Object { $_.Destination }) 2>$null | Out-Null
    Write-Host ''
    Write-Host 'Staged with `git add -N` (intent to add). Run `git diff` to review, then `git add` + `git commit`.' -ForegroundColor Cyan
} finally {
    Pop-Location
}
