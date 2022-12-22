Function Add-MDMApplication() {
    [cmdletbinding()]
    param
    (
        $JSON
    )

    $graphApiVersion = "Beta"
    $App_resource = "deviceAppManagement/mobileApps"

    try {

        if (!$JSON) {

            write-host "No JSON was passed to the function, provide a JSON variable" -f Red
            break

        }

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($App_resource)"
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JSON -Headers $authToken

    }

    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
    }

}