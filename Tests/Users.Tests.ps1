#Requires -Modules Pester
[CmdletBinding()]
param (
    [PSCredential]$Credential = $NextcloudCredential,
    [string]$Server = $NextcloudServer
)
Write-Host 'p1'
if ($env:AGENT_NAME) {
    Write-Host 'p11'
    Write-Host ("NextcloudUser {0}" -f ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$(NextcloudUser)"))))
    Write-Host ("System_JobDisplayName {0}" -f ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$(NextcloudServer)"))))

    $Credential = [Management.Automation.PSCredential]::new("$(NextcloudUser)", (ConvertTo-SecureString "$(NextcloudPassword)" -AsPlainText -Force))
    Write-Host 'p12'
    $Server = "$(NextcloudServer)"
    Write-Host 'p13'
}