function Get-ObjectMatching {

    [cmdletbinding()]

    $graphApiVersion = "v1.0"
    $NL_resource = "directory/onPremisesSynchronization"
    
    try {
    
        $uri = "https://graph.microsoft.com/$($graphApiVersion)/$($NL_resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value[0]
    
    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break

    }
}