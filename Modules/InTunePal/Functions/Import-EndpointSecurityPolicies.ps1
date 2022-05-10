function Import-EndpointSecurityPolicies {
    param (
        $Path
    )

    Get-Tokens

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
    $Templates = Get-EndpointSecurityTemplate

    ####################################################

    foreach ($json in $JSON_Data) {
        
        # Converting input to JSON format
        $JSON_in = Get-Content $json.FullName

        $JSON_Convert = $JSON_in | ConvertFrom-Json

        # Pulling out variables to use in the import
        $JSON_TemplateDisplayName = $JSON_Convert.templateDisplayName
        $JSON_TemplateId = $JSON_Convert.templateId

        ####################################################

        # Checking if templateId from JSON is a valid templateId
        $ES_Template = $Templates | Where-Object { $_.id -eq $JSON_TemplateId }

        ####################################################

        # If template is a baseline Edge, MDATP or Windows, use templateId specified
        if (($ES_Template.templateType -eq "microsoftEdgeSecurityBaseline") -or ($ES_Template.templateType -eq "securityBaseline") -or ($ES_Template.templateType -eq "advancedThreatProtectionSecurityBaseline")) {

            $TemplateId = $JSON_Convert.templateId

        }

        ####################################################

        # Else If not a baseline, check if template is deprecated
        elseif ($ES_Template) {

            # if template isn't deprecated use templateId
            if ($ES_Template.isDeprecated -eq $false) {

                $TemplateId = $JSON_Convert.templateId

            }

            # If template deprecated, look for lastest version
            elseif ($ES_Template.isDeprecated -eq $true) {

                $Template = $Templates | Where-Object { $_.displayName -eq "$JSON_TemplateDisplayName" }

                $Template = $Template | Where-Object { $_.isDeprecated -eq $false }

                $TemplateId = $Template.id

            }

        }

        ####################################################

        # Else If Imported JSON template ID can't be found check if Template Display Name can be used
        elseif ($null -eq $ES_Template) {

            $ES_Template = $Templates | Where-Object { $_.displayName -eq "$JSON_TemplateDisplayName" }

            If ($ES_Template) {

                if (($ES_Template.templateType -eq "securityBaseline") -or ($ES_Template.templateType -eq "advancedThreatProtectionSecurityBaseline")) {

                    Write-Host
                    Write-Host "TemplateID '$JSON_TemplateId' with template Name '$JSON_TemplateDisplayName' doesn't exist..." -ForegroundColor Red
                    Write-Host "Importing using the updated template could fail as settings specified may not be included in the latest template..." -ForegroundColor Red
                    Write-Host
                    break
                }

                else {

                    Write-Host "Template with displayName '$JSON_TemplateDisplayName' found..." -ForegroundColor Green

                    $Template = $ES_Template | Where-Object { $_.isDeprecated -eq $false }

                    $TemplateId = $Template.id

                }

            }

            else {

                Write-Host
                Write-Host "TemplateID '$JSON_TemplateId' with template Name '$JSON_TemplateDisplayName' doesn't exist..." -ForegroundColor Red
                Write-Host "Importing using the updated template could fail as settings specified may not be included in the latest template..." -ForegroundColor Red
                Write-Host
                break
            }

        }

        ####################################################

        # Excluding certain properties from JSON that aren't required for import
        $JSON_Convert = $JSON_Convert | Select-Object -Property * -ExcludeProperty TemplateDisplayName, TemplateId, versionInfo

        $DisplayName = $JSON_Convert.DisplayName

        $JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 5

        Write-Host "Adding Endpoint Security Policy '$DisplayName'" -ForegroundColor Yellow
        Add-EndpointSecurityPolicy -TemplateId $TemplateId -JSON $JSON_Output

    }
}