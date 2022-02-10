function Add-CAPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','

    Write-host
    Write-Host "Assigning Groups to Conditional Access Policies" -ForegroundColor Cyan
    foreach($Pol in $CAPGroups){
        $Policy = Get-AzureADMSConditionalAccessPolicy | Where-Object displayName -eq $pol.DisplayName
        [Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet]$Conditions = $Policy.Conditions
        $InclGrps = $pol.IncludeGroups -split ";"
        $ExclGrps = $pol.ExcludeGroups -split ";"

        foreach ($grp in $InclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = Get-AzureADMSGroup -SearchString $grp
                if ($null -ne $g){
                    $Conditions.Users.IncludeGroups += $g.Id
                }
                else {

                }
            }
            else {

            }
        }

        foreach ($grp in $ExclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = Get-AzureADMSGroup -SearchString "$($grp)"
                if ($null -ne $g){
                    $Conditions.Users.ExcludeGroups += $g.Id
                }
                else {
                    
                }
            }
            else {

            }
        }
        $null = Set-AzureADMSConditionalAccessPolicy -PolicyId $Policy.Id -Conditions $Conditions

        [PSCustomObject]@{
            "Action" = "Assign"
            "Type"   = "Conditional Access Policy"
            "Name"            = $Policy.displayName
            "Included Groups" = $InclGrps
            "Excluded Groups" = $ExclGrps
        }
    }

}