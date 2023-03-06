function Import-ConditionalAccessPolicies() {

    param(
        $Path,
        $Prefix,
        $AzureADToken
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion

    $BackupJsons = Get-ChildItem "$Path\ConditionalAccessPolicies" -Recurse -Include *.json

    Write-Host
    Write-Host "Importing Conditional Access Policies..." -ForegroundColor cyan

    $Allexisting = Get-ConditionalAccessPolicies
    $NamedLocations = Get-NamedLocations
    foreach ($Json in $BackupJsons) {

        $policy = Get-Content $Json.FullName | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, ModifiedDateTime, version

        $check = $Allexisting | Where-object { $_.displayName -eq $policy.DisplayName }

        if ($null -eq $check) {

            #Region Users
            $includeUsers = @(
                "none"
            )
            $Users = @{
                includeUsers = $includeUsers
            }
            $policy.conditions.users = $Users
            #EndRegion

            #Region Locations
            $OldInclLocations = $policy.Conditions.Locations.IncludeLocations
            $OldExclLocations = $Policy.Conditions.Locations.ExcludeLocations
            $ExcludeLocations = @()
            $IncludeLocations = @()
            if ($null -ne $OldInclLocations) {
                foreach ($loc in $OldExclLocations) {
                    if (-not[string]::IsNullOrEmpty($OldExclLocations)) {
                        $Exclloc = $NamedLocations | Where-object { $_.displayName -eq $loc }
                        $ExcludeLocations += $Exclloc.Id
                    }
                }
                foreach ($loc in $OldInclLocations) {
                    if ($OldInclLocations = "All") {
                        $IncludeLocations += "All"
                    }
                    elseif (-not[string]::IsNullOrEmpty($OldInclLocations)) {
                        $Inclloc = $NamedLocations | Where-object { $_.displayName -eq $loc }
                        $IncludeLocations += $Inclloc.Id
                    }
                }
                $Locations = @{
                    includeLocations = $IncludeLocations
                    excludeLocations = $ExcludeLocations
                }

                $policy.conditions.locations = $locations
            }
            #EndRegion

            #Region Disable policy
            $policy.state = "disabled"
            #EndRegion
            $jsontoImport = $policy | ConvertTo-Json -Depth 10

            Write-Host "Imported Conditional Access Policy $($DisplayName)"

            $null = Add-ConditionalAccessPolicy -JSON $jsontoImport

            Start-Sleep 3
        }
        else {
            Write-Host "Conditional Access policy $($policy.DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}