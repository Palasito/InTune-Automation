function Get-AuthToken {

    [cmdletbinding()]
        
        param
        (
            [Parameter(Mandatory=$true)]
            $User
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
            
                if($authResult.AccessToken){
            
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

# Function Remove-SecurityDefaults(){

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

    try {
        $uri = "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy"

        $Settings = (Invoke-RestMethod -Method GET -Uri $uri -Headers $authToken).value

        $Settings | ConvertFrom-Json

        if ($Settings.isEnabled = "true"){
            $body = (@{"isEnabled"="false"} | ConvertTo-Json)
            
            $null = Invoke-RestMethod -Method Patch -Headers $authToken -Uri $uri -Body $body
        }
        else{
            Write-Host "Security defaults are already disabled, will not make any changes..." -ForegroundColor Cyan
        }
    }
    catch {
        write-host $_.Exception.Message -f Red
        write-host $_.Exception.ItemName -f Red
        write-host
        break
    }
# }