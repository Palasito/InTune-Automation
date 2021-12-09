function Export-Intune(){
    
    Write-Host "Starting InTune Configuration import....."

    $Path = Read-host -Prompt "Specify the root path to export:"

    $ExportPath = $Path

    # If the directory path doesn't exist prompt user to create the directory
    $ExportPath = $ExportPath.replace('"','')
    
    if(!(Test-Path "$ExportPath")){

        Write-Host
        Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow
    
        $Confirm = read-host
    
            if($Confirm -eq "y" -or $Confirm -eq "Y"){
    
            new-item -ItemType Directory -Path "$ExportPath" | Out-Null
            Write-Host
    
            }

    else {

    Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
    Write-Host
    break

    }

    Export-AppProtectionPolicies -Path $ExportPath
    Export-ClientApps -Path $ExportPath
    Export-CompliancePolicies -Path $ExportPath
    Export-ConditionalAccessPolicies -Path $ExportPath
    Export-DeviceConfigurationPolicies -Path $ExportPath
    Export-UpdatePolicies -Path $ExportPath

}

}