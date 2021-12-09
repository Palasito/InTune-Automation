$Functions  = @(Get-ChildItem -Path -Recurse -Include $PSScriptRoot\Functions\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in $Functions) {
    try {
        . $Import.Fullname -ErrorAction Stop
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.Fullname): $_" -ErrorAction Continue
    }
}

Export-ModuleMember -Function $Function.Basename