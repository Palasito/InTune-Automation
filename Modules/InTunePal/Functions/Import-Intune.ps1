function Import-Intune() {
    
    Import-Module AzureAD

    Write-Host "Starting InTune Configuration import....."

    $Path = Read-host -Prompt "Specify the root path to import"

    if (-not (Test-Path "$Path")) {
        Write-Host "Invalid Path specified!!!" -ForegroundColor Red
    }

    else {

        Get-Tokens

        # Graph Api Powershell

        Write-Host "Creating Intune Policies and Profiles as specified in"$Path" folder..." -ForegroundColor Cyan
        
        # Start-Sleep -Seconds 5
        Import-CompliancePolicies -Path $Path
        # Start-Sleep -Seconds 5
        Import-DeviceConfigurationPolicies -Path $Path
        # Start-Sleep -Seconds 5
        Import-UpdatePolicies -Path $Path
        # Start-Sleep -Seconds 5
        Import-ClientApps -Path $Path
        # Start-Sleep -Seconds 5
        Import-AppProtectionPolicies -Path $Path

        # AzureAD Powershell

        Import-NamedLocations -Path $Path
        # Start-Sleep -Seconds 5
        $confirmation = Read-Host "Do you want to create the predefined user accounts? [y/n]"
        if ($confirmation -eq 'n') {

        }
        if ($confirmation -eq 'y') {
            Add-BreakGlassAccount -tenantforbreak $tenantforbreak
        }
        # Start-Sleep -Seconds 5
        Import-AADGroups -Path $Path
        # Start-Sleep -Seconds 5
        Import-ConditionalAccessPolicies -Path $Path
        # Start-Sleep -Seconds 5


        $confirmation = Read-Host "Do you want to assign groups based on the CSVs? [y/n]"
        if ($confirmation -eq 'n') {
            break;
        }
        if ($confirmation -eq 'y') {
            Write-Host
            Write-Host "Getting Ready to assign AzureAD Groups to the imported configuration..." -ForegroundColor Cyan
            Start-Sleep -Seconds 15
    
            Add-CPGroups -Path $Path
            # Start-Sleep -Seconds 5
            Add-DCPGroups -Path $Path
            # Start-Sleep -Seconds 5
            Add-DUPGroups -Path $Path
            # Start-Sleep -Seconds 5
            Add-APPGroups -Path $Path
            # Start-Sleep -Seconds 5
            Add-CAPGroups -Path $Path
        }
    }
}
