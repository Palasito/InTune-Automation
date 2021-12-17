Function Add-Memberships(){
    $ReqGrps = $pol.RequiredGroups -split ";"
    $AvailGrps = $pol.AvailableGroups -split ";"
    $Body = @{
        mobileAppAssignments = @()
    }

    Write-Host "Importing policy" $policy.displayname
    Write-Host "Policy " $pol.DisplayName " with groups " $pol.RequiredGroups " and " $pol.AvailableGroups
    foreach ($grp in $ReqGrps){
       $g = Get-AzureADMSGroup | Where-Object displayname -eq $grp
        $targetmember = @{}
        $targetmember.'@odata.type' = "#microsoft.graph.groupAssignmentTarget"
        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
        $targetmember.groupId = $g.id

        $body.mobileAppAssignments += @{
            "target" = $targetmember
            "intent" = "required"
            "settings" = $null
        }
    }

    foreach($grp in $AvailGrps){
        $g = Get-AzureADMSGroup | Where-Object displayname -eq $grp
        $targetmember = @{}
        $targetmember.'@odata.type' = "#microsoft.graph.exclusionGroupAssignmentTarget"
        $targetmember.deviceAndAppManagementAssignmentFilterId = $null
        $targetmember.deviceAndAppManagementAssignmentFilterType = "none"
        $targetmember.groupId = $g.id

       $body.mobileAppAssignments += @{
            "target" = $targetmember
            "intent" = "available"
            "settings" = $null
       }
    }

    $Body = $Body | ConvertTo-Json -Depth 100
}



function Add-ClientAppGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $DCPGroups = Import-Csv -Path $Path\CSVs\DeviceConfigurationProfiles\*.csv -Delimiter ','

    foreach($Pol in $DCPGroups){
    
        try{

            if($null -ne ($Policy = Get-GeneralDeviceConfigurationPolicy | Where-Object displayName -eq $pol.DisplayName)){
                
                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"

            }

            elseif($null -ne ($Policy = Get-DeviceAdministrativeTemplates |Where-Object displayName -eq $Pol.DisplayName)){

                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            }

            elseif($null -ne ($Policy = Get-DeviceSettingsCatalogPolicy | Where-Object name -eq $Pol.DisplayName)){

                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            }
        
            else{
                Write-Host "Could not find policy:" $Pol.DisplayName -ForegroundColor Red
            }
        }

        catch{
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