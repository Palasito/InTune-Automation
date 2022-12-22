Function Get-DeviceCompliancePolicy() {
    
    [cmdletbinding()]
    
    param
    (
        $Name,
        [switch]$Android,
        [switch]$iOS,
        [switch]$Win10
    )
    
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceCompliancePolicies"
    
    try {
    
        $Count_Params = 0
    
        if ($Android.IsPresent) { $Count_Params++ }
        if ($iOS.IsPresent) { $Count_Params++ }
        if ($Win10.IsPresent) { $Count_Params++ }
        if ($Name.IsPresent) { $Count_Params++ }
    
        if ($Count_Params -gt 1) {
    
            write-host "Multiple parameters set, specify a single parameter -Android -iOS or -Win10 against the function" -f Red
    
        }
    
        elseif ($Android) {
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("android") }
    
        }
    
        elseif ($iOS) {
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("ios") }
    
        }
    
        elseif ($Win10) {
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("windows10CompliancePolicy") }
    
        }
    
        elseif ($Name) {
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") }
    
        }
    
        else {
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
        }
    
    }
    
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    
    }
    
}