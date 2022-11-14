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
    
    $question = "Please select the type of work that is going to be performed and then press Enter"
    
    $answer = Get-InteractiveMenuChooseUserSelection -Question $question -Answers $Items -Options $options
    
    return $answer
}