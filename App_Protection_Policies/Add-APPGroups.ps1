Function Get-AndroidAPPPolicy(){
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceAppManagement/androidManagedAppProtections"
        
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

Function Get-iOSAPPPolicy(){
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceAppManagement/iosManagedAppProtections"
        
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

Function Get-WindowsInformationProtectionPolicy(){
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceAppManagement/windowsInformationProtectionPolicies"
        
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

Function Get-mdmWindowsInformationProtectionPolicy(){
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceAppManagement/mdmWindowsInformationProtectionPolicies"
        
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

function Add-APPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $APPGroups = Import-Csv -Path $Path\CSVs\AppProtection\*.csv -Delimiter ','

    foreach($Pol in $APPGroups){
    
        try{

            if($null -ne ($Policy = Get-AndroidAPPPolicy | Where-Object displayName -eq $pol.DisplayName)){
                
                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/androidManagedAppProtections/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"

            }

            elseif($null -ne ($Policy = Get-iOSAPPPolicy |Where-Object displayName -eq $Pol.DisplayName)){

                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/iosManagedAppProtections/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            }

            elseif($null -ne ($Policy = Get-WindowsInformationProtectionPolicy | Where-Object name -eq $Pol.DisplayName)){

                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/windowsInformationProtectionPolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
            }

            elseif($null -ne ($Policy = Get-mdmWindowsInformationProtectionPolicy | Where-Object name -eq $Pol.DisplayName)){

                Add-Memberships
                $null = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mdmWindowsInformationProtectionPolicies/$($Policy.id)/assign" -Headers $authToken -Method Post -Body $Body -ContentType "application/json"
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