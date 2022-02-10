Function Test-JSON() {
    
    param (
    
        $JSON
    
    )
    
    try {
    
        ConvertFrom-Json $JSON -ErrorAction Stop
        $validJson = $true
    
    }
    
    catch {
    
        $validJson = $false
        $_.Exception
    
    }
    
    if (!$validJson) {
        
        Write-Host "Provided JSON isn't in valid JSON format" -f Red
        break
    
    }
    
}