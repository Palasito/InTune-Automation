Function Add-DeviceSettingsCatalogConfigurationPolicy() {

    [cmdletbinding()]

    param
    (
        $JSON
    )

    $DSC_resource = "deviceManagement/configurationPolicies"
    Write-Verbose "Resource: $DSC_resource"

    try {

        if ($JSON -eq "" -or $null -eq $JSON) {

            write-host "No JSON specified, please specify valid JSON for the Device Configuration Policy..." -f Red

        }

        else {

            Test-JSON -JSON $JSON

            $uri = "https://graph.microsoft.com/Beta/$($DSC_resource)"
            Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"

        }

    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }
}