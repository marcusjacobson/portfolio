#Requires -Version 7.0
<#
.SYNOPSIS
    Applies branch protection rules to `main` via the GitHub API.

.DESCRIPTION
    Enforces the rollout settings from the implementation plan:
      - Requires PRs (no direct push to main)
      - Requires all listed status checks to pass and be up to date
      - Requires linear history
      - Disallows force pushes and deletions
      - Dismisses stale reviews on new commits
      - Requires at least 1 review (set to 0 if you're solo)

    Run this AFTER each required check has run successfully on main at least once,
    otherwise GitHub will reject contexts that have never reported.

.PARAMETER Repo
    owner/name. Defaults to the current repo from `gh repo view`.

.PARAMETER Reviewers
    Required approving review count. Default 0 (solo dev). Set to 1+ for teams.

.PARAMETER DryRun
    Show the payload that would be sent without applying.

.EXAMPLE
    ./scripts/apply-branch-protection.ps1 -DryRun

.EXAMPLE
    ./scripts/apply-branch-protection.ps1 -Reviewers 1
#>
[CmdletBinding()]
param(
    [string]$Repo,
    [int]$Reviewers = 0,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is required. Install from https://cli.github.com/"
}

if (-not $Repo) {
    $Repo = (gh repo view --json nameWithOwner -q .nameWithOwner) 2>$null
    if (-not $Repo) { throw "Could not detect repo. Pass -Repo owner/name." }
}

$contexts = @(
    'build',                # pages-deploy
    'lint',                 # html-css-lint
    'lychee',               # link-check
    'playwright',           # visual-regression
    'analyze',              # codeql
    'scan'                  # gitleaks
)

$payload = @{
    required_status_checks = @{
        strict = $true
        contexts = $contexts
    }
    enforce_admins = $true
    required_pull_request_reviews = @{
        dismiss_stale_reviews = $true
        require_code_owner_reviews = $false
        required_approving_review_count = $Reviewers
    }
    restrictions = $null
    required_linear_history = $true
    allow_force_pushes = $false
    allow_deletions = $false
    block_creations = $false
    required_conversation_resolution = $true
    lock_branch = $false
    allow_fork_syncing = $false
} | ConvertTo-Json -Depth 6

Write-Host "Repo:      $Repo" -ForegroundColor Cyan
Write-Host "Branch:    main" -ForegroundColor Cyan
Write-Host "Reviewers: $Reviewers" -ForegroundColor Cyan
Write-Host "Checks:    $($contexts -join ', ')" -ForegroundColor Cyan
Write-Host ''
Write-Host $payload

if ($DryRun) {
    Write-Host ''
    Write-Host '[DryRun] No changes applied.' -ForegroundColor Yellow
    return
}

$tmp = New-TemporaryFile
$payload | Set-Content -Path $tmp -Encoding utf8
try {
    gh api -X PUT "repos/$Repo/branches/main/protection" --input $tmp
    Write-Host ''
    Write-Host 'Branch protection applied.' -ForegroundColor Green
} finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
}
