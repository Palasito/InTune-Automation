Function Add-ManagedAppPolicy() {
    
    [cmdletbinding()]
    
    param
    (
        $JSON
    )
    
    $graphApiVersion = "Beta"
    $Resource = "deviceAppManagement/managedAppPolicies"
    
    try {
    
        if ($JSON -eq "" -or $null -eq $JSON) {
    
            write-host "No JSON specified, please specify valid JSON for a Managed App Policy..." -f Red
    
        }
    
        else {
    
            Test-JSON -JSON $JSON
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"
    
        }
    
    }
    
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
    }
    
}