function Export-ConditionalAccessPolicies(){

param(
    [parameter()]
    [String]$Path
)
# Connect to Azure AD
 $null = Connect-AzureAD

if (-not (Test-Path "$Path\ConditionalAccessPolicies")) {
    $null = New-Item -Path "$Path\ConditionalAccessPolicies" -ItemType Directory
}
Write-Host
Write-Host "Exporting Conditional Access Policies..." -ForegroundColor cyan

$AllPolicies = Get-AzureADMSConditionalAccessPolicy
foreach ($Policy in $AllPolicies) {
    $PolicyJSON = $Policy | ConvertTo-Json -Depth 6

    $JSONdisplayName = $Policy.DisplayName

    $FinalJSONDisplayName = $JSONDisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"

    $PolicyJSON | Out-File $Path\ConditionalAccessPolicies\$($FinalJSONdisplayName).json

    [PSCustomObject]@{
        "Action" = "Export"
        "Type"   = "Conditional Access Policy"
        "Name"   = $Policy.DisplayName
        "Path"   = "ConditionalAccessPolicies\$($FinalJSONdisplayName).json"
    }
}
}