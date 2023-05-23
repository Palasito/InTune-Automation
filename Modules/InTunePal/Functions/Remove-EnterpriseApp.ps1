function Remove-EnterpriseApp {

    [cmdletbinding()]
    param (

    )

    try {
        $null = Invoke-RestMethod -Method Delete -Headers $authToken -Uri "https://graph.microsoft.com/v1.0/servicePrincipals(appId='d1ddf0e4-d672-4dae-b554-9d5bdfd93547')"
        Write-Host "Enterprise Application has been Successfully deleted" -ForegroundColor Green
    }

    catch {
        $ex = $_.Exception
        Write-Host "Enterprise Application could not be removed!"
        Write-Error "Request to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)"
        break
    }
}
