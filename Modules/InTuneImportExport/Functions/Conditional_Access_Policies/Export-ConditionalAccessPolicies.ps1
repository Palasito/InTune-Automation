function Export-ConditionalAccessPolicies(){

param(
    [parameter()]
    [String]$ExportPath
)
# Connect to Azure AD
# Connect-AzureAD

if (-not (Test-Path "$ExportPath\ConditionalAccessPolicies")) {
    $null = New-Item -Path "$ExportPath\ConditionalAccessPolicies" -ItemType Directory
}


Write-Host "Exporting Conditional Access Policies..." -ForegroundColor cyan

$AllPolicies = Get-AzureADMSConditionalAccessPolicy
foreach ($Policy in $AllPolicies) {
    $PolicyJSON = $Policy | ConvertTo-Json -Depth 6

    $JSONdisplayName = $Policy.DisplayName

    $FinalJSONDisplayName = $JSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

    $PolicyJSON | Out-File $ExportPath\ConditionalAccessPolicies\$($FinalJSONdisplayName).json

    [PSCustomObject]@{
        "Action" = "Export"
        "Type"   = "Conditional Access Policy"
        "Name"   = $Policy.DisplayName
        "Path"   = "ConditionalAccessPolicies\$($FinalJSONdisplayName).json"
    }
}
}