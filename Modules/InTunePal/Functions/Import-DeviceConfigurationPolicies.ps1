function Import-DeviceConfigurationPolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion
    
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
    $AllExistingGDC = Get-GeneralDeviceConfigurationPolicy
    foreach ($json in $AvailableJsonsGDC) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $check = $AllExistingGDC | Where-Object { $_.DisplayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            Add-DeviceGeneralConfigurationPolicy -JSON $JSON_Output
    
            Write-Host "Imported Device General Configuration Policy $($DisplayName)"
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Importing Settings Catalog Profiles..." -ForegroundColor cyan

    $AvailableJsonsSCP = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include SC_*.json
    $AllexistingSCP = Get-DeviceSettingsCatalogPolicy
    foreach ($json in $AvailableJsonsSCP) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags

        $DisplayName = $JSON_Convert.name

        $check = $AllexistingSCP | Where-Object { $_.Name -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            Add-DeviceSettingsCatalogConfigurationPolicy -JSON $JSON_Output
    
            Write-Host "Imported Device Settings Catalog Policy $($DisplayName)"
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Importing Administrative Templates..." -ForegroundColor cyan

    $AvailableJsonsAT = Get-ChildItem "$ImportPath\DeviceConfigurationPolicies" -Recurse -Include AT_*.json
    $AllExistingAT = Get-DeviceAdministrativeTemplates
    foreach ($json in $AvailableJsonsAT) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json

        $DisplayName = $JSON_Convert.displayName

        $check = $AllExistingAT | Where-Object { $_.DisplayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100

            Add-DeviceAdministrativeTemplatePolicy -JSON $JSON_Output
            
            Write-Host "Imported Device Administrative Template Policy $($DisplayName)"
        }
        else {
            Write-Host "Device Configuration Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}