param(
    [parameter()]
    [String]$ExportPath
)
# Connect to Azure AD
Connect-AzureAD

$AllPolicies = Get-AzureADMSConditionalAccessPolicy

foreach ($Policy in $AllPolicies) {
    Write-Output "Backing up $($Policy.DisplayName)"
    $PolicyJSON = $Policy | ConvertTo-Json -Depth 6
    $PolicyJSON | Out-File $ExportPath$($Policy.DisplayName).json
}