function Add-DUPGroups() {
    
    [cmdletbinding()]
    
    param(
        $Path
    )
    
    Write-Host "Adding specified groups to Software Update Policies..." -ForegroundColor Cyan
    $DCPGroups = Import-Csv -Path $Path\CSVs\UpdatePolicies\*.csv -Delimiter ','
    $gr = Get-Groups
    
    foreach ($Pol in $DCPGroups) {
        $Policy = Get-SoftwareUpdatePolicyAssignments | Where-Object displayName -eq $pol.DisplayName
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
        
        Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
        
        [PSCustomObject]@{
            "Action"          = "Assign"
            "Type"            = "Update Policy"
            "Name"            = $policy.DisplayName
            "Included Groups" = $InclGrps
            "Excluded Groups" = $ExclGrps
        }
    }
}