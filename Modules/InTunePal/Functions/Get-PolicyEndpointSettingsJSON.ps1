Function Get-PolicyEndpointSettingsJSON() {

    param(
        $Policies
    )

    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/intents"

    try {

        $Policyid = $Policies.id
        #$PolicyJSON = $Policy | ConvertTo-Json -depth 5
        $uri_settings = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)/$($Policyid)/settings"
        $Settings = (Invoke-RestMethod -Uri $uri_settings -Headers $authToken -Method Get).Value

        return $Settings
    }

    catch {

    }
}