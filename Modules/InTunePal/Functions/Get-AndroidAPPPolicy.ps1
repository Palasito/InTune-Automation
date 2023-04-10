Function Get-AndroidAPPPolicy() {
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceAppManagement/androidManagedAppProtections"
        
    try {
        
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
    }
        
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break
    
    }
    
}