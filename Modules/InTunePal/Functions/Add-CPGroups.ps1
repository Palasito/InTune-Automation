function Add-CPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $CPGroupsCheck = Get-ChildItem -Path $Path\CSVs\CompliancePolicies

    if ($null -eq $CPGroupsCheck) {
        Write-Host "No CSVs found containing groups to assign for the Device Compliance Policies !" -ForegroundColor Yellow
        break
    }

    else {
        $CPGroups = $CPGroupsCheck | ForEach-Object { Import-Csv $Path\CSVs\CompliancePolicies\$_ -Delimiter "," }
    }

    Write-Host "Adding specified groups to Device Compliance Policies..." -ForegroundColor Cyan
    Write-Host

    $gr = Get-AADGroups
    
    foreach ($Pol in $CPGroups) {
        $Policy = Get-DeviceCompliancePolicy -Name $pol.DisplayName
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
    
        try {

            $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"

        }

        catch {
            $ex = $_.Exception
            Write-Host "Issue when assigning groups and users on policy $($pol.displayName)"
            Write-Host "Error for policy $($pol.displayName) is: $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)" -ForegroundColor Red
        }
        
    
        [PSCustomObject]@{
            "Action"          = "Assign"
            "Type"            = "Compliance Policies"
            "Name"            = $Policy.displayName
            "Included Groups" = $InclGrps
            "Excluded Groups" = $ExclGrps
        }
    }
}