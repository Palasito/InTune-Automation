Function Get-ManagedAppPolicy() {
    
    [cmdletbinding()]
    
    param
    (
        $Name
    )
    
    $graphApiVersion = "Beta"
    $Resource = "deviceAppManagement/managedAppPolicies"
    
    try {
        
        if ($Name) {
        
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") }
        
        }
        
        else {
        
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'@odata.type').contains("ManagedAppProtection") -or ($_.'@odata.type').contains("InformationProtectionPolicy") }
        
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
    
####################################################
    
Function Get-ManagedAppProtection() {
    
    <#
    .SYNOPSIS
    This function is used to get managed app protection configuration from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any managed app protection policy
    .EXAMPLE
    Get-ManagedAppProtection -id $id -OS "Android"
    Returns a managed app protection policy for Android configured in Intune
    Get-ManagedAppProtection -id $id -OS "iOS"
    Returns a managed app protection policy for iOS configured in Intune
    Get-ManagedAppProtection -id $id -OS "WIP_WE"
    Returns a managed app protection policy for Windows 10 without enrollment configured in Intune
    .NOTES
    NAME: Get-ManagedAppProtection
    #>
    
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
    
####################################################
    
Function Export-JSONData() {
    
    <#
    .SYNOPSIS
    This function is used to export JSON data returned from Graph
    .DESCRIPTION
    This function is used to export JSON data returned from Graph
    .EXAMPLE
    Export-JSONData -JSON $JSON
    Export the JSON inputted on the function
    .NOTES
    NAME: Export-JSONData
    #>
    
    param (
    
        $JSON,
        $ExportPath
    
    )
    
    try {
    
        if ($JSON -eq "" -or $null -eq $JSON) {
    
            write-host "No JSON specified, please specify valid JSON..." -f Red
    
        }
    
        elseif (!$ExportPath) {
    
            write-host "No export path parameter set, please provide a path to export the file" -f Red
    
        }
    
        elseif (!(Test-Path $ExportPath)) {
    
            write-host "$ExportPath doesn't exist, can't export JSON Data" -f Red
    
        }
    
        else {

            $JSON1 = ConvertTo-Json $JSON -Depth 5
    
            $JSON_Convert = $JSON1 | ConvertFrom-Json
    
            $displayName = $JSON_Convert.displayName
    
            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"
    
            # $Properties = ($JSON_Convert | Get-Member | Where-Object { $_.MemberType -eq "NoteProperty" }).Name
    
            $FileName_JSON = "$DisplayName" + ".json"
    
            # write-host "Export Path:" "$ExportPath"
    
            $JSON1 | Set-Content -LiteralPath "$ExportPath\$FileName_JSON"
                
        }
    
    }
    
    catch {
    
        $_.Exception
    
    }
    
}
    
####################################################
    
function Export-AppProtectionPolicies() {
    
    [cmdletbinding()]
    
    param
    (
        $Path
    )
    
    write-host
    
    # Checking if authToken exists before running authentication
    if ($global:authToken) {
    
        # Setting DateTime to Universal time to work in all timezones
        $DateTime = (Get-Date).ToUniversalTime()
    
        # If the authToken exists checking when it expires
        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes
    
        if ($TokenExpires -le 0) {
    
            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host
    
            # Defining User Principal Name if not present
    
            if ($null -eq $User -or $User -eq "") {
    
                $global:User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host
    
            }
    
            $global:authToken = Get-AuthToken -User $User
    
        }
    }
    
    # Authentication doesn't exist, calling Get-AuthToken function
    
    else {
    
        if ($null -eq $User -or $User -eq "") {
    
            $global:User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host
    
        }
    
        # Getting the authorization token
        $global:authToken = Get-AuthToken -User $User
    
    }
    
    #endregion
    
    ####################################################
    
    $ExportPath = $Path
    
    # If the directory path doesn't exist prompt user to create the directory
    
    if (!(Test-Path "$ExportPath")) {
    
        Write-Host
        Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow
    
        $Confirm = read-host
    
        if ($Confirm -eq "y" -or $Confirm -eq "Y") {
    
            new-item -ItemType Directory -Path "$ExportPath" | Out-Null
            Write-Host
    
        }
    
        else {
    
            Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
            Write-Host
            break
    
        }
    
    }
    
    Write-Host
    
    ####################################################
    
    if (-not (Test-Path "$ExportPath\AppProtectionPolicies")) {
        $null = New-Item -Path "$ExportPath\AppProtectionPolicies" -ItemType Directory
    }

    write-host "Exporting App Protection Policies" -f Cyan
    
    $ManagedAppPolicies = Get-ManagedAppPolicy | Where-Object { ($_.'@odata.type').contains("ManagedAppProtection") }
    
    if ($ManagedAppPolicies) {
    
        foreach ($ManagedAppPolicy in $ManagedAppPolicies) {
    
            # write-host "Managed App Policy:"$ManagedAppPolicy.displayName -f Cyan
    
            if ($ManagedAppPolicy.'@odata.type' -eq "#microsoft.graph.androidManagedAppProtection") {
    
                $AppProtectionPolicy = Get-ManagedAppProtection -id $ManagedAppPolicy.id -OS "Android"
    
                $AppProtectionPolicy | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value "#microsoft.graph.androidManagedAppProtection"
    
                # $AppProtectionPolicy
    
                Export-JSONData -JSON $AppProtectionPolicy -ExportPath "$ExportPath\AppProtectionPolicies"

                [PSCustomObject]@{
                    "Action" = "Export"
                    "Type"   = "App Protection Policy"
                    "Name"   = $AppProtectionPolicy.displayName
                    "Path"   = "$ExportPath\AppProtectionPolicies"
                }
    
            }
    
            elseif ($ManagedAppPolicy.'@odata.type' -eq "#microsoft.graph.iosManagedAppProtection") {
    
                $AppProtectionPolicy = Get-ManagedAppProtection -id $ManagedAppPolicy.id -OS "iOS"
    
                $AppProtectionPolicy | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value "#microsoft.graph.iosManagedAppProtection"
    
                # $AppProtectionPolicy
    
                Export-JSONData -JSON $AppProtectionPolicy -ExportPath "$ExportPath\AppProtectionPolicies"

                [PSCustomObject]@{
                    "Action" = "Export"
                    "Type"   = "App Protection Policy"
                    "Name"   = $AppProtectionPolicy.displayName
                    "Path"   = "$ExportPath\AppProtectionPolicies"
                }
    
            }
    
        }
    
    }

}