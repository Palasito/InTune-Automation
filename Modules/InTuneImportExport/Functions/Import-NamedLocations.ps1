Function Import-NamedLocations(){

    [cmdletbinding()]

    param(
        $Path
    )

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
}

Write-Host "Creating Trusted IP Range Policy..."

[System.Collections.Generic.List`1[Microsoft.Open.MSGraph.Model.IpRange]]$cidrAddress = @()
$IPs = do
{
    $ip = Read-Host "Enter IP or press enter to finish"
    $ip
} while ($ip -ne '')

$IPs = ($IPs[0..($IPs.Length-2)])

foreach($i in $IPs){
    $cidrAddress.Add("$i")
}

$Parameters = @{
    OdataType       = '#microsoft.graph.ipNamedLocation'
    DisplayName     = 'Trusted Networks'
    IsTrusted       = $true
    IpRanges        = $cidrAddress
}
New-AzureADMSNamedLocationPolicy @parameters

}