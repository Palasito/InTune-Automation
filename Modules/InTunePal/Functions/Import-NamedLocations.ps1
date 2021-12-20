Function Import-NamedLocations(){

    [cmdletbinding()]

    param(
        $Path,
        $AzureADToken
    )

if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens){
    Write-Host "Getting AzureAD authToken"
    Connect-AzureAD
} else {
    $global:azureADToken = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
        
}

$BackupJsons = Get-ChildItem "$Path\NamedLocations" -Recurse -Include *.json

Write-Host "Importing Named Locations (Countries Only)..." -ForegroundColor cyan
foreach ($Json in $BackupJsons) {

    $policy = Get-Content $Json | ConvertFrom-Json

    $Parameters = @{
    OdataType       = $policy.OdataType
    DisplayName     = $policy.DisplayName
    IncludeUnknownCountriesAndRegions       = $Policy.IncludeUnknownCountriesAndRegions
    CountriesAndRegion   = $Policy.CountriesAndRegions

    }

    New-AzureADMSNamedLocationPolicy @Parameters

    [PSCustomObject]@{
        "Action" = "Import"
        "Type"   = "Named Location"
        "Name"   = $policy.DisplayName
        "From"   = "$json"
    }
}

Write-Host "Creating Trusted IP Range Policy..."

[System.Collections.Generic.List`1[Microsoft.Open.MSGraph.Model.IpRange]]$cidrAddress = @()
# $IPs = do
# {
#     $ip = Read-Host "Enter IP or press enter to finish"
#     $ip
# } while ($ip -ne '')

# $IPs = ($IPs[0..($IPs.Length-2)])

$IPCSV = Import-Csv $path\CSVs\IPs\*.csv

foreach($i in $IPCSV){
    $IP = $i.IP
    $cidrAddress.Add("$IP")
}

$Parameters = @{
    OdataType       = '#microsoft.graph.ipNamedLocation'
    DisplayName     = 'Trusted Networks'
    IsTrusted       = $true
    IpRanges        = $cidrAddress
}
$null = New-AzureADMSNamedLocationPolicy @parameters

[PSCustomObject]@{
    "Action" = "Import"
    "Type"   = "Trusted IP Range Policy"
    "Name"   = "Trusted Networks"
    "From"   = "$($Path)\CSVs\IPs"
}

}