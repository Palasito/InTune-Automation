Function Get-EndpointSecurityTemplate() {    
    
    $graphApiVersion = "Beta"
    $ESP_resource = "deviceManagement/templates?`$filter=(isof(%27microsoft.graph.securityBaselineTemplate%27))"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($ESP_resource)"
            (Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken).value
    
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
    
Function Get-EndpointSecurityPolicy() {
    
    <#
    .SYNOPSIS
    This function is used to get all Endpoint Security policies using the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets all Endpoint Security templates
    .EXAMPLE
    Get-EndpointSecurityPolicy
    Gets all Endpoint Security Policies in Endpoint Manager
    .NOTES
    NAME: Get-EndpointSecurityPolicy
    #>
    
    
    $graphApiVersion = "Beta"
    $ESP_resource = "deviceManagement/intents"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($ESP_resource)"
            (Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken).value
    
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
    
Function Get-EndpointSecurityTemplateCategory() {
    
    <#
    .SYNOPSIS
    This function is used to get all Endpoint Security categories from a specific template using the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets all template categories
    .EXAMPLE
    Get-EndpointSecurityTemplateCategory -TemplateId $templateId
    Gets an Endpoint Security Categories from a specific template in Endpoint Manager
    .NOTES
    NAME: Get-EndpointSecurityTemplateCategory
    #>
    
    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $TemplateId
    )
    
    $graphApiVersion = "Beta"
    $ESP_resource = "deviceManagement/templates/$TemplateId/categories"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($ESP_resource)"
            (Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken).value
    
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
    
Function Get-EndpointSecurityCategorySetting() {
    
    <#
    .SYNOPSIS
    This function is used to get an Endpoint Security category setting from a specific policy using the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets a policy category setting
    .EXAMPLE
    Get-EndpointSecurityCategorySetting -PolicyId $policyId -categoryId $categoryId
    Gets an Endpoint Security Categories from a specific template in Endpoint Manager
    .NOTES
    NAME: Get-EndpointSecurityCategory
    #>
    
    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $PolicyId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $categoryId
    )
    
    $graphApiVersion = "Beta"
    $ESP_resource = "deviceManagement/intents/$policyId/categories/$categoryId/settings?`$expand=Microsoft.Graph.DeviceManagementComplexSettingInstance/Value"
    
    try {
    
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($ESP_resource)"
            (Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken).value
    
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
    
Function Export-JSONData() {
    
    <#
    .SYNOPSIS
    This function is used to export JSON data returned from Graph
    .DESCRIPTION
    This function is used to export JSON data returned from Graph
    .EXAMPLE
    Export-JSONData -JSON $JSON
    Export the JSON inputted on the function
    .NOTES
    NAME: Export-JSONData
    #>
    
    param (
    
        $JSON,
        $ExportPath
    
    )
    
    try {
    
        if ($JSON -eq "" -or $null -eq $JSON) {
    
            write-host "No JSON specified, please specify valid JSON..." -f Red
    
        }
    
        elseif (!$ExportPath) {
    
            write-host "No export path parameter set, please provide a path to export the file" -f Red
    
        }
    
        elseif (!(Test-Path $ExportPath)) {
    
            write-host "$ExportPath doesn't exist, can't export JSON Data" -f Red
    
        }
    
        else {
    
            $JSON1 = ConvertTo-Json $JSON -Depth 10
    
            $JSON_Convert = $JSON1 | ConvertFrom-Json
    
            $displayName = $JSON_Convert.displayName
    
            # Updating display name to follow file naming conventions - https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx
            $DisplayName = $DisplayName -replace '\<|\>|:|"|/|\\|\||\?|\*', "_"
    
            # Added milliseconds to date format due to duplicate policy name
            $FileName_JSON = "$DisplayName" + ".json"
    
            $JSON1 | Set-Content -LiteralPath "$ExportPath\$FileName_JSON"
                
        }
    
    }
    
    catch {
    
        $_.Exception
    
    }
    
}
    
function Export-EndpointSecurityPolicies() {
    
    [cmdletbinding()]

    param(
        $Path
    )

    ####################################################
    
    #region Authentication
    
    write-host
    
    # Checking if authToken exists before running authentication
    if ($global:authToken) {
    
        # Setting DateTime to Universal time to work in all timezones
        $DateTime = (Get-Date).ToUniversalTime()
    
        # If the authToken exists checking when it expires
        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes
    
        if ($TokenExpires -le 0) {
    
            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host
    
            # Defining User Principal Name if not present
    
            if ($null -eq $User -or $User -eq "") {
    
                $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
                Write-Host
    
            }
    
            $global:authToken = Get-AuthToken -User $User
    
        }
    }
    
    # Authentication doesn't exist, calling Get-AuthToken function
    
    else {
    
        if ($null -eq $User -or $User -eq "") {
    
            $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
            Write-Host
    
        }
    
        # Getting the authorization token
        $global:authToken = Get-AuthToken -User $User
    
    }
    
    #endregion
    
    ####################################################
    
    $ExportPath = $Path
    
    # If the directory path doesn't exist prompt user to create the directory
    $ExportPath = $ExportPath.replace('"', '')
    
    if (!(Test-Path "$ExportPath")) {
    
        Write-Host
        Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow
    
        $Confirm = read-host
    
        if ($Confirm -eq "y" -or $Confirm -eq "Y") {
    
            new-item -ItemType Directory -Path "$ExportPath" | Out-Null
            Write-Host
    
        }
    
        else {
    
            Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
            Write-Host
            break
    
        }
    
    }
    
    Write-Host
    
    #endregion
    
    ####################################################
    
    # Get all Endpoint Security Templates
    $Templates = Get-EndpointSecurityTemplate
    
    ####################################################
    
    # Get all Endpoint Security Policies configured
    $ESPolicies = Get-EndpointSecurityPolicy | Sort-Object displayName
    
    ####################################################
    
    if (-not (Test-Path "$ExportPath\EndpointSecurityPolicies")) {
        $null = New-Item -Path "$ExportPath\EndpointSecurityPolicies" -ItemType Directory
    }

    Write-Host "Exporting Endpoint Security Policies..." -ForegroundColor Cyan

    # Looping through all policies configured
    foreach ($policy in $ESPolicies) {
    
        $PolicyName = $policy.displayName
        $PolicyDescription = $policy.description
        $policyId = $policy.id
        $TemplateId = $policy.templateId
        $roleScopeTagIds = $policy.roleScopeTagIds
    
        $ES_Template = $Templates | Where-Object { $_.id -eq $policy.templateId }
    
        $TemplateDisplayName = $ES_Template.displayName
        $TemplateId = $ES_Template.id
        $versionInfo = $ES_Template.versionInfo
    
        if ($TemplateDisplayName -eq "Endpoint detection and response") {
    
            Write-Host "Export of 'Endpoint detection and response' policy not included in sample script..." -ForegroundColor Magenta
            Write-Host
    
        }
    
        else {
    
            ####################################################
    
            # Creating object for JSON output
            $JSON = New-Object -TypeName PSObject
    
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'displayName' -Value "$PolicyName"
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'description' -Value "$PolicyDescription"
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'roleScopeTagIds' -Value $roleScopeTagIds
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'TemplateDisplayName' -Value "$TemplateDisplayName"
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'TemplateId' -Value "$TemplateId"
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'versionInfo' -Value "$versionInfo"
    
            ####################################################
    
            # Getting all categories in specified Endpoint Security Template
            $Categories = Get-EndpointSecurityTemplateCategory -TemplateId $TemplateId
    
            # Looping through all categories within the Template
    
            foreach ($category in $Categories) {
    
                $categoryId = $category.id
    
                $Settings += Get-EndpointSecurityCategorySetting -PolicyId $policyId -categoryId $categoryId
            
            }
    
            # Adding All settings to settingsDelta ready for JSON export
            Add-Member -InputObject $JSON -MemberType 'NoteProperty' -Name 'settingsDelta' -Value @($Settings)
    
            ####################################################
    
            Export-JSONData -JSON $JSON -ExportPath "$ExportPath\EndpointSecurityPolicies"

            [PSCustomObject]@{
                "Action" = "Export"
                "Type"   = "Endpoint Security"
                "Name"   = $policy.displayName
                "Path"   = "$ExportPath\EndpointSecurityPolicies"
            }
    
            # Clearing up variables so previous data isn't exported in each policy
            Clear-Variable JSON
            Clear-Variable Settings
    
        }
    
    }
}