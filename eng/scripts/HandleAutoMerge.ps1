[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$label,
  [Parameter(Mandatory = $true)]
  [string]$pullRequestId,
  [string]$pullRequestNumber = $pullRequestId,
  [switch]$labelAdded
)
Set-StrictMode -Version 3

#Test commit


. $PSScriptRoot/Github-Project-Helpers.ps1

Write-Verbose $(gh api -H "Accept: application/vnd.github.v3+json" /rate_limit --jq '.resources')

if ($label -ne "auto-merge") {
  Write-Host "Skipping action because the label name is [$label] which is not [auto-merge]."
  exit 0
}

$succeeded = $true
if ($labelAdded) {
  Write-Host "Enabling auto merge for pull request $pullRequestNumber because [$label] was added."
  $succeeded = EnablePullRequestAutoMerge $pullRequestId
}
else {
  Write-Host "Disabling auto merge for pull request $pullRequestNumber because [$label] was removed."
  $succeeded = DisablePullRequestAutoMerge $pullRequestId
}

Write-Verbose (gh api -H "Accept: application/vnd.github.v3+json" /rate_limit --jq '.resources')

if (!$succeeded) {
  exit 1
}
exit 0
