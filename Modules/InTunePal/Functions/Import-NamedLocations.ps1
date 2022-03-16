Function Import-NamedLocations() {

    [cmdletbinding()]

    param(
        $Path,
        $AzureADToken
    )

    if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens) {
        Write-Host "Getting AzureAD authToken"
        Connect-AzureAD
    }
    else {
        $global:azureADToken = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
        
    }

    $BackupJsons = Get-ChildItem "$Path\NamedLocations" -Recurse -Include *.json

    Write-Host
    Write-Host "Importing Named Locations (Countries Only)..." -ForegroundColor cyan

    $AllExisting = Get-AzureADMSNamedLocationPolicy
    foreach ($Json in $BackupJsons) {

        $policy = Get-Content $Json | ConvertFrom-Json

        $check = $AllExisting | Where-Object { $_.DisplayName -eq $policy.DisplayName }
        if ($null -eq $check) {
            $Parameters = @{
                OdataType                         = $policy.OdataType
                DisplayName                       = $policy.DisplayName
                IncludeUnknownCountriesAndRegions = $Policy.IncludeUnknownCountriesAndRegions
                CountriesAndRegion                = $Policy.CountriesAndRegions
            }
    
            New-AzureADMSNamedLocationPolicy @Parameters
    
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
        [System.Collections.Generic.List`1[Microsoft.Open.MSGraph.Model.IpRange]]$cidrAddress = @()
        # $IPs = do
        # {
        #     $ip = Read-Host "Enter IP or press enter to finish"
        #     $ip
        # } while ($ip -ne '')
    
        # $IPs = ($IPs[0..($IPs.Length-2)])
    
        $IPCSV = Import-Csv $path\CSVs\IPs\*.csv
    
        foreach ($i in $IPCSV) {
            $IP = $i.IP
            $cidrAddress.Add("$IP")
        }
    
        $Parameters = @{
            OdataType   = '#microsoft.graph.ipNamedLocation'
            DisplayName = 'Trusted Networks'
            IsTrusted   = $true
            IpRanges    = $cidrAddress
        }
        $null = New-AzureADMSNamedLocationPolicy @parameters
    
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