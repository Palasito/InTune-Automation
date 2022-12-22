Function Get-DeviceSettingsCatalogPolicyJSON() {

    param(
        $Policies,
        $ExportPath
    )

    $DSC_Resource = "deviceManagement/configurationPolicies"

    try {

        $Policyid = $Policies.id
        $uri_settings = "https://graph.microsoft.com/Beta/$($DSC_Resource)/$($Policyid)/settings"
        $Settings = (Invoke-RestMethod -Uri $uri_settings -Headers $authToken -Method Get).Value

        $PolicyJSON = [pscustomobject]@{
            name         = $Policies.Name
            description  = $Policies.description
            platforms    = $Policies.platforms
            technologies = $Policies.technologies
            settings     = $Settings
        }

        $FinalJSONdisplayName = $Policies.name
        $FinalJSONDisplayName = $FinalJSONDisplayName.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $FileName_FinalJSON = "SC" + "_" + "$FinalJSONDisplayName" + ".json"
        $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 20
        $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_FinalJSON"
            
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