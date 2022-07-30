Function Import-NamedLocations() {

    [cmdletbinding()]

    param(
        $Path
    )

    $BackupJsons = Get-ChildItem "$Path\NamedLocations" -Recurse -Include *.json

    Write-Host
    Write-Host "Importing Named Locations (Countries Only)..." -ForegroundColor cyan

    $AllExisting = Get-NamedLocations
    foreach ($Json in $BackupJsons) {

        $policy = Get-Content $Json.FullName | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, modifiedDateTime, version

        $check = $AllExisting | Where-Object { $_.DisplayName -eq $policy.DisplayName }
        if ($null -eq $check) {

            # $Parameters = @{
            #     OdataType                         = $policy.OdataType
            #     DisplayName                       = $policy.DisplayName
            #     IncludeUnknownCountriesAndRegions = $Policy.IncludeUnknownCountriesAndRegions
            #     CountriesAndRegion                = $Policy.CountriesAndRegions
            # }
    
            $jsontoimport = $policy | ConvertTo-Json -Depth 10

            Add-NamedLocations -JSON $jsontoimport
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Named Location"
                "Name"   = $policy.DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "Named Location $($policy.DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }

    Write-Host
    Write-Host "Creating Trusted IP Range Policy..." -ForegroundColor Cyan

    $check = $AllExisting | Where-Object { $_.DisplayName -eq "Trusted Networks" }
    if ( $null -eq $check ) {
        # $IPs = do
        # {
        #     $ip = Read-Host "Enter IP or press enter to finish"
        #     $ip
        # } while ($ip -ne '')
    
        # $IPs = ($IPs[0..($IPs.Length-2)])
    
        $IPCSV = Import-Csv $path\CSVs\IPs\*.csv
    
        $ipRanges = @()
        foreach ($i in $IPCSV) {
            $target = @{}
            $target."@odata.Type" = "#microsoft.graph.iPv4CidrRange"
            $target.cidrAddress = $i
        
            $ipRanges += $target
        }
    
        $jsontoimport = @{
            "@odata.type" = "#microsoft.graph.ipNamedLocation"
            displayName   = "Trusted Networks"
            Trusted       = $true
            ipRanges      = $ipRanges
        }
        
        $null = Add-NamedLocations -JSON $jsontoimport
    
        [PSCustomObject]@{
            "Action" = "Import"
            "Type"   = "Trusted IP Range Policy"
            "Name"   = "Trusted Networks"
            "From"   = "$($Path)\CSVs\IPs"
        }
    }
    else {
        Write-Host "Trusted IP Policy 'Trusted Networks' already exists and will not be imported" -ForegroundColor Red
    }
    
}