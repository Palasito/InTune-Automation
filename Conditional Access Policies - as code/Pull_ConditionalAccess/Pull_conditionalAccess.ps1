param(
    [parameter()]
    [String]$ExportPath
)
# Connect to Azure AD
Connect-AzureAD

if (-not (Test-Path "$ExportPath\ConditionalAccessPolicies")) {
    $null = New-Item -Path "$ExportPath\ConditionalAccessPolicies" -ItemType Directory
}

$AllPolicies = Get-AzureADMSConditionalAccessPolicy

Write-Output "Exporting Conditional Access Policies..." -ForegroundColor cyan
foreach ($Policy in $AllPolicies) {
    $PolicyJSON = $Policy | ConvertTo-Json -Depth 6
    $PolicyJSON | Out-File $ExportPath\ConditionalAccessPolicies$($Policy.DisplayName).json
    [PSCustomObject]@{
        "Action" = "Export"
        "Type"   = "Conditional Access Policy"
        "Name"   = $Policy.DisplayName
        "Path"   = "ConditionalAccessPolicies\$Policy.DisplayName.json"
    }
}