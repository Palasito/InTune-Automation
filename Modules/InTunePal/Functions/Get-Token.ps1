function GetMSALToken {

    param (
        [switch]$OtherTenant,
        $Tenant
    )

    #Region Paramaeters
    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $scope = "https://graph.microsoft.com/.default"
    $ConditionalAccessScope = @("https://graph.microsoft.com/Policy.ReadWrite.ConditionalAccess", "https://graph.microsoft.com/Policy.Read.All", "Application.Read.All")
    #EndRegion

    switch ($OtherTenant) {
        $true {
            $authority = "https://login.microsoftonline.com/$Tenant"
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -Authority $authority -ForceRefresh
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $ConditionalAccessScope -RedirectUri $redirectUri -Authority $authority -ForceRefresh -Silent
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }
            return $authHeader
        }
        $false {
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -ForceRefresh
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $ConditionalAccessScope -RedirectUri $redirectUri -ForceRefresh -Silent
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }
            return $authHeader
        }
        default {
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -ForceRefresh
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $ConditionalAccessScope -RedirectUri $redirectUri -ForceRefresh -Silent
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }
            return $authHeader
        }
    }
}

function Get-Token {

    $CurrentTime = Get-Date
    switch ($authHeader) {
        $null {
            if ($global:tenantconfirmation -eq 'n') {
                $global:authToken = GetMSALToken
                return $global:authToken
            }
                        
            elseif ($global:tenantconfirmation -eq 'y') {
                $Tenantconfirm = Read-Host "Please provide the tenant Id or Tenant Suffix to be used!"
        
                $global:authToken = GetMSALToken -OtherTenant -Tenant $Tenantconfirm
                return $global:authToken
            }
        }
        { $authResult.ExpiresOn.LocalDateTime -lt $CurrentTime } {
            $global:authToken = GetMSALToken
            return $global:authToken
        }
    }
    # if ($global:tenantconfirmation -eq 'n') {
    #     $global:authToken = GetMSALToken
    # }
                
    # elseif ($global:tenantconfirmation -eq 'y') {
    #     $Tenantconfirm = Read-Host "Please provide the tenant Id or Tenant Suffix to be used!"

    #     $global:authToken = GetMSALToken -OtherTenant -Tenant $Tenantconfirm
    # }
}