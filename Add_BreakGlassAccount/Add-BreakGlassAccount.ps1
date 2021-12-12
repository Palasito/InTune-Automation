Function Add-BreakGlassAccount(){

    param(
        $tenantforbreak
    )

    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = "P@55w.rd"
    $UserPrincipalName = 'breakuser@' + $tenantforbreak
    Write-Host "Creating the Break-Glass account with username: $UserPrincipalName and password: "$PasswordProfile.Password" !" -ForegroundColor Cyan
    Write-Host
    
    $Parameters= @{
        AccountEnabled = $true
        DisplayName = "Break-Glass Admin"
        PasswordProfile = $PasswordProfile
        UserPrincipalName = $UserPrincipalName
        MailNickName = "breakuser"
    }

    $null = New-AzureADUser @Parameters

    Write-Host
    Write-Host "Break the glass account has been successfully created!" -ForegroundColor Cyan
    
    [PSCustomObject]@{
        "Action" = "Cration"
        "Type"   = "Account"
        "Name"   = $UserPrincipalName
        "Path"   = ""
    }

    $userassignment = Get-AzureADUser | Where-Object userPrincipalName -eq "breakuser@$tenantforbreak"

    $roleDefinition = Get-AzureADMSRoleDefinition | Where-Object displayName -eq "Global Administrator"

    $null = New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $userassignment.objectId

    Write-Host
    Write-Host "Global Administrator role has been successfully assigned to the Break the glass account!" -ForegroundColor Cyan

}