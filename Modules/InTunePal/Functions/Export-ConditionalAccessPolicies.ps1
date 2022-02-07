function Export-ConditionalAccessPolicies() {

    param(
        $Path,
        $AzureADToken
    )
    # Connect to Azure AD
    if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens) {
        Write-Host "Getting AzureAD authToken"
        Connect-AzureAD
    }
    else {
        $azureADToken = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
    
    }

    if (-not (Test-Path "$Path\ConditionalAccessPolicies")) {
        $null = New-Item -Path "$Path\ConditionalAccessPolicies" -ItemType Directory
    }
    Write-Host
    Write-Host "Exporting Conditional Access Policies..." -ForegroundColor cyan

    $AllPolicies = Get-AzureADMSConditionalAccessPolicy
    foreach ($Policy in $AllPolicies) {
        $PolicyJSON = $Policy | ConvertTo-Json -Depth 20

        $JSONdisplayName = $Policy.DisplayName

        $FinalJSONDisplayName = $JSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

        $PolicyJSON | Out-File -LiteralPath "$($Path)\ConditionalAccessPolicies\$($FinalJSONdisplayName).json"

        [PSCustomObject]@{
            "Action" = "Export"
            "Type"   = "Conditional Access Policy"
            "Name"   = $Policy.DisplayName
            "Path"   = "ConditionalAccessPolicies\$($FinalJSONdisplayName).json"
        }
    }
}