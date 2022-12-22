function Get-ConditionalAccessPolicies {

    [cmdletbinding()]

    $graphApiVersion = "v1.0"
    $CA_resource = "identity/conditionalAccess/policies"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($CA_resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }
}