Function Set-HardMatch() {

    [cmdletbinding()]

    param
    (
        [string]$id,
        [switch]$enable,
        [switch]$disable
    )

    $graphApiVersion = "v1.0"
    $Resource = "directory/onPremisesSynchronization"
    
    try {
        $uri = "https://graph.microsoft.com/$($graphApiVersion)/$($Resource)/$($id)"
        if ($enable) {
            $features = @{'blockCloudObjectTakeoverThroughHardMatchEnabled' = $false}
        }
        if ($disable) {
            $features = @{'blockCloudObjectTakeoverThroughHardMatchEnabled' = $true}
        }
        $body = @{'features' = $features} | ConvertTo-Json -Depth 10
        $null = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Patch -Body $body -ContentType "application/json" 
    }
    catch {
        $ex = $_.Exception
        Write-Host "Request for policy $(($body | ConvertFrom-Json)) to $($uri) failed with HTTP Status $($ex.Response.StatusCode.value__) $($ex.Response.StatusCode)" -ForegroundColor Red
        write-host
    }

}