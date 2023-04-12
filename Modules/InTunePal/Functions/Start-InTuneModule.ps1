function Start-InTuneModule {

    #Region Assembly Addition
    Add-Type -AssemblyName System.Windows.Forms
    #EndRegion

    $i = 0
    $e = 0
    $a = 0

    #Region Path
    if ([string]::IsNullOrEmpty($Path)) {

        $Path = Get-FolderName

    }
    elseif ($confirmation -eq 'y') {
        #Do Nothing !
    }
    else {
        $confirmation = Read-Host "Is the working path ($Path) correct? [y/n]"
        if ($confirmation -eq 'n') {
            $confirmation = Read-Host "Do you want to change the working path? [y/n]"
            if ($confirmation -eq 'n') {
                # Do Nothing !
            }
            if ($confirmation -eq 'y') {

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
            }
        }
        if ($confirmation -eq 'y') {
            # Do Nothing !
        }
    }
    #EndRegion 

    #Region Menu
    $w = InvokeMenu

    switch ($w) {
        1 {
            $i = MenuImport

            if ($i -contains 10) { 
                
                Start-InTuneModule
            }
            
            else {
                $command = "Import-Intune -Path '$($Path)'"
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
                Invoke-Expression -Command $commandf
            }
        }
        2 {
            $e = MenuExport

            if ($e -contains 10) { 
                
                Start-InTuneModule
            }
            
            else {
                $command = "Export-Intune -Path '$($Path)'"
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
                Invoke-Expression -Command $commandf
            }
        }
        3 {
            
            $a = MenuAssign

            if ($a -contains 10) { 
                
                Start-InTuneModule
            }
            
            else {
                $command = "Import-IntuneAssigns -Path '$($Path)'"
                if ($a -contains 1) { $Token = " -Token" }
                else { $Token = "" }
                if ($a -contains 2) { $CreateGrp = " -AADGroups" }
                else { $CreateGrp = "" }
                if ($a -contains 3) { $Conditional = " -CAPGroups" }
                else { $Conditional = "" }
                if ($a -contains 4) { $Compliance = " -CPGroups" }
                else { $Compliance = "" }
                if ($a -contains 5) { $Configuration = " -DCPGroups" }
                else { $Configuration = "" }
                if ($a -contains 6) { $Update = " -DUPGroups" }
                else { $Update = "" }
                if ($a -contains 7) { $Capps = " -ApplicationGroups" }
                else { $Capps = "" }
                if ($a -contains 8) { $ApplicationProt = " -APPGroups" }
                else { $ApplicationProt = "" }
                if ($a -contains 9) { $EndpointSec = " -EndpointSecGroups" }
                else { $EndpointSec = "" }

                $commandf = -join ($command, $Token, $CreateGrp, $Conditional, $Compliance, $Configuration, $Update, $Capps, $ApplicationProt, $EndpointSec)
                Invoke-Expression -Command $commandf
            }
        }
        4 {
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

            
            Start-InTuneModule
        }
        5 {
            $global:tenantconfirmation = "y"
            $null = Get-Token
            $global:tenantconfirmation = "n"
        }
        6 {
            $null = Get-Token
            Remove-EnterpriseApp
            $confirmation = Read-Host "Do you want to perform another job? [y/n]"
            if ($confirmation -eq 'n') {
                Write-Host "Thanks for using InTunePal! Have a nice one!" -ForegroundColor Green
                break;
            }
            if ($confirmation -eq 'y') {
                Start-InTuneModule
            }
        }
        7 {
            Write-Host "Thanks for using InTunePal! Have a nice one!" -ForegroundColor Green
            break;
        }
        default {
            Write-Host "Not configured for other options yet" -ForegroundColor Yellow
        }
    }
    #EndRegion
}