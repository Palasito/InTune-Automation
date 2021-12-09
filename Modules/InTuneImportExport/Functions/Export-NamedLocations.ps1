Function Export-NamedPolicies(){

    [cmdletbinding()]

    param(
        $Path
    )

    if (-not (Test-Path "$Path\NamedLocations")) {
        $null = New-Item -Path "$Path\NamedLocations" -ItemType Directory
    }

    $NamedLocations = get-AzureADMSNamedLocationPolicy | Where-Object 'OdataType' -Contains 'countryNamedLocation'

    foreach($Loc in $NamedLocations){

        $PolicyJSON = $Loc | ConvertTo-Json -Depth 6

        $JSONdisplayName = $Loc.DisplayName

        $FinalJSONDisplayName = $JSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $PolicyJSON | Out-File $Path\NamedLocations\$($FinalJSONdisplayName).json

    }
}

