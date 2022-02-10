Function Get-DeviceSettingsCatalogPolicy() {
    <#Explanation of function to be added#>

    [cmdletbinding()]

    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/configurationPolicies"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)"
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