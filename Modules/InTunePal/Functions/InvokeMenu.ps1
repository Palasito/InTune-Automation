function InvokeMenu {

    $Items = @()

    $Items += Get-InteractiveChooseMenuOption `
        -Value 1 `
        -Label "Importation " `
        -Info "This option redirects you to the menu regarding the Import functions" 

    $Items += Get-InteractiveChooseMenuOption `
        -Value 2 `
        -Label "Exportation" `
        -Info "This option redirects you to the menu regarding the Export functions"

    $Items += Get-InteractiveChooseMenuOption `
        -Value 3 `
        -Label "Assignments" `
        -Info "This option redirects you to the menu regarding the Group Assignment functions"

    $Items += Get-InteractiveChooseMenuOption `
        -Value 4 `
        -Label "Change Working Path" `
        -Info "This option shows a popup menu to change the working directory"

    $Items += Get-InteractiveChooseMenuOption `
        -Value 5 `
        -Label "Exit" `
        -Info "Just Exit the module"

    $options = @{
        MenuInfoColor   = [ConsoleColor]::DarkYellow
        QuestionColor   = [ConsoleColor]::Cyan
        HelpColor       = [ConsoleColor]::White
        ErrorColor      = [ConsoleColor]::DarkRed
        HighlightColor  = [ConsoleColor]::DarkGreen
        OptionSeparator = "`r`n"
    }
    
    if ($null -eq $global:authToken.Authorization) {
        $question = "Please select the type of work that is going to be performed and then press Enter`nWorking Location is $Path`nAlready Authenticated with user: $($global:authToken.Username)"
    }

    else {
        $question = "Please select the type of work that is going to be performed and then press Enter`nWorking Location is $Path`nNo authentication Token found!"
    }
    
    $answer = Get-InteractiveMenuChooseUserSelection -Question $question -Answers $Items -Options $options
    
    return $answer
}