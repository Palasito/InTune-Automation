function Export-Intune {

    [cmdletbinding()]

    param (
        [parameter(Mandatory)]
        $Path,
        [switch]$Token,
        [switch]$Named,
        [switch]$Conditional,
        [switch]$Compliance,
        [switch]$Configuration,
        [switch]$Update,
        [switch]$CApps,
        [switch]$ApplicationProt,
        [switch]$EndpointSec
    )
    
    Write-Host "Starting InTune Configuration export....." -ForegroundColor Cyan

    #Region Graph API Powershell
    if ($Token) {
        $global:tenantconfirmation = Read-Host "Do you want to connect to another tenant? [y/n]"
        Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
        if ($global:authToken) {
            #Do nothing
        }
        else {
            $null = Get-Token
        }
    }

    if ($Named) { Export-NamedLocations -Path $Path }

    if ($Conditional) { Export-ConditionalAccessPolicies -Path $Path }

    if ($Compliance) { Export-CompliancePolicies -Path $Path }

    if ($Configuration) { Export-DeviceConfigurationPolicies -Path $Path }

    if ($Update) { Export-UpdatePolicies -Path $Path }

    if ($CApps) { Export-ClientApps -Path $Path }

    if ($ApplicationProt) { Export-AppProtectionPolicies -Path $Path }

    if ($EndpointSec) { Export-EndpointSecurityPolicies -Path $Path }
    #EndRegion
}