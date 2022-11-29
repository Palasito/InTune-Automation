Function Import-CompliancePolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    # Authentication region
    if ($global:authToken) {
        #Do nothing
    }
    else {
        $null = Get-Token
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

    $uri = "https://graph.microsoft.com/Beta/deviceManagement/deviceCompliancePolicies"
    $AllExistingComp = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value 

    foreach ($json in $AvailableJsons) {

        $JSON_Data = Get-Content $json.FullName

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version

        $DisplayName = $JSON_Convert.displayName

        $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 5

        $scheduledActionsForRule = '"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":0,"notificationTemplateId":"","notificationMessageCCList":[]}]}]'

        $JSON_Output = $JSON_Output.trimend("}")

        $JSON_Output = $JSON_Output.TrimEnd() + "," + "`r`n"

        $JSON_Output = $JSON_Output + $scheduledActionsForRule + "`r`n" + "}"

        $check = $AllExistingComp | Where-Object { ($_.'displayname').equals($DisplayName) }
        if ($null -eq $check) {

            $null = Add-DeviceCompliancePolicy -JSON $JSON_Output

            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Device Compliance Policy"
                "Name"   = $DisplayName
            }
        }    
        else {
            Write-Host "Policy '$DisplayName' already exists and will not be imported!" -ForegroundColor Red
        }

    }
}