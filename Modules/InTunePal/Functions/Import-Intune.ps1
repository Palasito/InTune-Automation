function Import-Intune(){
    
    Import-Module AzureAD

    Write-Host "Starting InTune Configuration import....."

    $Path = Read-host -Prompt "Specify the root path to import"

    if(-not (Test-Path "$Path")){
    Write-Host "Invalid Path specified!!!" -ForegroundColor Red
    }

    else{

        Get-Tokens

        # Graph Api Powershell
        
        Import-CompliancePolicies -Path $Path
        Import-DeviceConfigurationPolicies -Path $Path
        Import-UpdatePolicies -Path $Path
        Import-ClientApps -Path $Path
        Import-AppProtectionPolicies -Path $Path

        # AzureAD Powershell

        Write-Host "For the next set of functions we need to get an auth token to use with AzureAD Module" -ForegroundColor Cyan
        Import-NamedLocations -Path $Path
        Add-BreakGlassAccount -tenantforbreak $tenantforbreak
        Import-AADGroups -Path $Path
        Import-ConditionalAccessPolicies -Path $Path
    }
}
