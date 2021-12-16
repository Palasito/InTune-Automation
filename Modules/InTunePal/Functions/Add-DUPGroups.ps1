Function Get-SoftwareUpdatePolicy(){
    
    <#
    .SYNOPSIS
    This function is used to get Software Update policies from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any Software Update policies
    .EXAMPLE
    Get-SoftwareUpdatePolicy -Windows10
    Returns Windows 10 Software Update policies configured in Intune
    .EXAMPLE
    Get-SoftwareUpdatePolicy -iOS
    Returns iOS update policies configured in Intune
    .NOTES
    NAME: Get-SoftwareUpdatePolicy
    #>
    
    [cmdletbinding()]
    
    param
    (

    )
    
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

    function Add-DUPGroups(){
    
        [cmdletbinding()]
    
        param(
            $Path
        )
    
        $DCPGroups = Import-Csv -Path $Path\CSVs\UpdatePolicies\*.csv -Delimiter ','
    
        foreach($Pol in $DCPGroups){
            $Policy = Get-SoftwareUpdatePolicy | Where-Object displayName -match $pol.DisplayName
            $InclGrps = $pol.IncludeGroups -split ";"
            $ExclGrps = $pol.ExcludeGroups -split ";"
            $Body = @{
                assignments = @()
            }
    
            Write-Host "Importing policy" $policy.displayname
            Write-Host "Policy " $pol.DisplayName " with groups " $pol.IncludeGroups " and " $pol.ExcludeGroups
                foreach ($grp in $InclGrps){
                    $g = Get-AzureADMSGroup | Where-Object displayname -eq $grp
                    $targetmember = @{}
                    $targetmember.'@odata.type' = "#microsoft.graph.groupAssignmentTarget"
                    $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                    $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                    $targetmember.groupId = $g.id
    
                    $body.assignments += @{
                        "target" = $targetmember
                    }
                }
    
                foreach($grp in $ExclGrps){
                    $g = Get-AzureADMSGroup | Where-Object displayname -eq $grp
                    $targetmember = @{}
                    $targetmember.'@odata.type' = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    $targetmember.deviceAndAppManagementAssignmentFilterId = $null
                    $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
                    $targetmember.groupId = $g.id
    
                    $body.assignments += @{
                        "target" = $targetmember
                    }
                }
            
            $Body = $Body | ConvertTo-Json -Depth 100
        
            Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
        }
    
    }