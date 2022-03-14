function Import-ClientApps() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    if ($global:authToken) {

        $DateTime = (Get-Date).ToUniversalTime()

        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

        if ($TokenExpires -le 0) {

            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host

            if ($null -eq $User -or $User -eq "") {

                $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host

            }

            $global:authToken = Get-AuthToken -User $User

        }
    }

    else {

        if ($null -eq $User -or $User -eq "") {

            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host

        }

        $global:authToken = Get-AuthToken -User $User

    }

    #endregion

    ####################################################

    $ImportPath = $Path

    $ImportPath = $ImportPath.replace('"', '')

    if (!(Test-Path "$ImportPath\ClientApps")) {

        Write-Host "Import Path for JSON files doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    ####################################################

    Write-Host
    Write-Host "Importing Client Apps..." -ForegroundColor Cyan

    $AvailableJSONS = Get-ChildItem "$ImportPath\ClientApps" -Recurse -Include *.json

    $uri = "https://graph.microsoft.com/Beta/deviceAppManagement/mobileApps"
    $Existing = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value

    foreach ($json in $AvailableJSONS) {

        $JSON_Data = Get-Content $json

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, "@odata.context", uploadState, packageId, appIdentifier, publishingState, usedLicenseCount, totalLicenseCount, productKey, licenseType, packageIdentityName

        $DisplayName = $JSON_Convert.displayName

        $check = $Existing | Where-Object { ($_.'displayName').contains("$DisplayName") }

        if ($null -eq $check) {

            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 10

            $null = Add-MDMApplication -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "ClientApp"
                "Name"   = $DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "Client App $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }

    }
}