function Import-AppProtectionPolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    #region AuthenticationW

    write-host
    
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
    
    if (!(Test-Path "$ImportPath")) {
    
        Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break
    
    }
    
    ####################################################
    
    $JSON_Data = Get-ChildItem "$ImportPath\AppProtectionPolicies" -Recurse -Include *.json

    write-host "Importing App Protection Policies..." -ForegroundColor Cyan
    Write-Host

    foreach ($json in $JSON_Data) {

        $Json_file = Get-Content $json

        $JSON_Convert = $Json_file | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, apps

        $DisplayName = $JSON_Convert.displayName

        $uri = "https://graph.microsoft.com/Beta/deviceAppManagement/managedAppPolicies"
        $check = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$DisplayName") }

        if ($null -eq $check) {

            $JSON_Convert | Add-Member -MemberType NoteProperty -Name 'appGroupType' -Value "allApps" -Force

            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100
     
            $null = Add-ManagedAppPolicy -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Intune App Protection"
                "Name"   = $DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "App Managed Policy $($DisplayName) already exists and will not be imported!" -ForegroundColor Red
        }
    }
}