Function Import-AADGroups() {

    param(
        [parameter()]
        [String]$Path
    )

    Write-Host
    Write-Host "Creating specified security groups" -ForegroundColor Cyan

    $Groups = Import-Csv -Path $Path\CSVs\AADGroups\*.csv

    foreach ($Group in $Groups) {

        $check = Get-AzureADMSGroup -SearchString $Group.DisplayName

        if ($null -eq $check) {

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