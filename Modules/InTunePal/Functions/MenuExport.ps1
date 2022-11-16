function MenuExport {

    $multiMenuItems = @()

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 1 `
        -Label "Authenticate to the target Tenant" `
        -Order 1 `
        -Info "This option retrieves an authentication Token to be used with all the exporting operations" `
        -Readonly

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 2 `
        -Label "Export Conditional Access Policies" `
        -Order 2 `
        -Info "This option exports ALL Conditional Access Policies as jsons"

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 3 `
        -Label "Export Named Locations" `
        -Order 3 `
        -Info "This option exports ALL Named Locations as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 4 `
        -Label "Export Compliance Policies" `
        -Order 4 `
        -Info "This option exports ALL Compliance Policies as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 5 `
        -Label "Export Device Configuration Policies" `
        -Order 5 `
        -Info "This option exports ALL Device Configuration Policies as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 6 `
        -Label "Export Update Policies" `
        -Order 6 `
        -Info "This option exports ALL Update Policies as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 7 `
        -Label "Export Client Applications" `
        -Order 7 `
        -Info "This option exports ALL Client Applications as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 8 `
        -Label "Export Application Protection Policies" `
        -Order 8 `
        -Info "This option exports ALL Application Protection Policies as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 9 `
        -Label "Export Endpoint Security Policies" `
        -Order 9 `
        -Info "This option exports ALL Endpoint Security Policies as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 10 `
        -Label "Back" `
        -Order 10 `
        -Info "Navigate back to the previous menu"

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
    
    $header = "Please choose which policies you want to export and press Enter"
    
    $selectedOptions = Get-InteractiveMenuUserSelection -Header $header -Items $multiMenuItems -Options $options
    
    return $selectedOptions
}