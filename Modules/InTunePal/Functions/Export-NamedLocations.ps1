Function Export-NamedLocations() {

    [cmdletbinding()]

    param(
        $Path
    )

    #Region Authentication
    $null = Get-Token
    #EndRegion
    
    if (-not (Test-Path "$Path\NamedLocations")) {
        $null = New-Item -Path "$Path\NamedLocations" -ItemType Directory
    }

    $NamedLocations = Get-NamedLocations | Where-Object '@odata.type' -Match 'countryNamedLocation'

    Write-Host
    Write-Host "Exporting Named Location Policies..." -ForegroundColor Cyan

    foreach ($Loc in $NamedLocations) {

        $PolicyJSON = $Loc | ConvertTo-Json -Depth 6

        $JSONdisplayName = $Loc.DisplayName

        $FinalJSONDisplayName = $JSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $PolicyJSON | Out-File $Path\NamedLocations\$($FinalJSONdisplayName).json

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Named Location Policy"
            "Name"   = $Loc.DisplayName
            "Path"   = "NamedLocations\$($FinalJSONdisplayName).json"
        }

    }
}

