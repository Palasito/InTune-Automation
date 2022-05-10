function Export-EndpointSecurityPolicies {
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