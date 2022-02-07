Function Add-BreakGlassAccount() {

    param(
        $tenantforbreak
    )

    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = "P@55w.rd"
    $UserPrincipalName = 'breakuser@' + $tenantforbreak
    Write-Host
    Write-Host "Will be creating the following users:" -ForegroundColor Cyan
    write-host "Break-Glass account with username: $UserPrincipalName and password: "$PasswordProfile.Password -ForegroundColor Cyan
    write-host "Test User account with username: testuser@$($tenantforbreak) and password: "$PasswordProfile.Password -ForegroundColor Cyan
    write-host "Officeline account with username: Officeline@$($tenantforbreak) and password: "$PasswordProfile.Password -ForegroundColor Cyan
    Write-Host 
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

    $userassignment = Get-AzureADUser | Where-Object userPrincipalName -eq "breakuser@$tenantforbreak"

    $roleDefinition = Get-AzureADMSRoleDefinition | Where-Object displayName -eq "Global Administrator"

    $null = New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $userassignment.objectId

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
        "Path"   = ""
    }

    $null = New-AzureADUser @Parameters

    $userassignment = Get-AzureADUser | Where-Object userPrincipalName -eq "officeline@$tenantforbreak"
    $null = New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $userassignment.objectId

    Write-Host
    Write-Host "Global Administrator role has been successfully assigned to the Break the glass account!" -ForegroundColor Yellow
    
}