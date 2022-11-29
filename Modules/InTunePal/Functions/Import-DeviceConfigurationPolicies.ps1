function Import-DeviceConfigurationPolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    # Authentication region
    if ($global:authToken) {
        #Do nothing
    }
    else {
        $null = Get-Token
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
    $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations"
    $AllExistingGDC = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    foreach ($json in $AvailableJsonsGDC) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $check = $AllExistingGDC | Where-Object { $_.DisplayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            $null = Add-DeviceGeneralConfigurationPolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Device Configuration Profile"
                "Name"   = $DisplayName
            }
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Importing Settings Catalog Profiles..." -ForegroundColor cyan

    $AvailableJsonsSCP = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include SC_*.json
    $uri = "https://graph.microsoft.com/Beta/deviceManagement/configurationPolicies"
    $AllexistingSCP = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    foreach ($json in $AvailableJsonsSCP) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.name

        $check = $AllexistingSCP | Where-Object { $_.Name -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            $null = Add-DeviceSettingsCatalogConfigurationPolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Settings Catalog Profile"
                "Name"   = $DisplayName
            }
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Importing Administrative Templates..." -ForegroundColor cyan

    $AvailableJsonsAT = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include AT_*.json
    $uri = "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations"
    $AllExistingAT = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    foreach ($json in $AvailableJsonsAT) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $check = $AllExistingAT | Where-Object { $_.DisplayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            $null = Add-DeviceAdministrativeTeamplatePolicy -JSON $JSON_Output
            
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Administrative Template"
                "Name"   = $DisplayName
            }
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}