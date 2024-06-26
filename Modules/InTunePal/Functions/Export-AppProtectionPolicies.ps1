Function Export-JSONData() {
    
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
            $JSON1 = ConvertTo-Json $JSON -Depth 100
            $JSON_Convert = $JSON1 | ConvertFrom-Json
            $displayName = $JSON_Convert.displayName

            $DisplayName = $DisplayName.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $FileName_JSON = "$DisplayName" + ".json"
            $JSON1 | Set-Content -LiteralPath "$ExportPath\$FileName_JSON"
        }
    }
    
    catch {
        $ex = $_.Exception
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
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
    
    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion
    
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
    
    ####################################################
    
    if (-not (Test-Path "$ExportPath\AppProtectionPolicies")) {
        $null = New-Item -Path "$ExportPath\AppProtectionPolicies" -ItemType Directory
    }

    write-host "Exporting App Protection Policies" -f Cyan
    $ManagedAppPolicies = Get-ManagedAppPolicy | Where-Object { ($_.'@odata.type').contains("ManagedAppProtection") }
    
    if ($ManagedAppPolicies) {
        foreach ($ManagedAppPolicy in $ManagedAppPolicies) {
            if ($ManagedAppPolicy.'@odata.type' -eq "#microsoft.graph.androidManagedAppProtection") {
                $AppProtectionPolicy = Get-ManagedAppProtection -id $ManagedAppPolicy.id -OS "Android"
                $AppProtectionPolicy | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value "#microsoft.graph.androidManagedAppProtection"
                Export-JSONData -JSON $AppProtectionPolicy -ExportPath "$ExportPath\AppProtectionPolicies"
                Write-Host "Exported App Protection Policy: $($AppProtectionPolicy.displayName)"      
            }
    
            elseif ($ManagedAppPolicy.'@odata.type' -eq "#microsoft.graph.iosManagedAppProtection") {
                $AppProtectionPolicy = Get-ManagedAppProtection -id $ManagedAppPolicy.id -OS "iOS"
                $AppProtectionPolicy | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value "#microsoft.graph.iosManagedAppProtection"
                Export-JSONData -JSON $AppProtectionPolicy -ExportPath "$ExportPath\AppProtectionPolicies"
                Write-Host "Exported App Protection Policy: $($AppProtectionPolicy.displayName)"    
            }
        }
    }
}