Function Import-CompliancePolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    # Checking if authToken exists before running authentication
    if ($global:authToken) {

        # Setting DateTime to Universal time to work in all timezones
        $DateTime = (Get-Date).ToUniversalTime()

        # If the authToken exists checking when it expires
        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

        if ($TokenExpires -le 0) {

            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host

            # Defining User Principal Name if not present

            if ($null -eq $User -or $User -eq "") {

                $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host

            }

            $global:authToken = Get-AuthToken -User $User

        }
    }

    # Authentication doesn't exist, calling Get-AuthToken function

    else {

        if ($null -eq $User -or $User -eq "") {

            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host

        }

        # Getting the authorization token
        $global:authToken = Get-AuthToken -User $User

    }

    #endregion

    ####################################################

    $ImportPath = $Path

    # Replacing quotes for Test-Path
    $ImportPath = $ImportPath.replace('"', '')

    if (!(Test-Path "$ImportPath\DeviceCompliancePolicies")) {

        Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    Write-Host
    Write-Host "Importing Device Compliance Policies..." -ForegroundColor Cyan

    $AvailableJsons = Get-ChildItem "$ImportPath\DeviceCompliancePolicies" -Recurse -Include *.json

    foreach ($json in $AvailableJsons) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version

        $DisplayName = $JSON_Convert.displayName
        
        $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 5

        $scheduledActionsForRule = '"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":0,"notificationTemplateId":"","notificationMessageCCList":[]}]}]'

        $JSON_Output = $JSON_Output.trimend("}")

        $JSON_Output = $JSON_Output.TrimEnd() + "," + "`r`n"

        $JSON_Output = $JSON_Output + $scheduledActionsForRule + "`r`n" + "}"

        $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceCompliancePolicies"
        $check = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayname').equals($DisplayName) }
        if ($null -eq $check) {

            $null = Add-DeviceCompliancePolicy -JSON $JSON_Output

            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Device Compliance Policy"
                "Name"   = $DisplayName
                "Path"   = "$($ImportPath)\DeviceCompliancePolicies"
            }
        }    
        else {
            Write-Host "Policy '$DisplayName' already exists and will not be imported!" -ForegroundColor Red
        }

    }
}