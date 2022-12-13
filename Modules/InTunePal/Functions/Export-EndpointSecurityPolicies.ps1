function Export-EndpointSecurityPolicies {
    param (
        $Path
    )

    #Region Authentication 
    if ($global:authToken) {
        #Do nothing
    }
    else {
        $null = Get-Token
    }
    #endregion

    ########################################################################################

    $ExportPath = $Path
    
    if (!(Test-Path "$Path")) {

        Write-Host
        Write-Host "Path '$Path' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow
    
        $Confirm = read-host
    
        if ($Confirm -eq "y" -or $Confirm -eq "Y") {
    
            new-item -ItemType Directory -Path "$Path" | Out-Null
            Write-Host
    
        }

        else {

            Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
            Write-Host
            break

        }

    }

    ########################################################################################

    if (-not (Test-Path "$ExportPath\EndpointSecurityPolicies")) {
        $null = New-Item -Path "$ExportPath\EndpointSecurityPolicies" -ItemType Directory
    }

    ########################################################################################

    $uri = 'https://graph.microsoft.com/beta/deviceManagement/intents'

    $EPP = (Invoke-RestMethod -Method GET -Headers $authToken -Uri $uri).value

    Write-Host
    Write-Host "Exporting Device Endpoint Security Policies..." -ForegroundColor cyan
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
        $FinalJSON | Set-Content -LiteralPath "$($Path)\EndpointSecurityPolicies\$($FileName_FinalJSON)"

        Write-Host "Exported Endpoint Security Policy: $($e.displayName)"
    }
}