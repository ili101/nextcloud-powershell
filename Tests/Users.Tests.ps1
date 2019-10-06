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
else {
    if (!$Credential) {
        $Credential = $Global:NextcloudCredential = Get-Credential
    }
    if (!$Server) {
        $Server = $Global:NextcloudServer = Read-Host -Prompt 'Nextcloud Server'
    }
}
Write-Host 'p2'
Describe 'Users' {
    BeforeEach {
        $FailedCount = InModuleScope -ModuleName Pester { $Pester.FailedCount }
        if ($FailedCount -gt 0) {
            Set-ItResult -Skipped -Because 'Previous test failed'
        }
    }
    Write-Host 'p3'
    $UserIdAdmin = $Credential.UserName
    $UserIdTest1 = "{0}-{1}-Test1" -f $UserIdAdmin, $(if ($env:System_JobDisplayName) { $env:System_JobDisplayName } else { 'Local' })
    It 'Connect-NextcloudServer' {
        Write-Host 'p4'
        Connect-NextcloudServer -Server $Server -Credential $Credential | Should -BeNullOrEmpty
        Write-Host 'p5'
    }
    It 'Get-NextcloudUser' {
        $User = Get-NextcloudUser -UserID $UserIdAdmin
        $User.id | Should -Be $UserIdAdmin
    }
    It 'Add-NextcloudUser' {
        try {
            Remove-NextcloudUser -UserID $UserIdTest1
        }
        catch {
            Write-Verbose $_
        }
        Add-NextcloudUser -UserID $UserIdTest1 -Password New-Guid | Should -BeNullOrEmpty
        (Get-NextcloudUser -UserID $UserIdTest1).id | Should -Be $UserIdTest1

        { Add-NextcloudUser -UserID $UserIdTest1 -Password New-Guid } | Should -Throw -ExpectedMessage 'User already exists'
    }
    It 'Get-NextcloudUsers' {
        $Users = Get-NextcloudUser
        $Users.id | Should -Contain $UserIdAdmin
        $Users.id | Should -Contain $UserIdTest1
    }
    It 'Set-NextcloudUser' {
        Set-NextcloudUser -UserID $UserIdTest1 -Email 'me@example.com' | Should -BeNullOrEmpty
        (Get-NextcloudUser -UserID $UserIdTest1).email | Should -Be 'me@example.com'
    }
    It 'Remove-NextcloudUser' {
        Remove-NextcloudUser -UserID $UserIdTest1 | Should -BeNullOrEmpty
        { Remove-NextcloudUser -UserID $UserIdTest1 } | Should -Throw -ExpectedMessage '101'
        Get-NextcloudUser -UserID $UserIdTest1 | Should -BeNullOrEmpty
    }
}