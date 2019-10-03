function Connect-NextcloudServer {
    [cmdletbinding()]
    param(
        $Username,
        $Password,
        $Server,
        [switch]$NoSSL
    )
    
    $creds = "$($Username):$($Password)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($creds))
    $basicAuthValue = "Basic $encodedCreds" 
    $Headers = @{
        Authorization = $basicAuthValue
        'OCS-APIRequest' = 'true'
    }

    if($NoSSL){
        $UrlPrefix = 'http://'
    }
    else{
        $UrlPrefix = 'https://'
    }
    
    $NextcloudBaseURL = $UrlPrefix + $Server
    Write-Verbose "NextcloudBaseURL: $NextcloudBaseURL"


    try{
        $r = Invoke-RestMethod -Method Get -Headers $Headers -Uri "$NextcloudBaseURL/ocs/v1.php/cloud/users?search=&format=json&limit=1"
    }
    catch{
        Write-Error "Nextcloud Server could not be contacted please check the server URL: $NextcloudBaseURL"
    }

    
    if($r.ocs.meta.status -eq 'ok'){
        Write-host "Connected to Nextcloud Server: $Server"
        $Global:NextcloudAuthHeaders = $Headers
        $Global:NextcloudBaseURL = $NextcloudBaseURL
    }
    else{
        Write-Host "Failed to Authenticate to Nextcloud Server: $Server"
    }
}

function Get-NextcloudUser {
    [cmdletbinding()]

    $r = Invoke-RestMethod -Method Get -Headers $Global:NextcloudAuthHeaders -Uri "$($Global:NextcloudBaseURL)/ocs/v1.php/cloud/users?search=&format=json"
    $rf = $r.ocs.data.users |Select-Object @{l='Users';e={$_}}
    return $rf
}