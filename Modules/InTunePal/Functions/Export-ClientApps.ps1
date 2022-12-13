Function Export-JSONData() {
    param (

        $JSON,
        $Type,
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

            $JSON1 = ConvertTo-Json $JSON

            $JSON_Convert = $JSON1 | ConvertFrom-Json

            $displayName = $JSON_Convert.displayName

            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

            $Properties = ($JSON_Convert | Get-Member | Where-Object { $_.MemberType -eq "NoteProperty" }).Name

            if ($Type) {

                $FileName_JSON = "$DisplayName" + ".json"

            }

            else {

                $FileName_JSON = "$DisplayName" + "_" + ".json"

            }

            $Object = New-Object System.Object

            foreach ($Property in $Properties) {

                $Object | Add-Member -MemberType NoteProperty -Name $Property -Value $JSON_Convert.$Property

            }

            write-host "Export Path:" "$ExportPath"

            $JSON1 | Set-Content -LiteralPath "$ExportPath\$FileName_JSON"
            write-host "JSON created in $ExportPath\$FileName_JSON..." -f cyan
            
        }

    }

    catch {

        $_.Exception

    }

}

####################################################

function Export-ClientApps() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    write-host

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

    ####################################################

    if (-not (Test-Path "$ExportPath\ClientApps")) {
        $null = New-Item -Path "$ExportPath\ClientApps" -ItemType Directory
    }


    if (-not (Test-Path "$ExportPath\ClientApps\AndroidApps")) {
        $null = New-Item -Path "$ExportPath\ClientApps\AndroidApps" -ItemType Directory
    }


    if (-not (Test-Path "$ExportPath\ClientApps\iOSApps")) {
        $null = New-Item -Path "$ExportPath\ClientApps\iOSApps" -ItemType Directory
    }


    if (-not (Test-Path "$ExportPath\ClientApps\WindowsApps")) {
        $null = New-Item -Path "$ExportPath\ClientApps\WindowsApps" -ItemType Directory
    }

    $MDMApps = Get-IntuneApplication

    Write-Host "Exporting Client Apps" -ForegroundColor Cyan

    if ($MDMApps) {

        foreach ($App in $MDMApps) {

            if ($App.'@odata.type'.Contains("android")) {
                $Application = Get-IntuneApplication -AppId $App.id
                $Type = $Application.'@odata.type'.split(".")[2]
    
                Export-JSONData -JSON $Application -Type $Type -ExportPath "$ExportPath\ClientApps\AndroidApps"

                Write-Host "Exported Client App: $($App.displayName)"
            }
        
            elseif ($App.'@odata.type'.Contains("ios")) {
                $Application = Get-IntuneApplication -AppId $App.id
                $Type = $Application.'@odata.type'.split(".")[2]

                Export-JSONData -JSON $Application -Type $Type -ExportPath "$ExportPath\ClientApps\iOSApps"

                Write-Host "Exported Client App: $($App.displayName)"
            }

            elseif ($App.'@odata.type'.Contains("windows") -or $App.'@odata.type'.Contains("microsoftStoreForBusinessApp")) {
                $Application = Get-IntuneApplication -AppId $App.id
                $Type = $Application.'@odata.type'.split(".")[2]
    
                Export-JSONData -JSON $Application -Type $Type -ExportPath "$ExportPath\ClientApps\WindowsApps"

                Write-Host "Exported Client App: $($App.displayName)"
            }
            else {
                $Application = Get-IntuneApplication -AppId $App.id
                $Type = $Application.'@odata.type'.split(".")[2]

                Export-JSONData -JSON $Application -Type $Type -ExportPath "$ExportPath\ClientApps"

                Write-Host "Exported Client App: $($App.displayName)"
            }
        
        }

    }

    else {

        Write-Host "No MDM Applications added to the Intune Service..." -ForegroundColor Red
        Write-Host

    }

}