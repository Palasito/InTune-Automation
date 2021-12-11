Function Add-BreakGlassAccount(){

    param(
        $tenantforbreak
    )

    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = "P@55w.rd"

    $Parameters= @{
        AccountEnabled = $true
        DisplayName = "Break-Glass Admin"
        PasswordProfile = $PasswordProfile
        UserPrincipalName = breakuser@($tenantforbreak)
    }

    New-AzureADUser @Parameters
}