function Get-FolderName {
    
    [CmdletBinding()]

    param (
        
    )

    $FileBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        ShowNewFolderButton = $true
        Description         = 'Select root folder where the folder structure is located...'
        RootFolder          = 'Desktop'
    }
    if ($FileBrowser.ShowDialog() -ne "OK") {
        exit
    }

    $FileBrowser.Dispose()

    return $FileBrowser.SelectedPath

}