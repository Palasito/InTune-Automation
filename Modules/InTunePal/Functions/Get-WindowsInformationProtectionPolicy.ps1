Function Get-WindowsInformationProtectionPolicy() {
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceAppManagement/windowsInformationProtectionPolicies"
        
    try {
        
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
    }
        
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    
    }
    
}