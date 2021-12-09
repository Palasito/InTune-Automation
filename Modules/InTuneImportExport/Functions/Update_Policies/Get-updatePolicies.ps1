
<#

.COPYRIGHT
Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
See LICENSE in the project root for license information.

#>

####################################################

function Get-AuthToken {

    <#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface with the tenant name
    .EXAMPLE
    Get-AuthToken
    Authenticates you with the Graph API interface
    .NOTES
    NAME: Get-AuthToken
    #>
    
    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory=$true)]
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
    
        if($AadModule.count -gt 1){
    
            $Latest_Version = ($AadModule | Select-Object version | Sort-Object)[-1]
    
            $aadModule = $AadModule | Where-Object { $_.version -eq $Latest_Version.version }
    
                # Checking if there are multiple versions of the same module found
    
                if($AadModule.count -gt 1){
    
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
    
        $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$redirectUri,$platformParameters,$userId).Result
    
            # If the accesstoken is valid then create the authentication header
    
            if($authResult.AccessToken){
    
            # Creating header for Authorization token
    
            $authHeader = @{
                'Content-Type'='application/json'
                'Authorization'="Bearer " + $authResult.AccessToken
                'ExpiresOn'=$authResult.ExpiresOn
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
    
    Function Get-SoftwareUpdatePolicy(){
    
    <#
    .SYNOPSIS
    This function is used to get Software Update policies from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any Software Update policies
    .EXAMPLE
    Get-SoftwareUpdatePolicy -Windows10
    Returns Windows 10 Software Update policies configured in Intune
    .EXAMPLE
    Get-SoftwareUpdatePolicy -iOS
    Returns iOS update policies configured in Intune
    .NOTES
    NAME: Get-SoftwareUpdatePolicy
    #>
    
    [cmdletbinding()]
    
    param
    (
        [switch]$Windows10,
        [switch]$iOS
    )
    
    $graphApiVersion = "Beta"
    
        try {
    
            $Count_Params = 0
    
            if($iOS.IsPresent){ $Count_Params++ }
            if($Windows10.IsPresent){ $Count_Params++ }
    
            if($Count_Params -gt 1){
    
            write-host "Multiple parameters set, specify a single parameter -iOS or -Windows10 against the function" -f Red
    
            }
    
            elseif($Count_Params -eq 0){
    
            Write-Host "Parameter -iOS or -Windows10 required against the function..." -ForegroundColor Red
            Write-Host
            break
    
            }
    
            elseif($Windows10){
    
            $Resource = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.windowsUpdateForBusinessConfiguration')&`$expand=groupAssignments"
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
    
            }
    
            elseif($iOS){
    
            $Resource = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosUpdateConfiguration')&`$expand=groupAssignments"
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
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
    
    Function Get-AADGroup(){
    
    <#
    .SYNOPSIS
    This function is used to get AAD Groups from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any Groups registered with AAD
    .EXAMPLE
    Get-AADGroup
    Returns all users registered with Azure AD
    .NOTES
    NAME: Get-AADGroup
    #>
    
    [cmdletbinding()]
    
    param
    (
        $GroupName,
        $id,
        [switch]$Members
    )
    
    # Defining Variables
    $graphApiVersion = "v1.0"
    $Group_resource = "groups"
    
        try {
    
            if($id){
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Group_resource)?`$filter=id eq '$id'"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
            }
    
            elseif($GroupName -eq "" -or $null -eq $GroupName){
    
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Group_resource)"
            (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
            }
    
            else {
    
                if(!$Members){
    
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Group_resource)?`$filter=displayname eq '$GroupName'"
                (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
                }
    
                elseif($Members){
    
                $uri = "https://graph.microsoft.com/$graphApiVersion/$($Group_resource)?`$filter=displayname eq '$GroupName'"
                $Group = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
                    if($Group){
    
                    $GID = $Group.id
    
                    $Group.displayName
                    write-host
    
                    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Group_resource)/$GID/Members"
                    (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value
    
                    }
    
                }
    
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
    
function Get-UpdatePolicies(){
    
    # Checking if authToken exists before running authentication
    if($global:authToken){
    
        # Setting DateTime to Universal time to work in all timezones
        $DateTime = (Get-Date).ToUniversalTime()
    
        # If the authToken exists checking when it expires
        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes
    
            if($TokenExpires -le 0){
    
            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host
    
                # Defining User Principal Name if not present
    
                if($null -eq $User -or $User -eq ""){
    
                $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host
    
                }
    
            $global:authToken = Get-AuthToken -User $User
    
            }
    }
    
    # Authentication doesn't exist, calling Get-AuthToken function
    
    else {
    
        if($null -eq $User -or $User -eq ""){
    
        $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
        Write-Host
    
        }
    
    # Getting the authorization token
    $global:authToken = Get-AuthToken -User $User
    
    }
    
    #endregion
    
    ####################################################
    
    $WSUPs = Get-SoftwareUpdatePolicy -Windows10
    
    Write-Host "Software updates - Windows 10 Update Rings" -ForegroundColor Cyan
    Write-Host
    
        if($WSUPs){
    
            foreach($WSUP in $WSUPs){
    
            write-host "Software Update Policy:"$WSUP.displayName -f Yellow
            $WSUP
    
    
            $TargetGroupIds = $WSUP.groupAssignments.targetGroupId
    
            write-host "Getting SoftwareUpdate Policy assignment..." -f Cyan
    
                if($TargetGroupIds){
    
                    foreach($group in $TargetGroupIds){
    
                    (Get-AADGroup -id $group).displayName
    
                    }
    
                }
    
                else {
    
                Write-Host "No Software Update Policy Assignments found..." -ForegroundColor Red
    
                }
    
            }
    
        }
    
        else {
    
        Write-Host
        Write-Host "No Windows 10 Update Rings defined..." -ForegroundColor Red
    
        }
    
    write-host
    
    ####################################################
    
    $ISUPs = Get-SoftwareUpdatePolicy -iOS
    
    Write-Host "Software updates - iOS Update Policies" -ForegroundColor Cyan
    Write-Host
    
        if($ISUPs){
    
            foreach($ISUP in $ISUPs){
    
            write-host "Software Update Policy:"$ISUP.displayName -f Yellow
            $ISUP
    
            $TargetGroupIds = $ISUP.groupAssignments.targetGroupId
    
            write-host "Getting SoftwareUpdate Policy assignment..." -f Cyan
    
                if($TargetGroupIds){
    
                    foreach($group in $TargetGroupIds){
    
                    (Get-AADGroup -id $group).displayName
    
                    }
    
                }
    
                else {
    
                Write-Host "No Software Update Policy Assignments found..." -ForegroundColor Red
    
                }
    
            }
    
        }
    
        else {
    
        Write-Host
        Write-Host "No iOS Software Update Rings defined..." -ForegroundColor Red
    
        }
    
    Write-Host

}