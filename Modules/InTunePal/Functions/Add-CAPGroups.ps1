function Add-CAPGroups() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    $CAPGroupsCheck = Get-ChildItem -Path $Path\CSVs\ConditionalAccess

    if ($null -eq $CAPGroupsCheck) {
        Write-Host "No CSVs found containing groups to assign for the Conditional Access Policies !" -ForegroundColor Yellow
        break
    }

    else {
        $CAPGroups = $CAPGroupsCheck | ForEach-Object { Import-Csv $Path\CSVs\ConditionalAccess\$_ -Delimiter "," }
    }

    Write-host
    Write-Host "Assigning Groups to Conditional Access Policies" -ForegroundColor Cyan
    $gr = Get-AADGroups

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

        $InGrp = @()
        $ExGrp = @()


        foreach ($grp in $InclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = $gr | Where-Object { $_.displayName -eq $grp }
                $JSON.conditions.users.includeUsers = @("none")
                if ($null -ne $g) {
                    $InGrp += $g.Id
                }
                elseif ($grp -eq "GuestsOrExternalUsers") {
                    $JSON.conditions.users.includeUsers = @("GuestsOrExternalUsers")
                }
                else {
                    
                }
            }
            else {
                $JSON.conditions.users.includeUsers = @("All Users")
            }
        }

        foreach ($grp in $ExclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = $gr | Where-Object { $_.displayName -eq $grp }
                if ($null -ne $g) {
                    $ExGrp += $g.Id
                }
                elseif ($grp -eq "GuestsOrExternalUsers") {
                    $JSON.conditions.users.excludeUsers = @("GuestsOrExternalUsers")
                }
                else {
                    
                }
            }
            else {

            }
        }

        $JSON.conditions.Users.includeGroups = $InGrp
        $JSON.conditions.users.excludeGroups = $ExGrp

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