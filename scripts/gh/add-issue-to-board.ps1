#Requires -Version 7.0
<#
.SYNOPSIS
    Add a GitHub issue or PR to a board (Projects v2) by URL.
.DESCRIPTION
    Resolves the project number and owner from -BoardUrl, then calls
    `gh project item-add <number> --owner <owner> --url <ItemUrl>`.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$BoardUrl,
    [Parameter(Mandatory)][string]$ItemUrl
)
$ErrorActionPreference = 'Stop'

# Expect URLs of the form https://github.com/(users|orgs)/<owner>/projects/<number>
if ($BoardUrl -notmatch 'github\.com/(?:users|orgs)/(?<owner>[^/]+)/projects/(?<number>\d+)') {
    throw "BoardUrl is not a Projects v2 URL: $BoardUrl"
}
$owner = $Matches.owner
$number = [int]$Matches.number

gh project item-add $number --owner $owner --url $ItemUrl
