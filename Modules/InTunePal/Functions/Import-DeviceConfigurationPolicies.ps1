function Import-DeviceConfigurationPolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    if ($global:authToken) {

        # Setting DateTime to Universal time to work in all timezones
        $DateTime = (Get-Date).ToUniversalTime()

        # If the authToken exists checking when it expires
        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

        if ($TokenExpires -le 0) {

            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host

            # Defining User Principal Name if not present

            if ($null -eq $User -or $User -eq "") {

                $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host

            }

            $global:authToken = Get-AuthToken -User $User

        }
    }

    # Authentication doesn't exist, calling Get-AuthToken function

    else {

        if ($null -eq $User -or $User -eq "") {

            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host

        }

        # Getting the authorization token
        $global:authToken = Get-AuthToken -User $User

    }

    #endregion

    ####################################################

    $ImportPath = $Path

    # Replacing quotes for Test-Path
    $ImportPath = $ImportPath.replace('"', '')

    if (!(Test-Path "$ImportPath")) {

        Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    ####################################################

    Write-Host
    Write-Host "Importing Device Configuration Profiles..." -ForegroundColor cyan

    $AvailableJsonsGDC = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include GDC_*.json
    $AllExistingGDC = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    foreach ($json in $AvailableJsonsGDC) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations"
        $check = $AllExistingGDC | Where-Object { $_.DisplayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            $null = Add-DeviceGeneralConfigurationPolicy -JSON $JSON_Output -ErrorAction Continue
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Device Configuration Profile"
                "Name"   = $DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Importing Settings Catalog Profiles..." -ForegroundColor cyan

    $AvailableJsonsSCP = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include SC_*.json
    $AllexistingSCP = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    foreach ($json in $AvailableJsonsSCP) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.name

        $uri = "https://graph.microsoft.com/Beta/deviceManagement/configurationPolicies"
        $check = $AllexistingSCP | Where-Object { $_.Name -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            $null = Add-DeviceSettingsCatalogConfigurationPolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Settings Catalog Profile"
                "Name"   = $DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Importing Administrative Templates..." -ForegroundColor cyan

    $AvailableJsonsAT = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include AT_*.json
    $AllExistingAT = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    foreach ($json in $AvailableJsonsAT) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $uri = "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations"
        $check = $AllExistingAT | Where-Object { $_.DisplayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            $null = Add-DeviceAdministrativeTeamplatePolicy -JSON $JSON_Output
            
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Administrative Template"
                "Name"   = $DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}