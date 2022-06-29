function Export-ConditionalAccessPolicies() {

    param(
        $Path,
        $AzureADToken
    )

    #Region Authentication
    Get-Token
    #EndRegion

    if (-not (Test-Path "$Path\ConditionalAccessPolicies")) {
        $null = New-Item -Path "$Path\ConditionalAccessPolicies" -ItemType Directory
    }

    Write-Host
    Write-Host "Exporting Conditional Access Policies..." -ForegroundColor cyan

    $AllPolicies = Get-ConditionalAccessPolicies
    
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