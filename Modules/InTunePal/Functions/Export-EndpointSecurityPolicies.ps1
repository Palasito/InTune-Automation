Function Get-PolicyEndpointSettingsJSON() {

    param(
        $Policies
    )

    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/configurationPolicies"

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

    $uri = 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies'

    $EPP = (Invoke-RestMethod -Method GET -Headers $authToken -Uri $uri).value

    foreach ($e in $EPP) {

        if ($e.templateReference -match 'endpointSecurity') {

            $Settings = Get-PolicyEndpointSettingsJSON -Policies $e

            $templateReference = $e.templateReference
            $TemplateId = $templateReference.TemplateId
            $TemplateDispName = $templateReference.templateDisplayName

            $PolicyJSON = [pscustomobject]@{
                DisplayName         = $e.Name
                Description         = $e.description
                Platforms           = $e.platforms
                technologies        = $e.technologies
                settings            = $Settings
                templateId          = $TemplateId
                templateDisplayName = $TemplateDispName
            }

            $FinalJSONdisplayName = $e.name

            $FinalJSONDisplayName = $FinalJSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

            $FileName_FinalJSON = "$FinalJSONDisplayName" + ".json"

            $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 20

            $FinalJSON | Set-Content -LiteralPath "C:\script\testout\$FileName_FinalJSON"
        }
    }
}

