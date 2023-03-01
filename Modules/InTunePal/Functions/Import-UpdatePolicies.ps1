function Import-UpdatePolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion

    $ImportPath = $Path

    $ImportPath = $ImportPath.replace('"', '')

    if (!(Test-Path "$ImportPath")) {

        Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    ####################################################
    
    Write-Host
    Write-Host "Importing Software Update Policies..." -ForegroundColor Cyan

    $AvailableJsonsiOS = Get-ChildItem "$ImportPath\iOSUpdatePolicies" -Recurse -Include *.json

    $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations"
    $Existing = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value 
    foreach ($json in $AvailableJsonsiOS) {

        $JSON_Data = Get-Content $json

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, 'groupAssignments@odata.context', groupAssignments, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $check = $EXisting | Where-Object { $_.displayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json

            $null = Add-DeviceConfigurationUpdatePolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Software Update Policy"
                "Name"   = $DisplayName
            }
        }
        else {
            Write-Host "iOS update policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    $AvailableJsonsWindows = Get-ChildItem "$ImportPath\WindowsUpdatePolicies" -Recurse -Include *.json

    $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations"
    $Existing = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
    foreach ($json in $AvailableJsonsWindows) {

        $JSON_Data = Get-Content $json

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, 'groupAssignments@odata.context', groupAssignments, supportsScopeTags

        $DisplayName = $JSON_Convert.displayName

        $check = $Existing | Where-Object { $_.displayName -eq $DisplayName }
        if ($null -eq $check) {
            $JSON_Output = $JSON_Convert | ConvertTo-Json

            $null = Add-DeviceConfigurationUpdatePolicy -JSON $JSON_Output

            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Software Update Policy"
                "Name"   = $DisplayName
            }
        }
        else {
            Write-Host "Windows Update Policy $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}