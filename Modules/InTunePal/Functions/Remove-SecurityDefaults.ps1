Function Remove-SecurityDefaults() {

    try {
        $uri = "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy"
        $Settings = Invoke-WebRequest -Headers $authToken -Uri "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy"
        $Settings = $Settings | ConvertFrom-Json
        if ($Settings.isEnabled -eq "true") {
            $body = (@{"isEnabled" = "false" } | ConvertTo-Json)
            $null = Invoke-RestMethod -Method Patch -Headers $authToken -Uri $uri -Body $body
            Write-Host "Security Defaults have been disabled !" -ForegroundColor Green
        }
        else {
            Write-Host "Security defaults are already disabled, will not make any changes..." -ForegroundColor Cyan
        }
    }
    catch {
        write-host "$_`n"
        write-host
        break
    }
}