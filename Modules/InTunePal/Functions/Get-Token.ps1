function GetMSALToken {

    param (
        [switch]$OtherTenant,
        $Tenant
    )

    #Region Paramaeters
    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
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

    switch ($global:authToken) {
        $null {
            if ($global:tenantconfirmation -eq 'n') {
                Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
                $global:authToken = GetMSALToken
                return $global:authToken
            }
                        
            elseif ($global:tenantconfirmation -eq 'y') {

                $Tenantconfirm = Read-Host "Please provide the tenant Id or Tenant Suffix to be used!"
                Write-host "Please wait for the Authentication popup to appear" -ForegroundColor Cyan
                $global:authToken = GetMSALToken -OtherTenant -Tenant $Tenantconfirm
                return $global:authToken
            }
        }
        { $global:authToken.ExpiresOn.UtcDateTime -lt $CurrentTime } {
            $global:authToken = GetMSALToken
            return $global:authToken
        }
        default {
            
        }
    }
}