function Export-Intune(){
    
    Write-Host "Starting InTune Configuration export....."

    $Path = Read-host -Prompt "Specify the root path to export"

    Export-AppProtectionPolicies -Path $Path
    Export-ClientApps -Path $Path
    Export-CompliancePolicies -Path $Path
    Export-DeviceConfigurationPolicies -Path $Path
    Export-UpdatePolicies -Path $Path
    Export-ConditionalAccessPolicies -Path $Path

}