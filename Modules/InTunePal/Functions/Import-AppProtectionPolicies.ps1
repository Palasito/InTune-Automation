function Import-AppProtectionPolicies() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion
    
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

    write-host
    write-host "Importing App Protection Policies..." -ForegroundColor Cyan

    $uri = "https://graph.microsoft.com/Beta/deviceAppManagement/managedAppPolicies"
    $AllAppProtPolicies = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value

    foreach ($json in $JSON_Data) {

        $Json_file = Get-Content $json

        $JSON_Convert = $Json_file | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, apps

        $DisplayName = $JSON_Convert.displayName

        $check = $AllAppProtPolicies | Where-Object { ($_.'displayName').contains("$DisplayName") }

        if ($null -eq $check) {

            $JSON_Convert | Add-Member -MemberType NoteProperty -Name 'appGroupType' -Value "allApps" -Force

            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100
     
            $null = Add-ManagedAppPolicy -JSON $JSON_Output
    
            Write-Host "Imported App Protection Policy $($DisplayName)"
        }
        else {
            Write-Host "App Managed Policy $($DisplayName) already exists and will not be imported!" -ForegroundColor Red
        }
    }
}