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

    # Authentication region

    Get-Tokens

    #endregion
    
    ####################################################
    
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