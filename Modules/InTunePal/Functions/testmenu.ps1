function testmenu {

$answerItems = @(
    Get-InteractiveChooseMenuOption `
        -Label "I choose good" `
        -Value "good" `
        -Info "Good info"
    Get-InteractiveChooseMenuOption `
        -Label "I choose bad" `
        -Value "bad" `
        -Info "Bad info"
)

# [Optional] You can change the colors and the symbols
$options = @{
    MenuInfoColor = [ConsoleColor]::DarkYellow
    QuestionColor = [ConsoleColor]::Magenta
    HelpColor = [ConsoleColor]::Cyan
    ErrorColor = [ConsoleColor]::DarkRed
    HighlightColor = [ConsoleColor]::DarkGreen
    OptionSeparator = "`r`n"
}

# Define the question of the menu
$question = "Choos between good and bad"

# Trigger the menu and receive the user answer
# Note: the options parameter is optional
$answer = Get-InteractiveMenuChooseUserSelection -Question $question -Answers $answerItems -Options $options

return $answer
}