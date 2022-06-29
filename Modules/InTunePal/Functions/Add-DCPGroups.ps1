function Add-DCPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $DCPGroups = Import-Csv -Path $Path\CSVs\DeviceConfigurationProfiles\*.csv -Delimiter ','

    Write-Host "Adding specified Groups to the Device Configuration Policies..." -ForegroundColor Cyan
    $gr = Get-Groups

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
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
            Write-Host "Response content:`n$responseBody" -f Red
            Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            write-host
            break
        }
    }
}