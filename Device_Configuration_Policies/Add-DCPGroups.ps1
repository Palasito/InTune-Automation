Function Get-DeviceSettingsCatalogPolicy(){
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/configurationPolicies"
        
        try {
        
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
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

Function Get-DeviceAdministrativeTemplates(){
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DAT_Resource = "deviceManagement/groupPolicyConfigurations"
        
        try {
        
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DAT_Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
        
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

Function Get-GeneralDeviceConfigurationPolicy(){

    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $GDC_resource = "deviceManagement/deviceConfigurations"
        
        try {
        
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($GDC_resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
        
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

Function Add-Memberships(){
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
}

function Add-DCPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $DCPGroups = Import-Csv -Path $Path\CSVs\DeviceConfigurationProfiles\*.csv -Delimiter ','

    Write-Host "Adding specified Groups to the Configuration Policies" -ForegroundColor Cyan

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