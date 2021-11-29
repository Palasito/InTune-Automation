<#
.SYNOPSIS
    Restore Conditional Access Policies from JSON files
.DESCRIPTION
    This script uses JSON files in a folder to create new Conditional Access Policies.
    The JSON files should be created with Get-AzureADMSConditionalAccessPolicy
.EXAMPLE
    .\RestoreCA -BackupPath c:\CAP\ -Prefix "Restore - "
    Creates new policies where "Restore - " is added to the Display name
.PARAMETER JSONPath
    Path to the JSON files. Files will be searched recursively
.PARAMETER Prefix
    A prefix that is added to the display name of the policies
.NOTES
    Barbara Forbes
    4bes.nl
#>

param(
    [parameter()]
    [String]$JSONPath,
    [parameter()]
    [string]$Prefix
)

Connect-AzureAD

$BackupJsons = Get-ChildItem $JSONPath -Recurse -Include *.json
foreach ($Json in $BackupJsons) {

    $policy = Get-Content $Json.FullName | ConvertFrom-Json
    $policy.DisplayName

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

   $null = New-AzureADMSConditionalAccessPolicy @Parameters
}