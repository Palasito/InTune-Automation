function Export-DeviceConfigurationPolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    # Checking if authToken exists before running authentication
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

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "General Device Configuration Policy"  
            "Name"   = $GDC.DisplayName
            "Path"   = $ExportPath
        }

    }

    Write-Host

    $DSCs = Get-DeviceSettingsCatalogPolicy
    write-host "Exporting Device Settings Catalog Policies..." -ForegroundColor cyan
    foreach ($DSC in $DSCs) {
        Get-DeviceSettingsCatalogPolicyJSON -Policies $DSC -ExportPath "$ExportPath"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Settings Catalog Policy"
            "Name"   = $DSC.name
            "Path"   = $ExportPath
        }
    }

    Write-Host

    $DATs = Get-DeviceAdministrativeTemplates
    write-host "Exporting Device Administrative Template Policies..." -ForegroundColor cyan
    foreach ($DAT in $DATs) {
        Get-DeviceAdministrativeTemplatesJSON -Policies $DAT -ExportPath "$ExportPath"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Administrative Template"
            "Name"   = $DAT.DisplayName
            "Path"   = $ExportPath
        }
    }

    Write-Host
}