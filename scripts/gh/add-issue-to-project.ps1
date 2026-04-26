#Requires -Version 7.0
<#
.SYNOPSIS
    Add a GitHub issue or PR to a Project (v2) by URL.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectUrl,
    [Parameter(Mandatory)][string]$ItemUrl
)
$ErrorActionPreference = 'Stop'
gh project item-add --url $ProjectUrl --content-url $ItemUrl
