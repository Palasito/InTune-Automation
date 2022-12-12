function Get-Groups {

    [cmdletbinding()]

    $graphApiVersion = "v1.0"
    $GR_resource = "groups"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($GR_resource)?$select=displayName,id"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }
}