Function Get-DeviceAdministrativeTemplatesJSON() {
    param(
        $Policies,
        $ExportPath
    )

    try {
        $uri = "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations/$($Policies.id)/definitionValues"
        $PolicyDefinitionValues = (Invoke-RestMethod -Method Get -Headers $authToken -Uri $uri).value
        $DefinitionValues = @()

        foreach ($d in $PolicyDefinitionValues) {
            $definition = Invoke-RestMethod -Method Get -Headers $authToken -Uri "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations/$($Policies.id)/definitionValues/$($d.id)/definition"
            $PresentationValues = (Invoke-RestMethod -Method Get -Headers $authToken -Uri "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations/$($Policies.id)/definitionValues/$($d.id)/presentationValues?`$expand=presentation").Value | Select-Object -Property * -ExcludeProperty lastModifiedDateTime, createdDateTime

            $DefValue = @{
                "enabled"               = $d.enabled
                "definition@odata.bind" = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('$($definition.id)')"
            }

            if ($PresentationValues.value) {
                $DefValue."presentationValues" = @()
                foreach ($val in $PresentationValues) {
                    $DefValue."presentationValues" += @{
                        "@odata.type"             = $val.'@odata.type'
                        "value"                   = $val.value
                        "presentation@odata.bind" = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('$($definition.id)')/presentations('$($val.presentation.id)')"
                    }
                }
            }

            elseif ($PresentationValues.values) {
                $DefValue."presentationValues" = @(
                    @{
                        "@odata.type"             = $PresentationValues.'@odata.type'
                        "values"                  = @(
                            foreach ($val in $PresentationValues.values) {
                                @{
                                    "name"  = $val.name
                                    "value" = $val.value
                                }
                            }
                        )
                        "presentation@odata.bind" = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('$($definition.id)')/presentations('$($PresentationValues.presentation.id)')"
                    }
                )
            }
            $DefinitionValues += $DefValue
        }

        $FinalPolicyJSON = @{
            "displayName" = $Policies.displayName
            "description" = $Policies.description
            "definitionValues" = $DefinitionValues
        }

        $DisplayName = $Policies.DisplayName
        $DisplayName = $DisplayName.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $FileName_JSON = "AT" + "_" + "$($DisplayName)" + ".json"
        $FinalJSON = $FinalPolicyJSON | ConvertTo-Json -Depth 20
        $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_JSON"

    }

    catch {

        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    }
}