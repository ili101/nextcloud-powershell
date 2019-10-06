#Requires -Modules Pester
[CmdletBinding()]
param (
    [PSCredential]$Credential = $NextcloudCredential,
    [string]$Server = $NextcloudServer
)
Write-Host 'p1'
if ($env:AGENT_NAME) {
    Write-Host 'p11'

    Write-Host 'p13'
}