function Export-Intune {
    
    Write-Host "Starting InTune Configuration export....."

    $Path = Read-host -Prompt "Specify the root path to export"

    # Import-Module AzureAD

    $global:tenantconfirmation = Read-Host "Do you want to connect to another tenant? [y/n]"
    Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
    $null = Get-Token

    # Graph API Powershell

    Export-AppProtectionPolicies -Path $Path
    Export-ClientApps -Path $Path
    Export-CompliancePolicies -Path $Path
    Export-DeviceConfigurationPolicies -Path $Path
    Export-UpdatePolicies -Path $Path
    Export-EndpointSecurityPolicies -Path $Path

    Export-ConditionalAccessPolicies -Path $Path
    Export-NamedLocations -Path $Path
    Export-EndpointSecurityPolicies -Path $Path
}