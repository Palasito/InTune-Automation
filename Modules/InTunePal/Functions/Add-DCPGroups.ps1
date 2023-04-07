function Add-DCPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $DCPGroupsCheck = Get-ChildItem -Path $Path\CSVs\DeviceConfigurationProfiles

    if ($null -eq $DCPGroupsCheck) {
        Write-Host "No CSVs found containing groups to assign for the Device Configuration Profiles !" -ForegroundColor Yellow
        break
    }

    else {
        $DCPGroups = $DCPGroupsCheck | ForEach-Object { Import-Csv $Path\CSVs\DeviceConfigurationProfiles\$_ -Delimiter "," }
    }

    Write-Host "Adding specified Groups to the Device Configuration Profiles..." -ForegroundColor Cyan
    $gr = Get-AADGroups

    foreach ($Pol in $DCPGroups) {
    
        try {

            if ($null -ne ($Policy = Get-GeneralDeviceConfigurationPolicy | Where-Object displayName -eq $pol.DisplayName)) {
                
                $InclGrps = $Pol.IncludeGroups -split ";"
                $ExclGrps = $Pol.ExcludeGroups -split ";"
                
                $Body = @{
                    assignments = @()
                }
            
                foreach ($grp in $InclGrps) {
                    if (-not([string]::IsNullOrEmpty($grp))) {
                        $g = $gr | Where-Object { $_.displayName -eq $grp }
                        $targetmember = @{}
                        $targetmember.'@odata.type' = "#microsoft.graph.groupAssignmentTarget"
                        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                        $targetmember.groupId = $g.id
                
                        $body.assignments += @{
                            "target" = $targetmember
                        }
                    }
                    elseif ([string]::IsNullOrEmpty($grp)) {
        
                    }
                    else {
                        Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
                    }
                }
            
                foreach ($grp in $ExclGrps) {
                    if (-not([string]::IsNullOrEmpty($grp))) {
                        $g = $gr | Where-Object { $_.displayName -eq $grp }
                        $targetmember = @{}
                        $targetmember.'@odata.type' = "#microsoft.graph.exclusionGroupAssignmentTarget"
                        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                        $targetmember.groupId = $g.id
        
                        $body.assignments += @{
                            "target" = $targetmember
                        }
                    }
                    elseif ([string]::IsNullOrEmpty($grp)) {
        
                    }
                    else {
                        Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
                    }
                }
            
                $Body = $Body | ConvertTo-Json -Depth 100
            
            
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"

                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "Configuration Profiles"
                    "Name"            = $Policy.displayName
                    "Included Groups" = $InclGrps
                    "Excluded Groups" = $ExclGrps
                }
            }

            elseif ($null -ne ($Policy = Get-DeviceAdministrativeTemplates | Where-Object displayName -eq $Pol.DisplayName)) {

                $InclGrps = $Pol.IncludeGroups -split ";"
                $ExclGrps = $Pol.ExcludeGroups -split ";"
                
                $Body = @{
                    assignments = @()
                }
            
                foreach ($grp in $InclGrps) {
                    if (-not([string]::IsNullOrEmpty($grp))) {
                        $g = $gr | Where-Object { $_.displayName -eq $grp }
                        $targetmember = @{}
                        $targetmember.'@odata.type' = "#microsoft.graph.groupAssignmentTarget"
                        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                        $targetmember.groupId = $g.id
                
                        $body.assignments += @{
                            "target" = $targetmember
                        }
                    }
                    elseif ([string]::IsNullOrEmpty($grp)) {
        
                    }
                    else {
                        Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
                    }
                }
            
                foreach ($grp in $ExclGrps) {
                    if (-not([string]::IsNullOrEmpty($grp))) {
                        $g = $gr | Where-Object { $_.displayName -eq $grp }
                        $targetmember = @{}
                        $targetmember.'@odata.type' = "#microsoft.graph.exclusionGroupAssignmentTarget"
                        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                        $targetmember.groupId = $g.id
        
                        $body.assignments += @{
                            "target" = $targetmember
                        }
                    }
                    elseif ([string]::IsNullOrEmpty($grp)) {
        
                    }
                    else {
                        Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
                    }
                }
            
                $Body = $Body | ConvertTo-Json -Depth 100

                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            
                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "Configuration Profiles"
                    "Name"            = $Policy.displayName
                    "Included Groups" = $InclGrps
                    "Excluded Groups" = $ExclGrps
                }
            }

            elseif ($null -ne ($Policy = Get-DeviceSettingsCatalogPolicy | Where-Object name -eq $Pol.DisplayName)) {

                $InclGrps = $Pol.IncludeGroups -split ";"
                $ExclGrps = $Pol.ExcludeGroups -split ";"
                
                $Body = @{
                    assignments = @()
                }

                foreach ($grp in $InclGrps) {
                    if (-not([string]::IsNullOrEmpty($grp))) {
                        $g = $gr | Where-Object { $_.displayName -eq $grp }
                        $targetmember = @{}
                        $targetmember.'@odata.type' = "#microsoft.graph.groupAssignmentTarget"
                        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                        $targetmember.groupId = $g.id
        
                        $body.assignments += @{
                            "target" = $targetmember
                        }
                    }
                    elseif ([string]::IsNullOrEmpty($grp)) {

                    }
                    else {
                        Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
                    }
                }
            
                foreach ($grp in $ExclGrps) {
                    if (-not([string]::IsNullOrEmpty($grp))) {
                        $g = $gr | Where-Object { $_.displayName -eq $grp }
                        $targetmember = @{}
                        $targetmember.'@odata.type' = "#microsoft.graph.exclusionGroupAssignmentTarget"
                        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                        $targetmember.groupId = $g.id
        
                        $body.assignments += @{
                            "target" = $targetmember
                        }
                    }
                    elseif ([string]::IsNullOrEmpty($grp)) {
        
                    }
                    else {
                        Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
                    }
                }

                $Body = $Body | ConvertTo-Json -Depth 100

                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            
                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "Configuration Profiles"
                    "Name"            = $Policy.name
                    "Included Groups" = $InclGrps
                    "Excluded Groups" = $ExclGrps
                }
            }
        
            else {
                Write-Host "Could not find policy:" $Pol.DisplayName -ForegroundColor Red
            }
        }

        catch {
            $ex = $_.Exception
            Write-Error "Request for policy $($Policy.Name) to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
            write-host
        }
    }
}