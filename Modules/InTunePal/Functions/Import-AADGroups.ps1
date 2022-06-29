Function Import-AADGroups() {

    param(
        [parameter()]
        [String]$Path,
        $AzureADToken
    )

    # Authentication Region
    $null = Get-Token
    # endregion
    
    ############################################

    Write-Host
    Write-Host "Creating specified security groups" -ForegroundColor Cyan

    $Groups = Import-Csv -Path $Path\CSVs\AADGroups\*.csv
    $check = Get-Groups
    
    foreach ($Group in $Groups) {

        $checkresult = $check | Where-Object { $_.displayName -eq $Group }

        if ($null -eq $checkresult) {

            $null = New-AzureADMSGroup -DisplayName $Group.DisplayName -Description $Group.Description -MailEnabled $False -MailNickName "group" -SecurityEnabled $True

            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Groups"
                "Name"   = $Group.DisplayName
                "Path"   = "$Path\CSVs\AADGroups"
            }
        }

        else {
            Write-Host "Group already exists, will skip creation of" $Group.DisplayName -ForegroundColor Yellow
        }
    }
}