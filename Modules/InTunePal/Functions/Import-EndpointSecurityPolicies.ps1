function Import-EndpointSecurityPolicies {
    param (
        $Path
    )

    #Region Authentication (unused as of version 2.9)
    # $null = Get-Token
    #EndRegion
    
    $ImportPath = $Path

    # Replacing quotes for Test-Path
    $ImportPath = $ImportPath.replace('"', '')

    if (!(Test-Path "$ImportPath")) {

        Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
        Write-Host "Script can't continue..." -ForegroundColor Red
        Write-Host
        break

    }

    ####################################################

    # Getting content of JSON Import file
    $JSON_Data = Get-ChildItem "$ImportPath\EndpointSecurityPolicies" -Recurse -Include *.json

    ####################################################

    # Get all Endpoint Security Templates
    # $Templates = Get-EndpointSecurityTemplatε

    ####################################################

    foreach ($json in $JSON_Data) {
        
        # Converting input to JSON format
        $JSON_in = Get-Content $json.FullName
        $JSON_Convert = $JSON_in | ConvertFrom-Json

        # Excluding certain properties from JSON that aren't required for import
        $JSON_Convert = $JSON_Convert | Select-Object -Property *
        $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 100
        $null = Add-EndpointSecurityPolicy -JSON $JSON_Output
        Write-Host "Imported Endpoint Security Policy $($JSON_Convert.name)"
    }
}