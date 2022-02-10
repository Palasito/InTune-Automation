function Import-ConditionalAccessPolicies() {

    param(
        $Path,
        $Prefix,
        $AzureADToken
    )

    if ($null -eq [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens) {
        Write-Host "Getting AzureAD authToken"
        Connect-AzureAD
    }
    else {
        $azureADToken = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens
    
    }

    # $CAPGroups = Import-Csv -Path $Path\CSVs\ConditionalAccess\*.csv -Delimiter ','
    $BackupJsons = Get-ChildItem "$Path\ConditionalAccessPolicies" -Recurse -Include *.json

    Write-Host
    Write-Host "Importing Conditional Access Policies..." -ForegroundColor cyan

    foreach ($Json in $BackupJsons) {

        $policy = Get-Content $Json.FullName | ConvertFrom-Json

        $check = Get-AzureADMSConditionalAccessPolicy | Where-object { $_.DisplayName -eq $policy.DisplayName }

        if ($null -eq $check) {

            # Create objects for the conditions and GrantControls
            [Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet]$Conditions = $Policy.Conditions
            [Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls]$GrantControls = $Policy.GrantControls
            [Microsoft.Open.MSGraph.Model.ConditionalAccessSessionControls]$SessionControls = $Policy.SessionControls
            $BreakGlass = Get-AzureADUser -SearchString "breakuser"
            $OLUser = Get-AzureADUser -SearchString "officeline"
            $TestUser = Get-AzureADUser -SearchString "testuser"

            $Users = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition

            $Users.IncludeUsers = $Users.IncludeUsers + $Conditions.Users.IncludeUsers
            $Users.IncludeUsers += $TestUser.ObjectId
            $Users.ExcludeUsers += $BreakGlass.ObjectId
            $Users.ExcludeUsers += $OLUser.ObjectId
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
            $NewDisplayName = $Prefix + $Policy.DisplayName
            $Parameters = @{
                DisplayName     = $NewDisplayName
                State           = $Policy.State
                Conditions      = $Conditions
                GrantControls   = $GrantControls
                SessionControls = $SessionControls
            }
        
            [PSCustomObject]@{
                "Action" = "Import"
                "Type"   = "Conditional Access Policy"
                "Name"   = $NewDisplayName
                "From"   = $Json
            }

            $null = New-AzureADMSConditionalAccessPolicy @Parameters
        }
        else {
            Write-Host "Conditional Access policy $($policy.DisplayName) already exists and will not be imported" -ForegroundColor Red
        }
    }
}