function Import-Intune {

    [cmdletbinding()]

    param(
        [Parameter(mandatory)]
        $Path
    )

    Write-Host "Starting InTune Configuration import....."

    if (-not (Test-Path "$Path")) {
        Write-Host "Invalid Path specified!!!" -ForegroundColor Red
    }

    else {

        #Region Authentication
        $global:tenantconfirmation = Read-Host "Do you want to connect to another tenant? [y/n]"
        Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
    
        if ($global:authToken) {
            #Do nothing
        }
        else {
            $null = Get-Token
        }
        #EndRegion
        
        #Region Graph Api Powershell

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
        # Start-Sleep -Seconds 5
        Import-NamedLocations -Path $Path
        # Start-Sleep -Seconds 5
        Import-ConditionalAccessPolicies -Path $Path
        # Start-Sleep -Seconds 5
        #EndRegion

        #Region Group Assignments
        $confirmation = Read-Host "Do you want to assign groups based on the CSVs? [y/n]"
        if ($confirmation -eq 'n') {
            # Do Nothing !
        }
        if ($confirmation -eq 'y') {
            Write-Host
            Write-Host "Getting Ready to assign AzureAD Groups to the imported configuration..." -ForegroundColor Cyan
            Start-Sleep -Seconds 15

            Import-AADGroups -Path $Path
            # Start-Sleep -Seconds 5
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
        #EndRegion
        
        #Region Endpoint Security Policies
        $confirmation = Read-Host "Do you want to import endpoint security policies? [y/n]"
        if ($confirmation -eq 'n') {
            # Do Nothing !
        }
        if ($confirmation -eq 'y') {
            Write-Host
            Write-Host "Getting Ready to import Endpoint Security Policies..." -ForegroundColor Cyan

            Import-EndpointSecurityPolicies -Path $Path
        }
        #EndRegion

        Write-Host "Thanks for using InTunePal! Enjoy your new configuration!" -ForegroundColor Cyan
    }
}