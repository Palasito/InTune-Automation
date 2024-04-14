Function Add-EndpointSecurityPolicy() {

    [cmdletbinding()]

    param
    (
        $JSON
    )

    $ESP_resource = "deviceManagement/configurationPolicies"

    try {

        if ($JSON -eq "" -or $null -eq $JSON) {

            write-host "No JSON specified, please specify valid JSON for the Endpoint Security Policy..." -f Red

        }

        else {

            $null = Test-JSON -JSON $JSON

            $uri = "https://graph.microsoft.com/Beta/$($ESP_resource)"
            $null = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"

        }

    }
    
    catch {

        $ex = $_.Exception
        Write-Host "Request for policy $(($JSON | ConvertFrom-Json).name) to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)" -ForegroundColor Red
    }

}