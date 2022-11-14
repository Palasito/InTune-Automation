function Import-IntuneGroups {

    [cmdletbinding()]

    param(
        [Parameter(mandatory)]
        $Path,
        [switch]$Token,
        [switch]$AADGroups,
        [switch]$CPGroups,
        [switch]$DCPGroups,
        [switch]$DUPGroups,
        [switch]$APPGroups,
        [switch]$CAPGroups
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
    Import-AADGroups -Path $Path
    # Start-Sleep -Seconds 5
    Add-CPGroups -Path $Path
    # Start-Sleep -Seconds 5
    Add-DCPGroups -Path $Path
    # Start-Sleep -Seconds 5
    Add-DUPGroups -Path $Path
    # Start-Sleep -Seconds 5
    Add-APPGroups -Path $Path
    # Start-Sleep -Seconds 5
    Add-CAPGroups -Path $Path
    #EndRegion

}