function Import-Intune {

    [cmdletbinding()]

    param(
        [Parameter(mandatory)]
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

    Write-Host "Starting InTune Configuration import....."

    if (-not (Test-Path "$Path")) {
        Write-Host "Invalid Path specified!!!" -ForegroundColor Red
    }

    else {

        #Region Authentication
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
        #EndRegion
        
        #Region Importation
        Write-Host "Creating Intune Policies and Profiles as specified in "$Path" folder..." -ForegroundColor Cyan
        
        if ($Named) { Import-NamedLocations -Path $Path }

        if ($Conditional) { Import-ConditionalAccessPolicies -Path $Path }
    
        if ($Compliance) { Import-CompliancePolicies -Path $Path }
    
        if ($Configuration) { Import-DeviceConfigurationPolicies -Path $Path }
    
        if ($Update) { Import-UpdatePolicies -Path $Path }
    
        if ($CApps) { Import-ClientApps -Path $Path }
    
        if ($ApplicationProt) { Import-AppProtectionPolicies -Path $Path }
    
        if ($EndpointSec) { Import-EndpointSecurityPolicies -Path $Path }
        #EndRegion

        Write-Host "Thanks for using InTunePal! Enjoy your new configuration!" -ForegroundColor Green
    }
}