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
        
        Import-CompliancePolicies -Path $Path
        Import-DeviceConfigurationPolicies -Path $Path
        Import-UpdatePolicies -Path $Path
        Import-ClientApps -Path $Path
        Import-AppProtectionPolicies -Path $Path

        # AzureAD Powershell

        Import-NamedLocations -Path $Path
        Add-BreakGlassAccount -tenantforbreak $tenantforbreak
        Import-AADGroups -Path $Path
        Import-ConditionalAccessPolicies -Path $Path

        Write-Host
        Write-Host "Getting Ready to assign AzureAD Groups to the imported configuration..." -ForegroundColor Cyan
        Start-Sleep -Seconds 15

        Add-CPGroups -Path $Path
        Add-DCPGroups -Path $Path
        Add-DUPGroups -Path $Path
        Add-APPGroups -Path $Path
        Add-CAPGroups -Path $Path

    }
}
