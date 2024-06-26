Function Get-GeneralDeviceConfigurationPolicyJSON() {

    param(
        $Policies,
        $ExportPath
    )
    
    try {

        if (($Policies.'@odata.type' -eq '#microsoft.graph.windows10CustomConfiguration') -and ($Policies.omaSettings | Where-Object { $_.isEncrypted -contains $true } )) {
            
            $Policyid = $Policies.id
            $omaSettings = @()
            foreach ($oma in $Policies.omaSettings) {
                $uri_value = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Policyid)/getOmaSettingPlainTextValue(secretReferenceValueId='$($oma.secretReferenceValueId)')"
                $value = (Invoke-RestMethod -Uri $uri_value -Headers $authToken -Method Get).Value
                $newSetting = @{}
                $newSetting.'@odata.type' = $oma.'@odata.type'
                $newSetting.displayName = $oma.displayName
                $newSetting.description = $oma.description
                $newSetting.omaUri = $oma.omaUri
                $newSetting.value = $value
                $newSetting.isEncrypted = $false
                $newSetting.secretReferenceValueId = $null

                $omaSettings += $newSetting
            }
            $PolicyJSON = $Policies
            $PolicyJSON.omaSettings = @()
            $PolicyJSON.omaSettings = $omaSettings
            $FinalJSONdisplayName = $Policies.DisplayName
            $FinalJSONDisplayName = $FinalJSONDisplayName.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $FileName_FinalJSON = "GDC" + "_" + "$FinalJSONDisplayName" + ".json"
            $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 100
            $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_FinalJSON"
        }

        else {
            $DisplayName = $Policies.DisplayName
            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"
            $FileName_JSON = "GDC" + "_" + "$DisplayName" + ".json"
            $FinalJSON = $Policies | ConvertTo-Json -Depth 100
            $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_JSON"
        }


    }

    catch {

        $ex = $_.Exception
        Write-Error "Request to $($uri_value) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        write-host
        break
    }

}