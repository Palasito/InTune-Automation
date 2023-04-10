Function Get-DeviceAdministrativeTemplates() {
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $DAT_Resource = "deviceManagement/groupPolicyConfigurations"
        
    try {
        
        $uri = "https://graph.microsoft.com/Beta/$($DAT_Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
        
    }
        
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break
    
    }
    
}

