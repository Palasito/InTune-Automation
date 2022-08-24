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

            $JSON1 = ConvertTo-Json $JSON -Depth 5

            $JSON_Convert = $JSON1 | ConvertFrom-Json

            $displayName = $JSON_Convert.displayName

            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

            $Properties = ($JSON_Convert | Get-Member | Where-Object { $_.MemberType -eq "NoteProperty" }).Name

            $FileName_JSON = "$DisplayName" + ".json"

            $Object = New-Object System.Object

            foreach ($Property in $Properties) {

                $Object | Add-Member -MemberType NoteProperty -Name $Property -Value $JSON_Convert.$Property

            }

            $JSON1 | Set-Content -LiteralPath "$ExportPath\DeviceCompliancePolicies\$FileName_JSON"
            
        }

    }

    catch {

        $_.Exception

    }

}

####################################################

function Export-CompliancePolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    #Region Authentication 
    if ($global:authToken) {
        #Do nothing
    }
    else {
        $null = Get-Token
    }
    #endregion

    ####################################################

    $ExportPath = $Path

    # If the directory path doesn't exist prompt user to create the directory
    $ExportPath = $ExportPath.replace('"', '')

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

    if (-not (Test-Path "$ExportPath\DeviceCompliancePolicies")) {
        $null = New-Item -Path "$ExportPath\DeviceCompliancePolicies" -ItemType Directory
    }

    Write-Host "Exporting Device Compliance Policies..." -ForegroundColor cyan
    $CPs = Get-DeviceCompliancePolicy

    foreach ($CP in $CPs) {
        Export-JSONData -JSON $CP -ExportPath "$ExportPath\DeviceCompliancePolicies"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Compliance Policy"
            "Name"   = $CP.displayName
            "Path"   = "$ExportPath"
        }
    }
}