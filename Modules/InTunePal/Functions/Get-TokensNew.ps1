function GetMSALToken {

    param (
        [switch]$OtherTenant,
        $Tenant
    )

    #Region Paramaeters
    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $scope = "https://graph.microsoft.com/.default"    
    #EndRegion

    switch ($OtherTenant) {
        $true {
            $authority = "https://login.microsoftonline.com/$Tenant"
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -Authority $authority
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }
            return $authHeader
        }
        $false {
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -ForceRefresh
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }
            return $authHeader
        }
        default {
            $authResult = Get-MsalToken -ClientId $clientId -Scopes $scope -RedirectUri $redirectUri -ForceRefresh
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "Bearer " + $authResult.AccessToken
                'ExpiresOn'     = $authResult.ExpiresOn
            }
            return $authHeader
        }
    }
}

function Get-TokensNew {

    if ($global:tenantconfirmation -eq 'n') {
        $global:authToken = GetMSALToken
    }
                
    elseif ($global:tenantconfirmation -eq 'y') {
        $Tenantconfirm = Read-Host "Please provide the tenant Id or Tenant Suffix to be used!"

        $global:authToken = GetMSALToken -OtherTenant -Tenant $Tenantconfirm
    }
}