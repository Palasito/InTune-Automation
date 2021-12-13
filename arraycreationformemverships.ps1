$test = Import-Csv -Path c:\script_output\test\csv\testcsv.csv

$Grps = $test.Members -split ";"
$Importarray = New-Object System.Collections.Generic.List[System.Object]

foreach ($grp in $Grps){
    $Importarray.Add("$grp")
}

$null = $Importarray.ToArray()

$Importarray | ConvertTo-Json -Depth 5
