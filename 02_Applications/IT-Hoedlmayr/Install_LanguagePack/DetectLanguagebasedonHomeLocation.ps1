# Log-Datei definieren
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LanguageSetup.log"

# Funktion zum Schreiben in die Log-Datei
Function Write-Log {
    param (
        [string]$Message
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
}

# Start Logging
Write-Log "$timestamp PowerShell Version: $psVersion"
Write-Log "-------------------------------------"
Write-Log "Language detection script started..."

# Beispiel: Installierte Sprache abrufen
$InstalledLanguage = [System.Environment]::GetEnvironmentVariable("InstalledLanguage", "Machine")
$LanguageTag = (Get-WinUserLanguageList).LanguageTag
Write-Log "Installed language(s): $InstalledLanguage"

# Pruefen, ob eine der installierten Sprachen enthalten ist
if ($LanguageTag -contains $InstalledLanguage) {
    Write-Log "Language Pack detected: $InstalledLanguage"
    Write-Output "Language Pack detected: $InstalledLanguage"
    exit 0
} else {
    Write-Log "Language Pack not installed. Expected: $LanguageTag, Found: $InstalledLanguage"
    Write-Output "Language Pack not installed."
    exit 1
}