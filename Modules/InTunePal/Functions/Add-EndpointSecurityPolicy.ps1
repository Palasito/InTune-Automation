Function Add-EndpointSecurityPolicy() {

    [cmdletbinding()]

    param
    (
        $TemplateId,
        $JSON
    )

    $graphApiVersion = "Beta"
    $ESP_resource = "deviceManagement/templates/$TemplateId/createInstance"
    Write-Verbose "Resource: $ESP_resource"

    try {

        if ($JSON -eq "" -or $null -eq $JSON) {

            write-host "No JSON specified, please specify valid JSON for the Endpoint Security Policy..." -f Red

        }

        else {

            Test-JSON -JSON $JSON

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($ESP_resource)"
            Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"

        }

    }
    
    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
    }

}