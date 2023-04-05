Function Import-AADGroups() {

    param(
        [parameter()]
        [String]$Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion

    Write-Host
    Write-Host "Creating specified security groups" -ForegroundColor Cyan

    $Groups = Import-Csv -Path $Path\CSVs\AADGroups\*.csv
    $check = Get-AADGroups
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

            Write-Host "Imported Group: $($Group.DisplayName)"
        }

        else {
            Write-Host "Group already exists, will skip creation of" $Group.DisplayName -ForegroundColor Yellow
        }
    }
}