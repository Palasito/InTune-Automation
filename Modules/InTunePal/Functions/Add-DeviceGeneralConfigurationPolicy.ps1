Function Add-DeviceGeneralConfigurationPolicy() {

    [cmdletbinding()]

    param
    (
        $JSON
    )

    $graphApiVersion = "Beta"
    $GDCP_resource = "deviceManagement/deviceConfigurations"
    Write-Verbose "Resource: $GDCP_resource"

    try {

        if ($JSON -eq "" -or $null -eq $JSON) {

            write-host "No JSON specified, please specify valid JSON for the Device Configuration Policy..." -f Red

        }

        else {

            Test-JSON -JSON $JSON

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($GDCP_resource)"
            $null = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"

        }

    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request for policy $(($JSON | ConvertFrom-Json).displayName) to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host

    }

}