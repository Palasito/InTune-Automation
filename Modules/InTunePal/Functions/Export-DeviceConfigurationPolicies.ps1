function Export-DeviceConfigurationPolicies() {

    [cmdletbinding()]
    
    param
    (
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

    ####################################################

    $ExportPath = $Path

    # If the directory path doesn't exist prompt user to create the directory
    $ExportPath = $ExportPath.replace('"', '')
    
    if (!(Test-Path "$ExportPath")) {

        Write-Host
        Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow
    
        $Confirm = read-host
    
        if ($Confirm -eq "y" -or $Confirm -eq "Y") {
    
            new-item -ItemType Directory -Path "$ExportPath" | Out-Null
            Write-Host
    
        }

        else {

            Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
            Write-Host
            break

        }

    }

    ####################################################

    if (-not (Test-Path "$ExportPath\DeviceConfigurationPolicies")) {
        $null = New-Item -Path "$ExportPath\DeviceConfigurationPolicies" -ItemType Directory
    }

    # Filtering out iOS and Windows Software Update Policies
    $GDCs = Get-GeneralDeviceConfigurationPolicy | Where-Object { ($_.'@odata.type' -ne "#microsoft.graph.iosUpdateConfiguration") -and ($_.'@odata.type' -ne "#microsoft.graph.windowsUpdateForBusinessConfiguration") }
    Write-Host
    write-host "Exporting Device Configuration Policies..." -ForegroundColor cyan
    foreach ($GDC in $GDCs) {
        Get-GeneralDeviceConfigurationPolicyJSON -Policies $GDC -ExportPath "$ExportPath"

        Write-Host "Exported General Device Configuration Policy: $($GDC.displayName)"
    }

    Write-Host

    $DSCs = Get-DeviceSettingsCatalogPolicy
    write-host "Exporting Device Settings Catalog Policies..." -ForegroundColor cyan
    foreach ($DSC in $DSCs) {
        Get-DeviceSettingsCatalogPolicyJSON -Policies $DSC -ExportPath "$ExportPath"

        Write-Host "Exported Settings Catalog Policy: $($DSC.name)"
    }

    Write-Host

    $DATs = Get-DeviceAdministrativeTemplates
    write-host "Exporting Device Administrative Template Policies..." -ForegroundColor cyan
    foreach ($DAT in $DATs) {
        Get-DeviceAdministrativeTemplatesJSON -Policies $DAT -ExportPath "$ExportPath"

        Write-Host "Exported Administrative Template: $($DAT.displayName)"
    }

    Write-Host
}