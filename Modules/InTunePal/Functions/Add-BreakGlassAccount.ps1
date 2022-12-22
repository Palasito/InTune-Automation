Function Add-BreakGlassAccount() {

    param(
        $global:tenantforbreak
    )

    Write-Host
    Write-Host "Will be creating User Accounts" -ForegroundColor Cyan
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = "P@55w.rd"
    $UserPrincipalName = 'breakuser@' + $tenantforbreak

    $checkbreak = Get-AzureADUser -SearchString "breakuser"
    $checktest = Get-AzureADUser -SearchString "testuser"
    $checkOL = Get-AzureADUser -SearchString "officeline"
    
    if ($null -eq $checkbreak) {
        Write-Host "Will be creating the following user:" -ForegroundColor Cyan
        write-host "Break-Glass account with username: $UserPrincipalName and password: "$PasswordProfile.Password -ForegroundColor Cyan
        Start-Sleep -Seconds 5
        
        $Parameters = @{
            AccountEnabled    = $true
            DisplayName       = "Break-Glass Admin"
            PasswordProfile   = $PasswordProfile
            UserPrincipalName = $UserPrincipalName
            MailNickName      = "breakuser"
        }
        $null = New-AzureADUser @Parameters
    
        [PSCustomObject]@{
            "Action" = "Creation"
            "Type"   = "Account"
            "Name"   = $UserPrincipalName
            "Path"   = ""
        }
    
        $userassignment = Get-AzureADUser -SearchString "breakuser"
    
        $roleDefinition = Get-AzureADMSRoleDefinition -Filter "startswith(displayname, 'Global Administrator')"
    
        $null = New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $userassignment.objectId
    }
    else {
        Write-Host "User $UserPrincipalName already exists and will not be created!" -ForegroundColor Yellow
    }
    if ($null -eq $checktest) {
        Write-Host "Will be creating the following user:" -ForegroundColor Cyan
        write-host "TestUser account with username: testuser@$($tenantforbreak) and password: "$PasswordProfile.Password -ForegroundColor Cyan
        Start-Sleep -Seconds 5
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = "P@55w.rd"
        $UserPrincipalName = 'testuser@' + $tenantforbreak
        
    
        $Parameters = @{
            AccountEnabled    = $true
            DisplayName       = "testuser"
            PasswordProfile   = $PasswordProfile
            UserPrincipalName = $UserPrincipalName
            MailNickName      = "testuser"
        }
    
        [PSCustomObject]@{
            "Action" = "Creation"
            "Type"   = "Account"
            "Name"   = $UserPrincipalName
            "Path"   = ""
        }
    
        $null = New-AzureADUser @Parameters
    
    }
    else {
        Write-Host "User testuser@$($tenantforbreak) already exists and will not be created!" -ForegroundColor Yellow
    }
    if ($null -eq $checkOL) {
        Write-Host "Will be creating the following user:" -ForegroundColor Cyan
        write-host "OfficeLine account with username: Officeline@$($tenantforbreak) and password: "$PasswordProfile.Password -ForegroundColor Cyan
        Start-Sleep -Seconds 5
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = "P@55w.rd"
        $UserPrincipalName = 'officeline@' + $tenantforbreak
        
        $Parameters = @{
            AccountEnabled    = $true
            DisplayName       = "officeline"
            PasswordProfile   = $PasswordProfile
            UserPrincipalName = $UserPrincipalName
            MailNickName      = "officeline"
        }
    
        [PSCustomObject]@{
            "Action" = "Creation"
            "Type"   = "Account"
            "Name"   = $UserPrincipalName
        }
    
        $null = New-AzureADUser @Parameters
    
        $userassignment = Get-AzureADUser -SearchString "officeline"
        $null = New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $userassignment.objectId
    
    }
    else {
        Write-Host "User Officeline@$($tenantforbreak) already exists and will not be created!" -ForegroundColor Yellow
    }   
}