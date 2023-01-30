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
        
        #Region Importation
        Write-Host "Creating Intune Policies and Profiles as specified in "$Path" folder..." -ForegroundColor Cyan

        if ($Named) {
            Import-NamedLocations -Path $Path
        }

        if ($Conditional) {

            Set-SecDef

            Import-ConditionalAccessPolicies -Path $Path 
        }
    
        if ($Compliance) { Import-CompliancePolicies -Path $Path }
    
        if ($Configuration) { Import-DeviceConfigurationPolicies -Path $Path }
    
        if ($Update) { Import-UpdatePolicies -Path $Path }
    
        if ($CApps) { Import-ClientApps -Path $Path }
    
        if ($ApplicationProt) { Import-AppProtectionPolicies -Path $Path }
    
        if ($EndpointSec) { Import-EndpointSecurityPolicies -Path $Path }
        #EndRegion

        #Region Continue or Exit
        $confirmation = Read-Host "Do you want to perform another job? [y/n]"
        if ($confirmation -eq 'n') {
            Write-Host "Thanks for using InTunePal! Have a nice one!" -ForegroundColor Green
            break
        }
        if ($confirmation -eq 'y') {
            Start-InTuneModule
        }
        #EndRegion
    }
}