Function Add-DeviceAdministrativeTemplatePolicy() {
    [cmdletbinding()]

    param
    (
        $JSON
    )
    
    try {
    
        Test-JSON -JSON $JSON

        $JSON = $JSON | ConvertFrom-Json

        $MainJson = $JSON | Select-Object -Property displayName, description
        $MainJson = $MainJson | ConvertTo-Json
    
        $uri = "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations"
        $Polid = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $MainJson -ContentType "application/json"

        $DefinitionValues = $JSON.definitionValues

        foreach ($def in $DefinitionValues) {

            $def = $def | ConvertTo-Json -Depth 20
            $uri = "https://graph.microsoft.com/Beta/deviceManagement/groupPolicyConfigurations/$($Polid.id)/definitionValues"
            Invoke-RestMethod -Method Post -Headers $authToken -Uri $uri -Body $def

        }
    }
        
    catch {
    
        Write-Error "$_`n"
        Write-Host
        break
    
    }
}