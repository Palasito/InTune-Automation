Function Get-SoftwareUpdatePolicyAssignments() {
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    
    try {
    
        $Resource = "deviceManagement/deviceConfigurations"
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
    
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
    
####################################################

function Add-DUPGroups() {
    
    [cmdletbinding()]
    
    param(
        $Path
    )
    
    Write-Host "Adding specified groups to Software Update Policies..." -ForegroundColor Cyan
    $DCPGroups = Import-Csv -Path $Path\CSVs\UpdatePolicies\*.csv -Delimiter ','
    
    foreach ($Pol in $DCPGroups) {
        $Policy = Get-SoftwareUpdatePolicyAssignments | Where-Object displayName -eq $pol.DisplayName
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
            elseif ([string]::IsNullOrEmpty($grp)){

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
            elseif ([string]::IsNullOrEmpty($grp)){

            }
            else {
                Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
            }
        }
            
        $Body = $Body | ConvertTo-Json -Depth 100
        
        Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
        
        [PSCustomObject]@{
            "Action"          = "Assign"
            "Type"            = "Update Policy"
            "Name"            = $policy.DisplayName
            "Included Groups" = $InclGrps
            "Excluded Groups" = $ExclGrps
        }
    }
    
}