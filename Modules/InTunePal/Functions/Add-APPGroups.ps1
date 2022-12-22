function Add-APPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $APPGroupsCheck = Get-ChildItem -Path $Path\CSVs\AppProtection

    if ($null -eq $APPGroupsCheck) {
        Write-Host "No CSVs found containing groups to assign for the App Protection Policies !" -ForegroundColor Yellow
        break
    }

    else {
        $APPGroups = $APPGroupsCheck | ForEach-Object { Import-Csv $Path\CSVs\AppProtection\$_ -Delimiter "," }
    }

    Write-Host "Adding specified groups to App Protection Policies..." -ForegroundColor Cyan
    Write-Host
    $gr = Get-AADGroups

    foreach ($Pol in $APPGroups) {
    
        try {

            if ($null -ne ($Policy = Get-AndroidAPPPolicy | Where-Object displayName -eq $pol.DisplayName)) {
                
                $InclGrps = $pol.IncludeGroups -split ";"
                $ExclGrps = $pol.ExcludeGroups -split ";"
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

                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/androidManagedAppProtections/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"

                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "App Protection Policy"
                    "Name"            = $Policy.displayName
                    "Included Groups" = $InclGrps
                    "Excluded Groups" = $ExclGrps
                }
            }

            elseif ($null -ne ($Policy = Get-iOSAPPPolicy | Where-Object displayName -eq $Pol.DisplayName)) {

                $InclGrps = $pol.IncludeGroups -split ";"
                $ExclGrps = $pol.ExcludeGroups -split ";"
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

                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/iosManagedAppProtections/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            
                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "App Protection Policy"
                    "Name"            = $Policy.displayName
                    "Included Groups" = $InclGrps
                    "Excluded Groups" = $ExclGrps
                }
            }

            elseif ($null -ne ($Policy = Get-WindowsInformationProtectionPolicy | Where-Object name -eq $Pol.DisplayName)) {

                $InclGrps = $pol.IncludeGroups -split ";"
                $ExclGrps = $pol.ExcludeGroups -split ";"
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

                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/windowsInformationProtectionPolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            
                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "App Protection Policy"
                    "Name"            = $Policy.displayName
                    "Included Groups" = $InclGrps
                    "Excluded Groups" = $ExclGrps
                }
            }

            elseif ($null -ne ($Policy = Get-mdmWindowsInformationProtectionPolicy | Where-Object name -eq $Pol.DisplayName)) {

                $InclGrps = $pol.IncludeGroups -split ";"
                $ExclGrps = $pol.ExcludeGroups -split ";"
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

                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mdmWindowsInformationProtectionPolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            
                [PSCustomObject]@{
                    "Action"          = "Assign"
                    "Type"            = "App Protection Policy"
                    "Name"            = $Policy.displayName
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
            Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            write-host
            break
        }
    }
}