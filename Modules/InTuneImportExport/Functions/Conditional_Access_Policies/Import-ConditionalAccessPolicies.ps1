function Import-ConditionalAccessPolicies(){

param(
    [parameter()]
    [String]$Path,
    [parameter()]
    [string]$Prefix
)

# Connect-AzureAD

$BackupJsons = Get-ChildItem "$Path\ConditionalAccessPolicies" -Recurse -Include *.json
Write-Host "Importing Conditional Access Policies..." -ForegroundColor cyan
foreach ($Json in $BackupJsons) {

    $policy = Get-Content $Json.FullName | ConvertFrom-Json
    # $policy.DisplayName

    # Create objects for the conditions and GrantControls
    [Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet]$Conditions = $Policy.Conditions
    [Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls]$GrantControls = $Policy.GrantControls
    [Microsoft.Open.MSGraph.Model.ConditionalAccessSessionControls]$SessionControls = $Policy.SessionControls
    
    # Create an object for the users. 
    # By going through the members we only add properties that are not null
    $OldUsers = $Policy.Conditions.Users
    $UserMembers = $OldUsers | Get-Member -MemberType NoteProperty
    $Users = New-Object Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
    foreach ($member in $UserMembers) {
        if (-not[string]::IsNullOrEmpty($OldUsers.$($member.Name))) {
            $Users.($member.Name) = ($OldUsers.$($member.Name))
        }
    }
    $Conditions.Users = $Users

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
}