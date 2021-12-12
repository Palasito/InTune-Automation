Function Import-AADGroups(){

param(
    [parameter()]
    [String]$Path
)

Write-Host
Write-Host "Creating specified security groups" -ForegroundColor Cyan

$Groups = Import-Csv -Path $Path\CSVs\Groups\*.csv

foreach($Group in $Groups)
{

$null = New-AzureADMSGroup -DisplayName $Group.DisplayName -Description $Group.Description -MailEnabled $False -MailNickName "group" -SecurityEnabled $True

[PSCustomObject]@{
    "Action" = "Import"
    "Type"   = "Groups"  
    "Name"   = $Group.DisplayName
    "Path"   = "$Path\CSVs\Groups"
}

} 

}