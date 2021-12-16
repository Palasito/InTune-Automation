function Add-CAPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $Conditions = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet

    $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','

    foreach($Pol in $CAPGroups){
        $Policy = Get-AzureADMSConditionalAccessPolicy | Where-Object displayName -eq $pol.DisplayName
        $InclGrps = $pol.IncludeGroups -split ";"
        $ExclGrps = $pol.ExcludeGroups -split ";"
        $PolicyConditions = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition

            foreach ($grp in $InclGrps){
                $inclgrpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp"
                $PolicyConditions.IncludeGroups += $inclgrpid.id
            }

            foreach($grp in $ExclGrps){
                $exclgrpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp" 
                $PolicyConditions.ExcludeGroups += $exclgrpid.Id
            }

        $Conditions.Users = $PolicyConditions

        Set-AzureADMSConditionalAccessPolicy -PolicyId $Policy.Id -Conditions $Conditions
    }

}