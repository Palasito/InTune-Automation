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

Function Test-JSON() {

    param (

        $JSON

    )

    try {

        ConvertFrom-Json $JSON -ErrorAction Stop
        $validJson = $true

    }

    catch {

        $validJson = $false
        $_.Exception

    }

    if (!$validJson) {
    
        Write-Host "Provided JSON isn't in valid JSON format" -f Red
        break

    }

}

####################################################

Function Add-DeviceCompliancePolicy() {

    [cmdletbinding()]

    param
    (
        $JSON
    )

    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceCompliancePolicies"
    
    try {

        if ($JSON -eq "" -or $null -eq $JSON) {

            write-host "No JSON specified, please specify valid JSON for the Device Compliance Policies..." -f Red

        }

        else {

            Test-JSON -JSON $JSON

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json" 

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

####################################################

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

    Write-Host "Importing Device Compliance Policies..." -ForegroundColor Cyan
    Write-Host

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
            Write-Host
            Write-Host "Policy '$DisplayName' already exists and will not be imported!" -ForegroundColor Yellow
        }

    }
}