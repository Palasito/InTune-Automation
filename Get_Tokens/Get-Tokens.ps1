function Get-AuthToken {

    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory = $true)]
        $User,
        $Tenant
    )

    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
        
    $tenant = $userUpn.Host
        
    $AadModule = Get-Module -Name "AzureAD" -ListAvailable
        
    if ($AadModule.version -lt "2.0.2.140") {
        
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
        
        if ($authResult.AccessToken) {
        
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

function Get-Tokens {

    $DateTime = (Get-Date).ToUniversalTime()

    $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes
    
    if ($TokenExpires -le 0) {
    
        write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
        write-host
    
        if ($null -eq $User -or $User -eq "") {
    
            if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens) {
                $confirmation = Read-Host "Do you want to connect to another tenant? [y/n]"
                if ($confirmation -eq 'n') {
                    Connect-AzureAD

                    $tokennew = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
                    $global:User = $tokennew.AccessToken.UserId
                    $global:authToken = Get-AuthToken -User $User -Tenant $userUpn.Host
            
                    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
                    $global:tenantforbreak = $userUpn.Host
                }
                
                elseif ($confirmation -eq 'y') {
                    $Tenantconfirm = Read-Host "Please provide the tenant Id to be used!"
                    $TenantSuff = Read-Host "Please provide the tenant suffix"
                    Connect-AzureAD -TenantId $Tenantconfirm

                    $tokennew = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
                    $global:User = $tokennew.AccessToken.UserId

                    $global:authToken = Get-AuthToken -User $User -Tenant $TenantSuff
            
                    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
                    $global:tenantforbreak = $TenantSuff
                }
            
        } 

            else {
                $token = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
                Write-host "Connected to tenant: $($token.AccessToken.TenantId) with user: $($token.AccessToken.UserId)"
            }        

        }

    }

    else {

        if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens) {
            $null = Connect-AzureAD
        }

        else {
            $token = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
            # Write-host "Connected to tenant: $($token.AccessToken.TenantId) with user: $($token.AccessToken.UserId)"
        }

        $tokennew = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
        $global:User = $tokennew.AccessToken.UserId
        $global:authToken = Get-AuthToken -User $User

        $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
        $global:tenantforbreak = $userUpn.Host

    }

}