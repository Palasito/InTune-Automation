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
        $InclGrps = $pol.IncludeGroups -split ";"
        $ExclGrps = $pol.ExcludeGroups -split ";"
        $PolicyConditions = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
        Write-Host "Importing policy" $policy.displayname

        Write-Host "Policy " $pol.DisplayName " with groups " $pol.IncludeGroups " and " $pol.ExcludeGroups
            foreach ($grp in $InclGrps){
                $inclgrpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp"
                Write-Host $inclgrpid.Id
                $PolicyConditions.IncludeGroups += $inclgrpid.id
            }

            foreach($grp in $ExclGrps){
                $exclgrpid = Get-AzureADMSGroup | Where-object displayname -eq "$grp" 
                Write-Host $exclgrpid.Id
                $PolicyConditions.ExcludeGroups += $exclgrpid.Id
            }

        $Conditions.Users = $PolicyConditions

        write-host $policy.id -ForegroundColor Yellow

        Set-AzureADMSConditionalAccessPolicy -PolicyId $Policy.Id -Conditions $Conditions
    }

}