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

    Write-Host "Assigning Groups to Conditional Access Policies" -ForegroundColor Cyan
    $gr = Get-AADGroups

    $AllExisting = Get-ConditionalAccessPolicies
    foreach ($Pol in $CAPGroups) {
        $Policy = $AllExisting | Where-Object displayName -eq $pol.DisplayName

        if ([string]::IsNullOrEmpty($Policy)) {
            Write-Warning "Policy $($pol.displayName) could not be found in the tenant"
        }

        else {

            $JSON = @{
                conditions = @{
                    users = @{}
                }
            }

            $InclGrps = $pol.IncludeGroups -split ";"
            $ExclGrps = $pol.ExcludeGroups -split ";"
    
            $InGrp = @()
            $ExGrp = @()
    
            if ([string]::IsNullOrEmpty($InclGrps)) {
                $JSON.conditions.users.includeUsers = @("none")
            }
    
            else {
                foreach ($grp in $InclGrps) {
                    $g = $gr | Where-Object { $_.DisplayName -eq $grp }
                    switch ($g) {
                        [string]::IsNullOrEmpty {
                            break
                        }
                        "GuestsOrExternalUsers" {
                            $JSON.conditions.users.includeUsers = @("GuestsOrExternalUsers")
                            break
                        }
                        "All Users" {
                            $JSON.conditions.users.includeUsers = @("All Users")
                            break
                        }
                        default {
                            $JSON.conditions.users.includeUsers = @("none")
                            $InGrp += $g.id
                        }
                    }
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

            $j = $JSON | ConvertTo-Json -Depth 100

            if ([string]::IsNullOrEmpty($JSON.conditions.Users.includeUsers)) {
                Write-Host "No groups have been found that can be assigned to policy $($pol.displayName)"
            }

            else {

                try {
                    $uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$($Policy.id)"
                    $null = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Patch -Body $j -ContentType "application/json"
    
                    Write-Host "Assignments completed successfully on policy $($pol.displayName)"
                }
    
                catch {

                    $ex = $_.Exception
                    Write-Host "Issue when assigning groups and users on policy $($pol.displayName)"
                    Write-Host "Error for policy $($pol.displayName) is: $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)" -ForegroundColor Red
                    
                }
            }
        }    
    }
}