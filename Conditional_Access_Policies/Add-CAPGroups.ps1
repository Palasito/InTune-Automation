function Add-CAPGroups(){
    
    [cmdletbinding()]

    param(
        $Path
    )

    $Path = "c:\script_output\test\"

    $Conditions = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet

    $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','

    foreach($Pol in $CAPGroups){
        $Policy = Get-AzureADMSConditionalAccessPolicy | Where-Object displayName -eq $pol.DisplayName
        $InclGrps = $CAPGroups.IncludeGroups -split ";"
        $ExclGrps = $CAPGroups.ExcludeGroups -split ";"
        $PolicyConditions = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
        # $Importarray = New-Object System.Collections.Generic.List[System.Object]

            foreach ($grp in $InclGrps){
                $grpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp" | Select-Object Id
                $PolicyConditions.IncludeGroups = $grpid
                # $Importarray.Add("$grpid")
            }

            foreach($grp in $ExclGrps){
                $grpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp" | Select-Object Id
                $PolicyConditions.ExcludeGroups = $grpid
                # $Importarray.Add("$grpid")
            }
        
        $Conditions.Users = $PolicyConditions

        Set-AzureADMSConditionalAccessPolicy -PolicyId $Policy.Id -Conditions $Conditions
    }

}