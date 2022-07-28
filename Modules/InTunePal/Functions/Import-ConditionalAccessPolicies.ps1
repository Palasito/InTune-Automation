function Import-ConditionalAccessPolicies() {

    param(
        $Path,
        $Prefix,
        $AzureADToken
    )

    # $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','
    $BackupJsons = Get-ChildItem "$Path\ConditionalAccessPolicies" -Recurse -Include *.json

    Write-Host
    Write-Host "Importing Conditional Access Policies..." -ForegroundColor cyan

    $Allexisting = Get-ConditionalAccessPolicies
    foreach ($Json in $BackupJsons) {

        $policy = Get-Content $Json.FullName | ConvertFrom-Json

        $check = $Allexisting | Where-object { $_.displayName -eq $policy.DisplayName }

        if ($null -eq $check) {

            # Create objects for the conditions and GrantControls
            [Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet]$Conditions = $Policy.Conditions
            [Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls]$GrantControls = $Policy.GrantControls
            [Microsoft.Open.MSGraph.Model.ConditionalAccessSessionControls]$SessionControls = $Policy.SessionControls

            $Users = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition

            $Users.IncludeUsers = "None"
            # $Users.IncludeUsers += $TestUser.ObjectId
            # $Users.ExcludeUsers += $BreakGlass.ObjectId
            # $Users.ExcludeUsers += $OLUser.ObjectId
            $Conditions.Users = $Users

            $OldInclLocations = $policy.Conditions.Locations.IncludeLocations
            $OldExclLocations = $Policy.Conditions.Locations.ExcludeLocations
            if ($null -ne $OldInclLocations) {
                $Locations = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessLocationCondition
                foreach ($loc in $OldExclLocations) {
                    if (-not[string]::IsNullOrEmpty($OldExclLocations)) {
                        $Exclloc = Get-AzureADMSNamedLocationPolicy | Where-object displayName -eq "$loc"
                        $Locations.ExcludeLocations += $Exclloc.Id
                    }
                }
                foreach ($loc in $OldInclLocations) {
                    if ($OldInclLocations = "All") {
                        $Locations.IncludeLocations = "All"
                    }
                    elseif (-not[string]::IsNullOrEmpty($OldInclLocations)) {
                        $Inclloc = Get-AzureADMSNamedLocationPolicy | Where-object displayName -eq "$loc"
                        $Locations.IncludeLocations += $Inclloc.Id
                    }
                }

                $Conditions.Locations = $locations
            }

            # Do the same thing for the applications
            $OldApplications = $Policy.Conditions.Applications
            $ApplicationMembers = $OldApplications | Get-Member -MemberType NoteProperty
            $Applications = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
            foreach ($member in $ApplicationMembers) {
                if (-not[string]::IsNullOrEmpty($OldApplications.$($member.Name))) {
                    $Applications.($member.Name) = ($OldApplications.$($member.Name))
                }
            }

            $Conditions.Applications = $Applications
            $Jsontoimport = @{
                displayName     = $Policy.DisplayName
                state           = "disabled"
                conditions      = $Conditions
                grantControls   = $GrantControls
                sessionControls = $SessionControls
            }
        
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Conditional Access Policy"
                "Name"   = $Policy.displayName
                "From"   = $Json
            }

            $null = New-AzureADMSConditionalAccessPolicy @Parameters

            Start-Sleep 3
        }
        else {
            Write-Host "Conditional Access policy $($policy.DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}