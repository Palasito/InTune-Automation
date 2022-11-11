function Invoke-Menu {

    $multiMenuItems = @()

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 1 `
        -Label "Importation " `
        -Order 0 `
        -Info "This option redirects you to the menu regarding the Import functions" `

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 2 `
        -Label "Exportation" `
        -Order 1 `
        -Info "This option redirects you to the menu regarding the Export functions"
    
    $options = @{
        HeaderColor          = [ConsoleColor]::Cyan;
        HelpColor            = [ConsoleColor]::White;
        CurrentItemColor     = [ConsoleColor]::DarkGreen;
        LinkColor            = [ConsoleColor]::DarkCyan;
        CurrentItemLinkColor = [ConsoleColor]::Black;
        MenuDeselected       = "[ ]";
        MenuSelected         = "[x]";
        MenuCannotSelect     = "[/]";
        MenuCannotDeselect   = "[!]";
        MenuInfoColor        = [ConsoleColor]::DarkYellow;
        MenuErrorColor       = [ConsoleColor]::DarkRed;
    }
    
    $header = "Please select the type of work that is going to be performed and then press Enter"
    
    $selectedOptions = Get-InteractiveMenuUserSelection -Header $header -Items $multiMenuItems -Options $options
    
    return $selectedOptions
}