Function Get-SoftwareUpdatePolicy() {
    
    [cmdletbinding()]
    
    param
    (
        [switch]$Windows10,
        [switch]$iOS
    )
    
    $graphApiVersion = "Beta"
    
    try {
    
        $Count_Params = 0
    
        if ($iOS.IsPresent) { $Count_Params++ }
        if ($Windows10.IsPresent) { $Count_Params++ }
    
        if ($Count_Params -gt 1) {
    
            write-host "Multiple parameters set, specify a single parameter -iOS or -Windows10 against the function" -f Red
    
        }
    
        elseif ($Count_Params -eq 0) {
    
            Write-Host "Parameter -iOS or -Windows10 required against the function..." -ForegroundColor Red
            Write-Host
            break
    
        }
    
        elseif ($Windows10) {
    
            $Resource = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.windowsUpdateForBusinessConfiguration')&`$expand=groupAssignments"
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
    
        }
    
        elseif ($iOS) {
    
            $Resource = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosUpdateConfiguration')&`$expand=groupAssignments"
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
        }
    
    }
    
    catch {
    
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break
    
    }
    
}