Function Get-DeviceCompliancePolicy(){

    <#
    .SYNOPSIS
    This function is used to get device compliance policies from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any device compliance policies
    .EXAMPLE
    Get-DeviceCompliancePolicy
    Returns any device compliance policies configured in Intune
    .EXAMPLE
    Get-DeviceCompliancePolicy -Android
    Returns any device compliance policies for Android configured in Intune
    .EXAMPLE
    Get-DeviceCompliancePolicy -iOS
    Returns any device compliance policies for iOS configured in Intune
    .NOTES
    NAME: Get-DeviceCompliancePolicy
    #>
    
    [cmdletbinding()]
    
    param
    (
        $Name,
        [switch]$Android,
        [switch]$iOS,
        [switch]$Win10
    )
    
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceCompliancePolicies"
    
        try {
    
            $Count_Params = 0
    
            if($Android.IsPresent){ $Count_Params++ }
            if($iOS.IsPresent){ $Count_Params++ }
            if($Win10.IsPresent){ $Count_Params++ }
            if($Name.IsPresent){ $Count_Params++ }
    
            if($Count_Params -gt 1){
    
            write-host "Multiple parameters set, specify a single parameter -Android -iOS or -Win10 against the function" -f Red
    
            }
    
            elseif($Android){
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("android") }
    
            }
    
            elseif($iOS){
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("ios") }
    
            }
    
            elseif($Win10){
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("windows10CompliancePolicy") }
    
            }
    
            elseif($Name){
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") }
    
            }
    
            else {
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
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


function Add-DCPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $DCPGroups = Import-Csv -Path $Path\CSVs\CompliancePolicies\*.csv -Delimiter ','

    foreach($Pol in $DCPGroups){
        $Policy = Get-DeviceCompliancePolicy | Where-Object displayName -match $pol.DisplayName
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
    
        Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
    }

}