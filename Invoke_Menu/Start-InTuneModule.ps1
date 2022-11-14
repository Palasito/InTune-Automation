function Start-InTuneModule {

    $w = InvokeMenu

    switch ($w) {
        1 {
            MenuImport
        }
        2 {
            MenuExport
        }
        3 {
            MenuAssign
        }
        4 {
            break;
        }
        default {
            Write-Host "Not configured for other options yet" -ForegroundColor Yellow
        }

    }

}