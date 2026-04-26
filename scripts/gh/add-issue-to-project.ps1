#Requires -Version 7.0
<#
.SYNOPSIS
    Add a GitHub issue or PR to a Project (v2) by URL.
.DESCRIPTION
    Resolves the project number and owner from -ProjectUrl, then calls
    `gh project item-add <number> --owner <owner> --url <ItemUrl>`.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectUrl,
    [Parameter(Mandatory)][string]$ItemUrl
)
$ErrorActionPreference = 'Stop'

# Expect URLs of the form https://github.com/(users|orgs)/<owner>/projects/<number>
if ($ProjectUrl -notmatch 'github\.com/(?:users|orgs)/(?<owner>[^/]+)/projects/(?<number>\d+)') {
    throw "ProjectUrl is not a Projects v2 URL: $ProjectUrl"
}
$owner = $Matches.owner
$number = [int]$Matches.number

gh project item-add $number --owner $owner --url $ItemUrl
