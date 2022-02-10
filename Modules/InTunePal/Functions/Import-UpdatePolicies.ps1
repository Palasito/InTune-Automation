function Import-UpdatePolicies() {

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

    if (!(Test-Path "$ImportPath")) {

        Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    ####################################################
    
    Write-Host
    Write-Host "Importing Software Update Policies..." -ForegroundColor Cyan

    $AvailableJsonsiOS = Get-ChildItem "$ImportPath\iOSUpdatePolicies" -Recurse -Include *.json

    foreach ($json in $AvailableJsonsiOS) {

        $JSON_Data = Get-Content $json

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, 'groupAssignments@odata.context', groupAssignments, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations"
        $check = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value | Where-Object { $_.displayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json

            $null = Add-DeviceConfigurationUpdatePolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Software Update Policy"
                "Name"   = $DisplayName
                "Path"   = "$($ImportPath)\iOSUpdatePolicies"
            }
        }
        else {
            Write-Host "iOS update policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    $AvailableJsonsWindows = Get-ChildItem "$ImportPath\WindowsUpdatePolicies" -Recurse -Include *.json

    foreach ($json in $AvailableJsonsWindows) {

        $JSON_Data = Get-Content $json

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, 'groupAssignments@odata.context', groupAssignments, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations"
        $check = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value | Where-Object { $_.displayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json

            $null = Add-DeviceConfigurationUpdatePolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Software Update Policy"
                "Name"   = $DisplayName
                "Path"   = "$($ImportPath)\WindowsUpdatePolicies"
            }
        }
        else {
            Write-Host "Windows Update Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}