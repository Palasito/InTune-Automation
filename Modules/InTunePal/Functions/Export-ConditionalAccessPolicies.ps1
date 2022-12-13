function Export-ConditionalAccessPolicies() {

    param(
        $Path,
        $AzureADToken
    )

    #Region Authentication
    if ($global:authToken) {
        #Do nothing
    }
    else {
        $null = Get-Token
    }
    #EndRegion

    if (-not (Test-Path "$Path\ConditionalAccessPolicies")) {
        $null = New-Item -Path "$Path\ConditionalAccessPolicies" -ItemType Directory
    }

    Write-Host
    Write-Host "Exporting Conditional Access Policies..." -ForegroundColor cyan

    $ExistingGroups = Get-AADGroups
    $AllPolicies = Get-ConditionalAccessPolicies
    $NamedLocations = Get-NamedLocations
    
    foreach ($Policy in $AllPolicies) {

        #Region Locations
        $OldInclLocations = $policy.Conditions.Locations.IncludeLocations
        $OldExclLocations = $Policy.Conditions.Locations.ExcludeLocations
        $ExcludeLocations = @()
        $IncludeLocations = @()
        if ($null -ne $OldInclLocations) {
            foreach ($loc in $OldExclLocations) {
                if (-not[string]::IsNullOrEmpty($OldExclLocations)) {
                    $Exclloc = $NamedLocations | Where-object { $_.Id -eq $loc }
                    $ExcludeLocations += $Exclloc.DisplayName
                }
            }
            foreach ($loc in $OldInclLocations) {
                if ($OldInclLocations -contains "All") {
                    $IncludeLocations += "All"
                }
                elseif (-not[string]::IsNullOrEmpty($OldInclLocations)) {
                    $Inclloc = $NamedLocations | Where-object { $_.Id -eq $loc }
                    $IncludeLocations += $Inclloc.DisplayName
                }
            }
            $Locations = @{
                includeLocations = $IncludeLocations
                excludeLocations = $ExcludeLocations
            }
        
            $policy.conditions.locations = $locations
        }
        #EndRegion

        #Region Groups
        $InclGrps = $policy.Conditions.Users.IncludeGroups
        $ExclGrps = $Policy.Conditions.Users.ExcludeGroups
        $ExcludeGrps = @()
        $IncludeGrps = @()

        if ( $InclGrps.length -gt 0 ) {
            foreach ($grp in $InclGrps) {
                $ig = $ExistingGroups | Where-Object ( $_.id -eq $grp)
                $IncludeGrps += $ig.displayName
            }
        }

        if ( $ExclGrps.length -gt 0 ) {
            foreach ($grp in $ExclGrps) {
                $eg = $ExistingGroups | Where-Object ( $_.id -eq $grp)
                $ExcludeGrps += $eg.displayName
            }
        }

        $Policy.Conditions.Users.includeGroups = $IncludeGrps
        $Policy.Conditions.Users.excludeGroups = $ExcludeGrps

        #EndRegion
        
        $PolicyJSON = $Policy | ConvertTo-Json -Depth 20

        $JSONdisplayName = $Policy.DisplayName

        $FinalJSONDisplayName = $JSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $PolicyJSON | Out-File -LiteralPath "$($Path)\ConditionalAccessPolicies\$($FinalJSONdisplayName).json"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Conditional Access Policy"
            "Name"   = $Policy.DisplayName
        }
    }
}