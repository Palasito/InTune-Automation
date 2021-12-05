$deviceconfigid = "99b324ca-937e-4494-ac54-b06d889b04e8"

#get the device configuration
$url = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$deviceconfigid"
$deviceconfiguration = Invoke-RestMethod -Uri $url -Headers $headers1b -Method get

#get the secretid needed to unencrypt the data
$secretid = $deviceconfiguration.omasettings.secretReferenceValueId

#parsing the secretid to unencrypt it
$Value = Invoke-restmethod -Headers $headers1b -Method get -uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$deviceConfigid/getOmaSettingPlainTextValue(secretReferenceValueId='$($secretid)')"
$value | Format-List