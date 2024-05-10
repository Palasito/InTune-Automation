function GetMSALToken {

    param (
        [switch]$OtherTenant,
        $Tenant
    )

    #Region Paramaeters
    $clientId = Read-Host -Prompt "Input clientId here"
    $redirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
    $scope = @("https://graph.microsoft.com/DeviceManagementApps.ReadWrite.All", "https://graph.microsoft.com/DeviceManagementConfiguration.ReadWrite.All", "https://graph.microsoft.com/DeviceManagementManagedDevices.PrivilegedOperations.All", "https://graph.microsoft.com/DeviceManagementManagedDevices.ReadWrite.All", "https://graph.microsoft.com/DeviceManagementRBAC.ReadWrite.All", "https://graph.microsoft.com/DeviceManagementServiceConfig.ReadWrite.All", "https://graph.microsoft.com/Directory.Read.All", "https://graph.microsoft.com/Group.Read.All", "https://graph.microsoft.com/Group.ReadWrite.All", "https://graph.microsoft.com/User.Read", "https://graph.microsoft.com/Policy.ReadWrite.ConditionalAccess", "https://graph.microsoft.com/Policy.Read.All", "https://graph.microsoft.com/Application.ReadWrite.All")
    # $scope = "https://graph.microsoft.com/.default"
    # $ConditionalAccessScope = @("https://graph.microsoft.com/Policy.ReadWrite.ConditionalAccess", "https://graph.microsoft.com/Policy.Read.All", "https://graph.microsoft.com/Application.Read.All")
    #EndRegion

    switch ($OtherTenant) {

        $true {
            $authority = "https://login.microsoftonline.com/$Tenant"
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -Authority $authority -ForceRefresh
            # $authResult = Get-MsalToken -ClientId $clientId -Scopes $ConditionalAccessScope -RedirectUri $redirectUri -Authority $authority -ForceRefresh
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
                'Username'      = $authResult.Account.Username
            }
            return $authHeader
        }

        $false {

            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -ForceRefresh
            # $authResult = Get-MsalToken -ClientId $clientId -Scopes $ConditionalAccessScope -RedirectUri $redirectUri -ForceRefresh
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
                'Username'      = $authResult.Account.Username
            }
            return $authHeader
        }

        default {

            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -ForceRefresh
            # $authResult = Get-MsalToken -ClientId $clientId -Scopes $ConditionalAccessScope -RedirectUri $redirectUri -ForceRefresh
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
                'Username'      = $authResult.Account.Username
            }
            return $authHeader
        }
    }
}

function Get-Token {

    $CurrentTime = (Get-Date).ToUniversalTime()

    if ([string]::IsNullOrEmpty($clientId)) {
        $clientId = Read-Host "Input Client Id Here"
    }

    if ([string]::IsNullOrEmpty($secret)) {
        $secret = Read-Host "Input Secret"
    }
    
    if ([string]::IsNullOrEmpty($tenantId)) {
        $tenantId = Read-Host "Input tenant Id"
    }

    $body = @{
        'client_id' = $clientId
        'client_secret' = $secret
        'grant_type' = 'client_credentials'
        'resource' = 'https://graph.microsoft.com'
    }

    $url = "https://login.microsoftonline.com/$($tenantId)/oauth2/token"

    switch ($global:authToken) {
        $null {
            if ($global:tenantconfirmation -eq 'n') {
                Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
                $global:authToken = @{
                    'Content-Type'  = 'application/json'
                    'Authorization' = "Bearer " + (Invoke-RestMethod -Method Post -Body $body -Uri $url).access_token
                }
                return $global:authToken
            }
                        
            elseif ($global:tenantconfirmation -eq 'y') {

                $Tenantconfirm = Read-Host "Please provide the tenant Id or Tenant Suffix to be used!"
                Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
                # $global:authToken = GetMSALToken -OtherTenant -Tenant $Tenantconfirm
                $global:authToken = @{
                    'Content-Type'  = 'application/json'
                    'Authorization' = "Bearer " + (Invoke-RestMethod -Method Post -Body $body -Uri $url).access_token
                }
                return $global:authToken
            }
        }
        { $global:authToken.ExpiresOn.UtcDateTime -lt $CurrentTime } {
            # $global:authToken = GetMSALToken
            $global:authToken = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + (Invoke-RestMethod -Method Post -Body $body -Uri $url).access_token
            }
            return $global:authToken
        }
        default {
            
        }
    }
}