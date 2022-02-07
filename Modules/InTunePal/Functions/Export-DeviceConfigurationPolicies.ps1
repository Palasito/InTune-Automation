function Get-AuthToken {
    [cmdletbinding()]

    param
    (
        [Parameter(Mandatory = $true)]
        $User
    )

    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User

    $tenant = $userUpn.Host

    Write-Host "Checking for AzureAD module..."

    $AadModule = Get-Module -Name "AzureAD" -ListAvailable

    if ($null -eq $AadModule) {

        Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable

    }

    if ($null -eq $AadModule) {
        write-host
        write-host "AzureAD Powershell module not installed..." -f Red
        write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
        write-host "Script can't continue..." -f Red
        write-host
        exit
    }

    # Getting path to ActiveDirectory Assemblies
    # If the module count is greater than 1 find the latest version

    if ($AadModule.count -gt 1) {

        $Latest_Version = ($AadModule | Select-Object version | Sort-Object)[-1]

        $aadModule = $AadModule | Where-Object { $_.version -eq $Latest_Version.version }

        # Checking if there are multiple versions of the same module found

        if ($AadModule.count -gt 1) {

            $aadModule = $AadModule | Select-Object -Unique

        }

        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    }

    else {

        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    }

    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"

    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

    $resourceAppIdURI = "https://graph.microsoft.com"

    $authority = "https://login.microsoftonline.com/$Tenant"

    try {

        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

        # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
        # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession

        $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"

        $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")

        $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters, $userId).Result

        # If the accesstoken is valid then create the authentication header

        if ($authResult.AccessToken) {

            # Creating header for Authorization token

            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }

            return $authHeader

        }

        else {

            Write-Host
            Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
            Write-Host
            break

        }

    }

    catch {

        write-host $_.Exception.Message -f Red
        write-host $_.Exception.ItemName -f Red
        write-host
        break

    }

}

####################################################

Function Get-GeneralDeviceConfigurationPolicy() {

    [cmdletbinding()]

    $graphApiVersion = "Beta"
    $GDC_resource = "deviceManagement/deviceConfigurations"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($GDC_resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
    }
    
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

####################################################

Function Get-GeneralDeviceConfigurationPolicyJSON() {

    param(
        $Policies,
        $ExportPath
    )
    
    try {

        if (($Policies.'@odata.type' -eq '#microsoft.graph.windows10CustomConfiguration') -and ($Policies.omaSettings | Where-Object { $_.isEncrypted -contains $true } )) {
            
            $Policyid = $Policies.id
            $uri_value = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($Policyid)/getOmaSettingPlainTextValue(secretReferenceValueId='$($Policies.omaSettings.secretReferenceValueId)')"
            $value = (Invoke-RestMethod -Uri $uri_value -Headers $authToken -Method Get).Value
            $omaSettings = @()
            foreach ($oma in $Policies.omaSettings) {
                $newSetting = @{}
                $newSetting.'@odata.type' = $oma.'@odata.type'
                $newSetting.displayName = $oma.displayName
                $newSetting.description = $oma.description
                $newSetting.omaUri = $oma.omaUri
                $newSetting.value = $value
                $newSetting.isEncrypted = $false
                $newSetting.secretReferenceValueId = $null

                $omaSettings += $newSetting
            }

            $PolicyJSON = $Policies
            $PolicyJSON.omaSettings = @()
            $PolicyJSON.omaSettings = $omaSettings

            $FinalJSONdisplayName = $Policies.DisplayName

            $FinalJSONDisplayName = $FinalJSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

            $FileName_FinalJSON = "GDC" + "_" + "$FinalJSONDisplayName" + ".json"

            $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 100

            $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_FinalJSON"

            
        }

        else {

            $DisplayName = $Policies.DisplayName

            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

            $FileName_JSON = "GDC" + "_" + "$DisplayName" + ".json"

            $FinalJSON = $Policies | ConvertTo-Json -Depth 100

            $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_JSON"
            
        }


    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    }

}

Function Get-DeviceSettingsCatalogPolicy() {
    <#Explanation of function to be added#>

    [cmdletbinding()]

    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/configurationPolicies"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)"
    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value

    }
    

    
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

Function Get-DeviceAdministrativeTemplates() {
    <#Explanation of function to be added#>
    
    [cmdletbinding()]
    
    $graphApiVersion = "Beta"
    $DAT_Resource = "deviceManagement/groupPolicyConfigurations"
        
    try {
        
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DAT_Resource)"
        (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
        
    }
        
    catch {
    
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    
    }
    
}

Function Get-DeviceAdministrativeTemplatesJSON() {
    param(
        $Policies,
        $ExportPath
    )

    try {

        $DisplayName = $Policies.DisplayName

        # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
        $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $FileName_JSON = "AT" + "_" + "$DisplayName" + ".json"

        $FinalJSON = $Policies | ConvertTo-Json -Depth 5

        $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_JSON"

    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
    }
}

Function Get-DeviceSettingsCatalogPolicyJSON() {

    param(
        $Policies,
        $ExportPath
    )

    $graphApiVersion = "Beta"
    $DSC_Resource = "deviceManagement/configurationPolicies"

    try {

        $Policyid = $Policies.id
        #$PolicyJSON = $Policy | ConvertTo-Json -depth 5
        $uri_settings = "https://graph.microsoft.com/$graphApiVersion/$($DSC_Resource)/$($Policyid)/settings"
        $Settings = (Invoke-RestMethod -Uri $uri_settings -Headers $authToken -Method Get).Value

        $PolicyJSON = [pscustomobject]@{
            name         = $Policies.Name
            description  = $Policies.description
            platforms    = $Policies.platforms
            technologies = $Policies.technologies
            settings     = $Settings
        }

        $FinalJSONdisplayName = $Policies.name

        $FinalJSONDisplayName = $FinalJSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $FileName_FinalJSON = "SC" + "_" + "$FinalJSONDisplayName" + ".json"

        $FinalJSON = $PolicyJSON | ConvertTo-Json -Depth 20

        $FinalJSON | Set-Content -LiteralPath "$ExportPath\DeviceConfigurationPolicies\$FileName_FinalJSON"
            
    }

    catch {
    
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break
            
    }
        
}

####################################################

function Export-DeviceConfigurationPolicies() {

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

    $ExportPath = $Path

    # If the directory path doesn't exist prompt user to create the directory
    $ExportPath = $ExportPath.replace('"', '')
    
    if (!(Test-Path "$ExportPath")) {

        Write-Host
        Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow
    
        $Confirm = read-host
    
        if ($Confirm -eq "y" -or $Confirm -eq "Y") {
    
            new-item -ItemType Directory -Path "$ExportPath" | Out-Null
            Write-Host
    
        }

        else {

            Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
            Write-Host
            break

        }

    }

    ####################################################

    if (-not (Test-Path "$ExportPath\DeviceConfigurationPolicies")) {
        $null = New-Item -Path "$ExportPath\DeviceConfigurationPolicies" -ItemType Directory
    }

    # Filtering out iOS and Windows Software Update Policies
    $GDCs = Get-GeneralDeviceConfigurationPolicy | Where-Object { ($_.'@odata.type' -ne "#microsoft.graph.iosUpdateConfiguration") -and ($_.'@odata.type' -ne "#microsoft.graph.windowsUpdateForBusinessConfiguration") }
    Write-Host
    write-host "Exporting Device Configuration Policies..." -ForegroundColor cyan
    foreach ($GDC in $GDCs) {
        Get-GeneralDeviceConfigurationPolicyJSON -Policies $GDC -ExportPath "$ExportPath"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "General Device Configuration Policy"  
            "Name"   = $GDC.DisplayName
            "Path"   = $ExportPath
        }

    }

    Write-Host

    $DSCs = Get-DeviceSettingsCatalogPolicy
    write-host "Exporting Device Settings Catalog Policies..." -ForegroundColor cyan
    foreach ($DSC in $DSCs) {
        Get-DeviceSettingsCatalogPolicyJSON -Policies $DSC -ExportPath "$ExportPath"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Settings Catalog Policy"
            "Name"   = $DSC.name
            "Path"   = $ExportPath
        }
    }

    Write-Host

    $DATs = Get-DeviceAdministrativeTemplates
    write-host "Exporting Device Administrative Template Policies..." -ForegroundColor cyan
    foreach ($DAT in $DATs) {
        Get-DeviceAdministrativeTemplatesJSON -Policies $DAT -ExportPath "$ExportPath"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Administrative Template"
            "Name"   = $DAT.DisplayName
            "Path"   = $ExportPath
        }
    }

    Write-Host
}