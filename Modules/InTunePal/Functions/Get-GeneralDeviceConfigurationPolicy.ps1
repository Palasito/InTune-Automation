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
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}