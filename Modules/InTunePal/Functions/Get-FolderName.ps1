function Get-FolderName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string]$Message = "Select a directory to save the Log File!!",
        [string]$InitialDirectory = [System.Environment+SpecialFolder]::MyComputer,
        [switch]$ShowNewFolderButton
    )

    $browserForFolderOptions = 0x00000040                                  # BIF_RETURNONLYFSDIRS -bor BIF_NEWDIALOGSTYLE
    $browserForFolderOptions += 0x00000010
    $browserForFolderOptions += 0x00000020
    if ($ShowNewFolderButton) { $browserForFolderOptions += 0x00000200 }  # BIF_NONEWFOLDERBUTTON


    $browser = New-Object -ComObject Shell.Application
    # To make the dialog topmost, you need to supply the Window handle of the current process
    [intPtr]$handle = [System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle

    # see: https://msdn.microsoft.com/en-us/library/windows/desktop/bb773205(v=vs.85).aspx
    $folder = $browser.BrowseForFolder($handle, $Message, $browserForFolderOptions, $InitialDirectory)

    $result = $null
    if ($folder) {
        $result = $folder.Self.Path
    }

    # Release and remove the used Com object from memory
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($browser) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    return $result
}