Function Import-AADGroups() {

    param(
        [parameter()]
        [String]$Path
    )

    # Authentication Region
    if ($global:authToken) {
        #Do nothing
    }
    else {
        $null = Get-Token
    }
    # endregion
    
    ############################################

    Write-Host
    Write-Host "Creating specified security groups" -ForegroundColor Cyan

    $Groups = Import-Csv -Path $Path\CSVs\AADGroups\*.csv
    $check = Get-Groups
    $uri = "https://graph.microsoft.com/v1.0/groups"
    
    foreach ($Group in $Groups) {

        $checkresult = $check | Where-Object { $_.displayName -eq $Group.DisplayName }

        if ($null -eq $checkresult) {

            $NickName = $Group.DisplayName.Replace(" ", "")

            $body = @{}
            $body.description = $Group.Description
            $body.displayName = $Group.DisplayName
            $body.MailEnabled = $false
            $body.MailNickName = $NickName
            $body.securityEnabled = $True

            $bodyfinal = $body | ConvertTo-Json -Depth 5

            $null = Invoke-RestMethod -Uri $uri -Method Post -Headers $authToken -ContentType "application/json" -Body $bodyfinal

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