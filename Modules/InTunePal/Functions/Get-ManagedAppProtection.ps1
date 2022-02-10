Function Get-ManagedAppProtection() {
    
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $id,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Android", "iOS", "WIP_WE", "WIP_MDM")]
        $OS    
    )
    
    $graphApiVersion = "Beta"
    
    try {
        
        if ($id -eq "" -or $null -eq $id) {
        
            write-host "No Managed App Policy id specified, please provide a policy id..." -f Red
            break
        
        }
        
        else {
        
            if ($OS -eq "" -or $null -eq $OS) {
        
                write-host "No OS parameter specified, please provide an OS. Supported value are Android,iOS,WIP_WE,WIP_MDM..." -f Red
                Write-Host
                break
        
            }
        
            elseif ($OS -eq "Android") {
        
                $Resource = "deviceAppManagement/androidManagedAppProtections('$id')/?`$expand=apps"
        
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
                Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
        
            }
        
            elseif ($OS -eq "iOS") {
        
                $Resource = "deviceAppManagement/iosManagedAppProtections('$id')/?`$expand=apps"
        
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
                Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
        
            }
    
            elseif ($OS -eq "WIP_WE") {
        
                $Resource = "deviceAppManagement/windowsInformationProtectionPolicies('$id')?`$expand=protectedAppLockerFiles,exemptAppLockerFiles,assignments"
        
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
                Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
        
            }
    
            elseif ($OS -eq "WIP_MDM") {
        
                $Resource = "deviceAppManagement/mdmWindowsInformationProtectionPolicies('$id')?`$expand=protectedAppLockerFiles,exemptAppLockerFiles,assignments"
        
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
                Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
    
            }
        
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