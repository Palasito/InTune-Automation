function Set-SecDef {

    [cmdletbinding()]
    param (

    )

    $SecDef = Invoke-RestMethod -Method Get -Headers $authToken -Uri "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy"
    # $SecDef = $SecDef

    if ($SecDef.isEnabled -eq "true") {

        try {
            $body = (@{"isEnabled" = "false" } | ConvertTo-Json)
            $null = Invoke-RestMethod -Method Patch -Headers $authToken -Uri "https://graph.microsoft.com/beta/policies/identitySecurityDefaultsEnforcementPolicy" -Body $body
        }

        catch {
            $ex = $_.Exception
            Write-Host "Security Defaults are enabled on the tenant and could not disable them!"
            Write-Error "Request to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
            break
        }
    }
}