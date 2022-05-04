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

# ---------------------------------------------------------------------------------------------------------

function Export-EndpointPolicies {
    param (
        $Path
    )
    

    Get-Tokens

    $uri = 'https://graph.microsoft.com/beta/deviceManagement/intents'

    $EPP = (Invoke-RestMethod -Method GET -Headers $authToken -Uri $uri).value

    foreach ($e in $EPP) {

        $Settings = Get-PolicyEndpointSettingsJSON -Policies $e

        $PolicyJSON = [pscustomobject]@{
            DisplayName   = $e.displayName
            Description   = $e.description
            Platforms     = $e.platforms
            settingsDelta = $Settings
            templateId    = $e.TemplateId
        }

        $FinalJSONdisplayName = $e.displayName

        $FinalJSONDisplayName = $FinalJSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $FileName_FinalJSON = "$FinalJSONDisplayName" + ".json"

        $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 20
        $FinalJSON | Set-Content -LiteralPath "$($Path)\$($FileName_FinalJSON)"
            
    }
}