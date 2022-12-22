Function Get-SoftwareUpdatePolicyAssignments() {
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    
    try {
    
        $Resource = "deviceManagement/deviceConfigurations"
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
    
    }
    
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    
    }
    
}