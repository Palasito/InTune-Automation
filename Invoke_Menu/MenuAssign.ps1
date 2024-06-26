function MenuAssign {

    $multiMenuItems = @()


    if ($global:authToken) {

        $multiMenuItems += Get-InteractiveMultiMenuOption `
            -Item 1 `
            -Label "Authenticate to the target Tenant" `
            -Order 1 `
            -Info "This option retrieves an authentication Token to be used with all the exporting operations" `
            -Readonly

    }

    else {

        $multiMenuItems += Get-InteractiveMultiMenuOption `
            -Item 1 `
            -Label "Authenticate to the target Tenant" `
            -Order 1 `
            -Info "This option retrieves an authentication Token to be used with all the exporting operations" `
            -Selected `
            -Readonly
    
    }

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 2 `
        -Label "Assign Groups to Conditional Access Policies" `
        -Order 2 `
        -Info "This option assigns groups as they are specified in the CSVs to Conditional Access Policies"

    # $multiMenuItems += Get-InteractiveMultiMenuOption `
    #     -Item 3 `
    #     -Label "Import Named Locations" `
    #     -Order 3 `
    #     -Info "This option imports ALL Named Locations as jsons" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 4 `
        -Label "Assign Groups to Compliance Policies" `
        -Order 4 `
        -Info "This option assigns groups as they are specified in the CSVs to Compliance Policies"

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 5 `
        -Label "Assign Groups to Device Configuration Policies" `
        -Order 5 `
        -Info "This option assigns groups as they are specified in the CSVs to Device Configuration Policies" 

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 6 `
        -Label "Assign Groups to Update Policies" `
        -Order 6 `
        -Info "This option assigns groups as they are specified in the CSVs to Update Policies"

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 7 `
        -Label "Assign Groups to Client Applications" `
        -Order 7 `
        -Info "This option assigns groups as they are specified in the CSVs to Client Applications"

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 8 `
        -Label "Assign Groups to Application Protection Policies" `
        -Order 8 `
        -Info "This option assigns groups as they are specified in the CSVs to Application Protection Policies"

    $multiMenuItems += Get-InteractiveMultiMenuOption `
        -Item 9 `
        -Label "Assign Groups to Endpoint Security Policies" `
        -Order 9 `
        -Info "This option assigns groups as they are specified in the CSVs to Endpoint Security Policies"
    
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