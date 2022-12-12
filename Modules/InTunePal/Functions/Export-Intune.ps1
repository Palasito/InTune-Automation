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

    #Region Authentication
    if ($Token) {
        # $global:tenantconfirmation = Read-Host "Do you want to connect to another tenant? [y/n]"
        $global:tenantconfirmation = "n"
        Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
        if ($global:authToken) {
            #Do nothing
        }
        else {
            $null = Get-Token
        }
    }
    #EndRegion

    #Region Exportation
    Write-Host "Exporting Existing Intune Policies and Profiles in "$Path" folder..." -ForegroundColor Cyan
    
    [PSCustomObject]@{
        "Action" = ""
        "Type"   = ""
        "Name"   = ""
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

    #Region Continue or Exit
    $confirmation = Read-Host "Do you want to perform another job? [y/n]"
    if ($confirmation -eq 'n') {
        Write-Host "Thanks for using InTunePal! Have a nice one!" -ForegroundColor Green
        break;
    }
    if ($confirmation -eq 'y') {
        Start-InTuneModule
    }
    #EndRegion
}