Function Export-NamedLocations(){

    [cmdletbinding()]

    param(
        $Path,
        $azureADToken
    )

    if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens){
        Write-Host "Getting AzureAD authToken"
        Connect-AzureAD
    } else {
        $global:azureADToken = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
        
    }

    if (-not (Test-Path "$Path\NamedLocations")) {
        $null = New-Item -Path "$Path\NamedLocations" -ItemType Directory
    }

    $NamedLocations = Get-AzureADMSNamedLocationPolicy | Where-Object 'OdataType' -Match 'countryNamedLocation'

    Write-Host
    Write-Host "Exporting Named Location Policies..." -ForegroundColor Cyan

    foreach($Loc in $NamedLocations){

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

