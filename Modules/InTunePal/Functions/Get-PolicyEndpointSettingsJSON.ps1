Function Get-PolicyEndpointSettingsJSON() {

    param(
        $Policies
    )

    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/intents"

    try {

        $Policyid = $Policies.id
        $uri_settings = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)/$($Policyid)/settings"
        $Settings = (Invoke-RestMethod -Uri $uri_settings -Headers $authToken -Method Get).Value

        return $Settings
    }

    catch {
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
    }
}