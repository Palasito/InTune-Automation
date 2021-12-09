function Import-Intune(){
    
    Write-Host "Starting InTune Configuration import....."

    $Path = Read-host -Prompt "Specify the root path to import:"

    if(-not (Test-Path "$Path")){
    Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
    Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    elseif(-not (Test-Path "$Path\AppProtectionPolicies")){
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
        }
    elseif (-not (Test-Path "$Path\ClientApps")) {
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    elseif (-not (Test-Path "$Path\DeviceCompliancePolicies")) {
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    elseif (-not (Test-Path "$Path\ConditionalAccessPolicies")) {
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    elseif (-not (Test-Path "$Path\DeviceConfigurationPolicies")) {
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    elseif (-not (Test-Path "$Path\WindowsUpdatePolicies")) {
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    elseif (-not (Test-Path "$Path\iOSUpdatePolicies")) {
        Write-Host "SPECIFIC FOLDER STRUCTURE REQUIRED!!" -ForegroundColor Red
        Write-Host "For folder structure requirements refer to the readme file!" -ForegroundColor Cyan
    }
    else{
        Import-ConditionalAccessPolicies -Path $Path
        Import-CompliancePolicies -Path $Path
        Import-DeviceConfigurationPolicies -Path $Path
        Import-UpdatePolicies -Path $Path
        Import-ClientApps -Path $Path
        Import-AppProtectionPolicies -Path $Path
    }
}
