function MenuImport {

    $multiMenuItems = @()

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 1 `
        -Label "Authenticate to the target Tenant" `
        -Order 1 `
        -Info "This option retrieves an authentication Token to be used with all the importing operations" `
        -Readonly

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 2 `
        -Label "Import Conditional Access Policies" `
        -Order 2 `
        -Info "This option imports ALL Conditional Access Policies from jsons"

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 3 `
        -Label "Import Named Locations" `
        -Order 3 `
        -Info "This option imports ALL Named Locations from jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 4 `
        -Label "Import Compliance Policies" `
        -Order 4 `
        -Info "This option imports ALL Compliance Policies from jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 5 `
        -Label "Import Device Configuration Policies" `
        -Order 5 `
        -Info "This option imports ALL Device Configuration Policies from jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 6 `
        -Label "Import Update Policies" `
        -Order 6 `
        -Info "This option imports ALL Update Policies from jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 7 `
        -Label "Import Client Applications" `
        -Order 7 `
        -Info "This option imports ALL Client Applications from jsons" `
        -Readonly

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 8 `
        -Label "Import Application Protection Policies" `
        -Order 8 `
        -Info "This option imports ALL Application Protection Policies from jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 9 `
        -Label "Import Endpoint Security Policies" `
        -Order 9 `
        -Info "This option imports ALL Endpoint Security Policies from jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 10 `
        -Label "Back" `
        -Order 10 `
        -Info "Navigate back to the previous menu" `
        -Standalone
    
    $options = @{
        HeaderColor          = [ConsoleColor]::Cyan;
        HelpColor            = [ConsoleColor]::DarkCyan;
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
    
    $header = "Please select the type of work that is going to be performed"
    
    $selectedOptions = Get-InteractiveMenuUserSelection -Header $header -Items $multiMenuItems -Options $options
    
    return $selectedOptions
}