Function Import-NamedLocations() {

    [cmdletbinding()]

    param(
        $Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion

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

            Write-Host "Imported Named Location $($policy.DisplayName)"
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

        $IPCSV = Import-Csv -Path (Get-ChildItem -Path "$path\CSVs\NamedLocations\IPs" -Filter '*.csv').FullName
        if ($ull -eq $IPCSV) {
            Write-Host "No trusted Networks are going to be created. Csv was not found. Make sure to remove the trusted Networks from all conditional access policies you want to import" -ForegroundColor Yellow
        }
        else {
            $ipRanges = @()
            foreach ($i in $IPCSV) {
                $target = @{}
                $target."@odata.Type" = "#microsoft.graph.iPv4CidrRange"
                $target.cidrAddress = $i.IP
            
                $ipRanges += $target
            }
        
            $jsontoimporttemp = @{
                "@odata.type" = "#microsoft.graph.ipNamedLocation"
                displayName   = "Trusted Networks"
                isTrusted     = $true
                ipRanges      = $ipRanges
            }
    
            $jsontoimport = $jsontoimporttemp | ConvertTo-Json -Depth 10
            
            Add-NamedLocations -JSON $jsontoimport
        
            Write-Host "Imported Trusted IP Range Policy 'Trusted Networks'"
        }
    }
    else {
        Write-Host "Trusted IP Policy 'Trusted Networks' already exists and will not be imported" -ForegroundColor Red
    }
}