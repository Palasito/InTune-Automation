Function Get-DeviceSettingsCatalogPolicy() {
    <#Explanation of function to be added#>

    [cmdletbinding()]

    $DSC_Resource = "deviceManagement/configurationPolicies"
    
    try {
    
        $uri = "https://graph.microsoft.com/Beta/$($DSC_Resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { $_.templateReference.templateFamily -notlike "endpointSecurity*" }

    }
    

    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break

    }

}