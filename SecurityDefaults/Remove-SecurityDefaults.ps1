# Function Remove-SecurityDefaults(){

try {
    $uri = "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy"

    # $Settings = (Invoke-RestMethod -Method GET -Uri $uri -Headers $authToken).value

    $Settings = Invoke-WebRequest -Headers $authToken -Uri "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy"

    $Settings = $Settings | ConvertFrom-Json

    if ($Settings.isEnabled -eq "true") {
        $body = (@{"isEnabled" = "false" } | ConvertTo-Json)
            
        $null = Invoke-RestMethod -Method Patch -Headers $authToken -Uri $uri -Body $body
    }
    else {
        Write-Host "Security defaults are already disabled, will not make any changes..." -ForegroundColor Cyan
    }
}
catch {
    write-host $_.Exception.Message -f Red
    write-host $_.Exception.ItemName -f Red
    write-host
    break
}
# }