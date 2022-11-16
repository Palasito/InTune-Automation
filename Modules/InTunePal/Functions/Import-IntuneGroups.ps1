function Import-IntuneGroups {

    [cmdletbinding()]

    param(
        [Parameter(mandatory)]
        $Path,
        [switch]$Token,
        [switch]$AADGroups,
        [switch]$CAPGroups,
        [switch]$CPGroups,
        [switch]$DCPGroups,
        [switch]$DUPGroups,
        [switch]$ApplicationGroups,
        [switch]$APPGroups,
        [switch]$EndpointSecGroups
    )

    Write-Host
    Write-Host "Getting Ready to assign AzureAD Groups to the imported configuration..." -ForegroundColor Cyan

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

    #Region Assignments
    Write-Host "Creating Assignments as specified in "$Path\CSVs" folder..." -ForegroundColor Cyan

    if ($AADGroups) { Import-AADGroups -Path $Path }

    if ($CAPGroups) { Add-CAPGroups -Path $Path }

    if ($CPGroups) { Add-CPGroups -Path $Path }
    
    if ($DCPGroups) { Add-DCPGroups -Path $Path }

    if ($DUPGroups) { Add-DUPGroups -Path $Path }

    if ($APPGroups) { Add-APPGroups -Path $Path }
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