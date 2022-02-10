function Add-CAPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','

    foreach($Pol in $CAPGroups){
        $Policy = Get-AzureADMSConditionalAccessPolicy | Where-Object displayName -eq $pol.DisplayName
        [Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet]$Conditions = $Policy.Conditions
        $InclGrps = $pol.IncludeGroups -split ";"
        $ExclGrps = $pol.ExcludeGroups -split ";"

        foreach ($grp in $InclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = Get-AzureADMSGroup -SearchString $grp
                $Conditions.Users.IncludeGroups += $g.Id
            }
            elseif ([string]::IsNullOrEmpty($grp)) {

            }
            else {
                Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
            }
        }

        foreach ($grp in $ExclGrps) {
            if (-not([string]::IsNullOrEmpty($grp))) {
                $g = Get-AzureADMSGroup -SearchString "$($grp)"
                $Conditions.Users.ExcludeGroups += $g.Id
            }
            elseif ([string]::IsNullOrEmpty($grp)) {

            }
            else {
                Write-Host "Group $grp does not exist, please check the CSV mapping" -ForegroundColor Yellow
            }
        }
        #     foreach ($grp in $InclGrps){
        #         $inclgrpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp"
        #         $PolicyConditions.IncludeGroups += $inclgrpid.id
        #     }

        #     foreach($grp in $ExclGrps){
        #         $exclgrpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp" 
        #         $PolicyConditions.ExcludeGroups += $exclgrpid.Id
        #     }

        # $Conditions.Users = $PolicyConditions

        Set-AzureADMSConditionalAccessPolicy -PolicyId $Policy.Id -Conditions $Conditions
    }

}