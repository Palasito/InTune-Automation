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