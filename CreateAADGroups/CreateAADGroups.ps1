

param(
    [parameter()]
    [String]$GroupsCsv
)

Connect-AzureAD

$Groups = Import-Csv -Path $GroupsCsv
foreach($Group in $Groups)
{

New-AzureADMSGroup -DisplayName $Group.DisplayName -Description $Group.Description -MailEnabled $False -MailNickName "group" -SecurityEnabled $True

} 