function Import-Intune {

    [cmdletbinding()]

    param(
        [Parameter(mandatory)]
        $Path
    )
    
    Import-Module AzureAD

    Write-Host "Starting InTune Configuration import....."

    if (-not (Test-Path "$Path")) {
        Write-Host "Invalid Path specified!!!" -ForegroundColor Red
    }

    else {

        # Authentication
        if ($global:authToken) {
            #Do nothing
        }
        else {
            $null = Get-Token
        }
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
            # Do nothing !
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
            # Do Nothing !
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
        
        $confirmation = Read-Host "Do you want to import endpoint security policies? [y/n]"
        if ($confirmation -eq 'n') {
            # Do Nothing !
        }
        if ($confirmation -eq 'y') {
            Write-Host
            Write-Host "Getting Ready to import Endpoint Security Policies..." -ForegroundColor Cyan

            Import-EndpointSecurityPolicies -Path $Path
        }

        Write-Host "Thanks for using InTunePal! Enjoy your new configuration!" -ForegroundColor Cyan
    }
}
