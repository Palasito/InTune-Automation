Function Get-GeneralDeviceConfigurationPolicyJSON() {

    param(
        $Policies,
        $ExportPath
    )
    
    try {

        if (($Policies.'@odata.type' -eq '#microsoft.graph.windows10CustomConfiguration') -and ($Policies.omaSettings | Where-Object { $_.isEncrypted -contains $true } )) {
            
            $Policyid = $Policies.id
            $uri_value = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Policyid)/getOmaSettingPlainTextValue(secretReferenceValueId='$($Policies.omaSettings.secretReferenceValueId)')"
            $value = (Invoke-RestMethod -Uri $uri_value -Headers $authToken -Method Get).Value
            $omaSettings = @()
            foreach ($oma in $Policies.omaSettings) {
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

            $FinalJSONDisplayName = $FinalJSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

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
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    }

}