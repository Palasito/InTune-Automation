function Add-APPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    Write-Host "Adding specified groups to App Protection Policies..." -ForegroundColor Cyan
    Write-Host
    
    $APPGroups = Import-Csv -Path $Path\CSVs\AppProtection\*.csv -Delimiter ','

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
                        $g = Get-AzureADMSGroup -SearchString $grp
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
                        $g = Get-AzureADMSGroup -SearchString "$($grp)"
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
                        $g = Get-AzureADMSGroup -SearchString $grp
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
                        $g = Get-AzureADMSGroup -SearchString "$($grp)"
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
                        $g = Get-AzureADMSGroup -SearchString $grp
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
                        $g = Get-AzureADMSGroup -SearchString "$($grp)"
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
                        $g = Get-AzureADMSGroup -SearchString $grp
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
                        $g = Get-AzureADMSGroup -SearchString "$($grp)"
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