function Start-InTuneModule {

    Add-Type -AssemblyName System.Windows.Forms

    Push-Location
    $FileBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        ShowNewFolderButton = $true
        Description         = 'Select root folder where the folder structure is located...'
        RootFolder          = 'Desktop'
    }
    if ($FileBrowser.ShowDialog() -ne "OK") {
        exit
    }
    Pop-Location

    $Path = $FileBrowser.SelectedPath

    $w = InvokeMenu

    switch ($w) {
        1 {
            $i = MenuImport

            if ($i -contains 10) { 
                $w = $null
                Start-InTuneModule
            }
            
            else {
                $command = "Import-Intune -Path $Path"
                if ($i -contains 1) { $Token = " -Token" }
                else { $Token = "" }
                if ($i -contains 2) { $Conditional = " -Conditional" }
                else { $Conditional = "" }
                if ($i -contains 3) { $Named = " -Named" }
                else { $Named = "" }
                if ($i -contains 4) { $Compliance = " -Compliance" }
                else { $Compliance = "" }
                if ($i -contains 5) { $Configuration = " -Configuration" }
                else { $Configuration = "" }
                if ($i -contains 6) { $Update = " -Update" }
                else { $Update = "" }
                if ($i -contains 7) { $Capps = " -Capps" }
                else { $Capps = "" }
                if ($i -contains 8) { $ApplicationProt = " -ApplicationProt" }
                else { $ApplicationProt = "" }
                if ($i -contains 9) { $EndpointSec = " -EndpointSec" }
                else { $EndpointSec = "" }

                $commandf = -join ($command, $Token, $Named, $Conditional, $Compliance, $Configuration, $Update, $Capps, $ApplicationProt, $EndpointSec)
                powershell $commandf
            }
        }
        2 {
            $e = MenuExport

            if ($e -contains 10) { 
                $w = $null
                Start-InTuneModule
            }
            
            else {
                $command = "Export-Intune"
                if ($e -contains 1) { $Token = " -Token" }
                else { $Token = "" }
                if ($e -contains 2) { $Conditional = " -Conditional" }
                else { $Conditional = "" }
                if ($e -contains 3) { $Named = " -Named" }
                else { $Named = "" }
                if ($e -contains 4) { $Compliance = " -Compliance" }
                else { $Compliance = "" }
                if ($e -contains 5) { $Configuration = " -Configuration" }
                else { $Configuration = "" }
                if ($e -contains 6) { $Update = " -Update" }
                else { $Update = "" }
                if ($e -contains 7) { $Capps = " -Capps" }
                else { $Capps = "" }
                if ($e -contains 8) { $ApplicationProt = " -ApplicationProt" }
                else { $ApplicationProt = "" }
                if ($e -contains 9) { $EndpointSec = " -EndpointSec" }
                else { $EndpointSec = "" }

                $commandf = -join ($command, $Token, $Named, $Conditional, $Compliance, $Configuration, $Update, $Capps, $ApplicationProt, $EndpointSec)
                powershell $commandf
            }
        }
        3 {
            MenuAssign
        }
        4 {
            break;
        }
        default {
            Write-Host "Not configured for other options yet" -ForegroundColor Yellow
        }

    }

}