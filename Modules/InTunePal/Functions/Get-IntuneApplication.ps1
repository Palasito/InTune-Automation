Function Get-IntuneApplication() {
    [cmdletbinding()]
    param
    (
        $Name,
        $AppId
    )

    $graphApiVersion = "Beta"
    $Resource = "deviceAppManagement/mobileApps"

    try {

        if ($Name) {

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") -and (!($_.'@odata.type').Contains("managed")) -and (!($_.'@odata.type').Contains("#microsoft.graph.iosVppApp")) }

        }

        elseif ($AppId) {

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)/$AppId"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get)

        }

        else {

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { (!($_.'@odata.type').Contains("managed")) -and (!($_.'@odata.type').Contains("#microsoft.graph.iosVppApp")) -and (!($_.'@odata.type').Contains("#microsoft.graph.windowsAppX")) -and (!($_.'@odata.type').Contains("#microsoft.graph.androidForWorkApp")) -and (!($_.'@odata.type').Contains("#microsoft.graph.windowsMobileMSI")) -and (!($_.'@odata.type').Contains("#microsoft.graph.androidLobApp")) -and (!($_.'@odata.type').Contains("#microsoft.graph.iosLobApp")) -and (!($_.'@odata.type').Contains("#microsoft.graph.microsoftStoreForBusinessApp")) }

        }

    }

    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}