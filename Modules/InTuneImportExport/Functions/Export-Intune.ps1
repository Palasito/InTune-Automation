function Export-Intune(){
    
    Write-Host "Starting InTune Configuration export....."

    $Path = Read-host -Prompt "Specify the root path to export"

    # Graph API Powershell

    Write-Host "For the next set of functions we need to get an auth token to use with the Graph API" -ForegroundColor Cyan
    Export-AppProtectionPolicies -Path $Path
    Export-ClientApps -Path $Path
    Export-CompliancePolicies -Path $Path
    Export-DeviceConfigurationPolicies -Path $Path
    Export-UpdatePolicies -Path $Path

    # AzureAD Powershell

    Write-Host "For the next set of functions we need to get an auth token to use with AzureAD Module" -ForegroundColor Cyan
    Export-ConditionalAccessPolicies -Path $Path
    Export-NamedLocations -Path $Path
}