function Add-CPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $DCPGroups = Import-Csv -Path $Path\CSVs\CompliancePolicies\*.csv -Delimiter ','

    Write-Host "Adding specified groups to Device Compliance Policies..." -ForegroundColor Cyan
    Write-Host
    
    foreach ($Pol in $DCPGroups) {
        $Policy = Get-DeviceCompliancePolicy -Name $pol.DisplayName
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
    
        Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
    
        [PSCustomObject]@{
            "Action"          = "Assign"
            "Type"            = "Compliance Policies"
            "Name"            = $Policy.displayName
            "Included Groups" = $InclGrps
            "Excluded Groups" = $ExclGrps
        }
    }
}