Function Get-ManagedAppPolicy() {
    
    [cmdletbinding()]
    
    param
    (
        $Name
    )
    
    $graphApiVersion = "Beta"
    $Resource = "deviceAppManagement/managedAppPolicies"
    
    try {
        
        if ($Name) {
        
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") }
        
        }
        
        else {
        
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("ManagedAppProtection") -or ($_.'@odata.type').contains("InformationProtectionPolicy") }
        
        }
        
    }
        
    catch {
        
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break
        
    }
        
}