Function Get-GeneralDeviceConfigurationPolicy() {

    [cmdletbinding()]

    $graphApiVersion = "Beta"
    $GDC_resource = "deviceManagement/deviceConfigurations"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($GDC_resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break

    }

}