#Requires -Version 7.0
<#
.SYNOPSIS
    Download the rendered site artifact from a PR and serve it on localhost.
.DESCRIPTION
    Resolves the most recent successful `pages-build.yml` run for the given
    PR, downloads its `site-preview` artifact, unpacks it under
    `staging-inbox/pr-<N>/`, and starts `npx http-server` on the requested
    port so the maintainer can click through the built site before merge.

    Requires `gh` (authenticated), Node.js (for `npx http-server`), and the
    PR's `pages-build` check to have completed at least once.
.PARAMETER Pr
    Pull request number to preview.
.PARAMETER Port
    Local port for the preview server. Default 8080.
.PARAMETER NoServe
    Download and unpack only; skip launching the server. Useful for CI
    smoke tests.
.EXAMPLE
    ./scripts/preview-pr.ps1 -Pr 312
    Downloads PR #312's preview and serves http://localhost:8080/.
.EXAMPLE
    ./scripts/preview-pr.ps1 -Pr 312 -Port 9000
    Same, on a different port.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][int]$Pr,
    [int]$Port = 8080,
    [switch]$NoServe
)
$ErrorActionPreference = 'Stop'

# 1. Resolve the PR's head SHA so we fetch the matching build run.
$headSha = gh pr view $Pr --json headRefOid --jq '.headRefOid' 2>$null
if (-not $headSha) {
    throw "Could not resolve PR #$Pr. Is it open and visible to your gh auth?"
}

# 2. Find the most recent successful pages-build.yml run for that SHA.
$run = gh run list `
    --workflow pages-build.yml `
    --commit $headSha `
    --status success `
    --limit 1 `
    --json databaseId,headBranch,createdAt `
    --jq '.[0]' | ConvertFrom-Json
if (-not $run) {
    throw "No successful pages-build run found for PR #$Pr (sha $headSha). Wait for the check to finish, then retry."
}
Write-Host "Found build run $($run.databaseId) on $($run.headBranch) (created $($run.createdAt))." -ForegroundColor Cyan

# 3. Download artifact into staging-inbox/pr-<N>/.
$dest = Join-Path -Path (Get-Location) -ChildPath "staging-inbox/pr-$Pr"
if (Test-Path $dest) {
    Write-Host "Refreshing $dest." -ForegroundColor DarkGray
    Remove-Item -Recurse -Force $dest
}
New-Item -ItemType Directory -Path $dest -Force | Out-Null
gh run download $run.databaseId --name site-preview --dir $dest
Write-Host "Artifact unpacked to $dest." -ForegroundColor Green

if ($NoServe) {
    Write-Host "Skipping server (-NoServe). Preview directory: $dest"
    return
}

# 4. Serve. http-server is small, transitive-free, and ships with npx.
Write-Host "Serving on http://localhost:$Port/  (Ctrl+C to stop)" -ForegroundColor Cyan
Push-Location $dest
try {
    npx --yes http-server -p $Port -c-1 .
} finally {
    Pop-Location
}
