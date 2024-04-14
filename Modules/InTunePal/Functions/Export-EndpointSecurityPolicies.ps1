function Export-EndpointSecurityPolicies {
    param (
        $Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion

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

    # $uri = 'https://graph.microsoft.com/beta/deviceManagement/intents'

    # $EPP = (Invoke-RestMethod -Method GET -Headers $authToken -Uri $uri).value

    #Region Get Policies
    $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $EPP = (Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken).value
    $EPP = $EPP | Where-Object { $_.templateReference.templateFamily -like "endpointSecurity*" }
    #EndRegion

    Write-Host
    Write-Host "Exporting Device Endpoint Security Policies..." -ForegroundColor cyan
    foreach ($e in $EPP) {

        $Settings = Get-PolicyEndpointSettingsJSON -Policies $e
        $PolicyJSON = [pscustomobject]@{
            name              = $e.name
            description       = $e.description
            platforms         = $e.platforms
            settings          = [Array]$Settings
            technologies      = $e.technologies
            # templateId    = $e.TemplateId
            templateReference = $e.templateReference
        }

        $FinalJSONdisplayName = $e.name
        $FinalJSONDisplayName = $FinalJSONDisplayName.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $FileName_FinalJSON = "$FinalJSONDisplayName" + ".json"
        $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 20
        $FinalJSON | Set-Content -LiteralPath "$($Path)\EndpointSecurityPolicies\$($FileName_FinalJSON)"
        Write-Host "Exported Endpoint Security Policy: $($e.name)"
    }
}