function Add-CAPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $CAPGroups = Import-Csv -Path $Path\CSVs\CAPGroups.csv
}