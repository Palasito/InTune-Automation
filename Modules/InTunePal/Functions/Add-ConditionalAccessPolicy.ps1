Function Add-ConditionalAccessPolicy() {

    [cmdletbinding()]

    param
    (
        $JSON
    )

    $graphApiVersion = "v1.0"
    $Resource = "identity/conditionalAccess/policies"
    
    try {

        if ($JSON -eq "" -or $null -eq $JSON) {

            write-host "No JSON specified, please specify valid JSON for the Conditional Access Policy..." -f Red

        }

        else {

            Test-JSON -JSON $JSON

            $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
            $null = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json" 

        }

    }
    
    catch {

        $ex = $_.Exception
        Write-Host "Request for policy $(($JSON | ConvertFrom-Json).displayName) to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)" -ForegroundColor Red

    }

}