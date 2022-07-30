function Add-CAPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','

    Write-host
    Write-Host "Assigning Groups to Conditional Access Policies" -ForegroundColor Cyan
    $gr = Get-Groups

    $AllExisting = Get-ConditionalAccessPolicies
    foreach ($Pol in $CAPGroups) {
        $Policy = $AllExisting | Where-Object displayName -eq $pol.DisplayName
        $JSON = @{
            conditions = @{
                users = @{}
            }
        }
        $InclGrps = $pol.IncludeGroups -split ";"
        $ExclGrps = $pol.ExcludeGroups -split ";"

        foreach ($grp in $InclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = $gr | Where-Object { $_.displayName -eq $grp }
                $JSON.conditions.users.includeUsers = @{}
                if ($null -ne $g) {
                    $JSON.conditions.Users.includeGroups += $g.Id
                }
                elseif ($grp -eq "GuestsOrExternalUsers"){
                    $JSON.conditions.users.includeUsers = "GuestsOrExternalUsers"
                }
                else {
                    
                }
            }
            else {
                $JSON.conditions.users.includeUsers = "All"
            }
        }

        foreach ($grp in $ExclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = $gr | Where-Object { $_.displayName -eq $grp }
                if ($null -ne $g) {
                    $JSON.conditions.users.excludeGroups += $g.Id
                }
                elseif ($grp -eq "GuestsOrExternalUsers"){
                    $JSON.conditions.users.includeUsers = "GuestsOrExternalUsers"
                }
                else {
                    
                }
            }
            else {

            }
        }

        $j = $JSON | ConvertTo-Json -Depth 5
        $uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$($Policy.id)"
        $null = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Patch -Body $j -ContentType "application/json" 
        Start-Sleep 3

        [PSCustomObject]@{
            "Action"          = "Assign"
            "Type"            = "Conditional Access Policy"
            "Name"            = $Policy.displayName
            "Included Groups" = $InclGrps
            "Excluded Groups" = $ExclGrps
        }
    }

}