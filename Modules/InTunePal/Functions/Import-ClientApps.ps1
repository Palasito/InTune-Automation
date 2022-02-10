Function Add-MDMApplication() {
    [cmdletbinding()]
    param
    (
        $JSON
    )

    $graphApiVersion = "Beta"
    $App_resource = "deviceAppManagement/mobileApps"

    try {

        if (!$JSON) {

            write-host "No JSON was passed to the function, provide a JSON variable" -f Red
            break

        }

        Test-JSON -JSON $JSON

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($App_resource)"
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JSON -Headers $authToken

    }

    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
        break

    }

}

####################################################

Function Test-JSON() {

    <#
.SYNOPSIS
This function is used to test if the JSON passed to a REST Post request is valid
.DESCRIPTION
The function tests if the JSON passed to the REST Post is valid
.EXAMPLE
Test-JSON -JSON $JSON
Test if the JSON is valid before calling the Graph REST interface
.NOTES
NAME: Test-AuthHeader
#>

    param (

        $JSON

    )

    try {

        ConvertFrom-Json $JSON -ErrorAction Stop
        $validJson = $true

    }

    catch {

        $validJson = $false
        $_.Exception

    }

    if (!$validJson) {
    
        Write-Host "Provided JSON isn't in valid JSON format" -f Red
        break

    }

}

####################################################

function Import-ClientApps() {

    [cmdletbinding()]
    
    param
    (
        $Path
    )

    if ($global:authToken) {

        $DateTime = (Get-Date).ToUniversalTime()

        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

        if ($TokenExpires -le 0) {

            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host

            if ($null -eq $User -or $User -eq "") {

                $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host

            }

            $global:authToken = Get-AuthToken -User $User

        }
    }

    else {

        if ($null -eq $User -or $User -eq "") {

            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host

        }

        $global:authToken = Get-AuthToken -User $User

    }

    #endregion

    ####################################################

    $ImportPath = $Path

    $ImportPath = $ImportPath.replace('"', '')

    if (!(Test-Path "$ImportPath\ClientApps")) {

        Write-Host "Import Path for JSON files doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    ####################################################

    Write-Host "Importing Client Apps..." -ForegroundColor Cyan
    Write-Host

    $AvailableJSONS = Get-ChildItem "$ImportPath\ClientApps" -Recurse -Include *.json

    foreach ($json in $AvailableJSONS) {

        $JSON_Data = Get-Content $json

        $JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, "@odata.context", uploadState, packageId, appIdentifier, publishingState, usedLicenseCount, totalLicenseCount, productKey, licenseType, packageIdentityName

        $DisplayName = $JSON_Convert.displayName

        $uri = "https://graph.microsoft.com/Beta/deviceAppManagement/mobileApps"
        $check = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).Value | Where-Object { ($_.'displayName').contains("$DisplayName") }

        if ($null -eq $check) {

            $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 10

            $null = Add-MDMApplication -JSON $JSON_Output
    
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "ClientApp"
                "Name"   = $DisplayName
                "From"   = "$json"
            }
        }
        else {
            Write-Host "Client App $($DisplayName) already exists and will not be imported" -ForegroundColor Red
        }

    }
}