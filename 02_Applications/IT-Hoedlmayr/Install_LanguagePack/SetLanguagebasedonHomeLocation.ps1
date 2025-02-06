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

# Log-Start
Write-Log "-------------------------------------"
Write-Log "Spracheinstellungen starten..."

# Aktuelle Region (GeoID) auslesen
$GeoID = (Get-WinHomeLocation).GeoID
Write-Log "Erkannte GeoID: $GeoID"

# Mapping von GeoID zu Sprache
# Liste GeoIDs: https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
# Language/Region tags: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11
$LanguageMap = @{
    94  = "de-DE"  # German (Germany)
    14  = "de-DE"  # German (Austria)
    176 = "nl-NL"  # Dutch (Netherlands)
    109 = "hu-HU"  # Hungarian (Hungary)
    217 = "es-ES"  # Spanish (Spain)
    21  = "nl-NL"  # Dutch (Belgium)
    35  = "bg-BG"  # Bulgarian (Bulgaria)
    108 = "hr-HR"  # Croatian (Croatia)
    75  = "cs-CZ"  # Czech (Czech Republic)
    88  = "ka-GE"  # Georgian (Georgia)
    200 = "ro-RO"  # Romanian (Romania)
    212 = "sl-SI"  # Slovenian (Slovenia)
    235 = "tr-TR"  # Turkish (Türkiye)
    241 = "uk-UA"  # Ukrainian (Ukraine)
    203 = "ru-RU"  # Russian (Russia)
    271 = "sr-Latn-RS"  # Serbian (Latin, Serbia)
}

# Standard-Sprache, falls GeoID nicht erkannt wird
#$LanguageTag = $LanguageMap[$GeoID] ?: "en-US"
$LanguageTag = if ($LanguageMap[$GeoID]) { $LanguageMap[$GeoID] } else { "en-US" }
#$LanguageTag = $LanguageMap[$GeoID] -ne $null ? $LanguageMap[$GeoID] : "en-US"


Write-Log "Eingestellte Sprache: $LanguageTag"

[System.Environment]::SetEnvironmentVariable("InstalledLanguage", $LanguageTag, "Machine")

# LXP für die Sprache installieren (falls noch nicht vorhanden)
Function Install-LXP {
    param (
        [string]$LanguageTag
    )

    # Überprüfen, ob das LXP bereits installiert ist
    $LXPInstalled = Get-WindowsCapability -Online | Where-Object { $_.Name -like "*Language.Basic~~~$LanguageTag*" }

    if ($LXPInstalled.State -ne "Installed") {
        Write-Log "Installiere LXP für $LanguageTag..."
        # LXP herunterladen und installieren
        Add-WindowsCapability -Online -Name "Language.Basic~~~$LanguageTag"
        Write-Log "LXP für $LanguageTag erfolgreich installiert."
    } else {
        Write-Log "LXP für $LanguageTag ist bereits installiert."
    }
}

# LXP für die erkannte Sprache installieren
Install-LXP -Language $LanguageTag

# Spracheinstellungen setzen
try {
    Set-WinUILanguageOverride -Language $LanguageTag
    Write-Log "UI-Sprache erfolgreich gesetzt: $LanguageTag"

    Set-WinUserLanguageList $LanguageTag -Force
    Write-Log "Benutzersprache gesetzt: $LanguageTag"

    Set-WinSystemLocale $LanguageTag
    Write-Log "Systemsprache gesetzt: $LanguageTag"

    Set-Culture $LanguageTag
    Write-Log "Regionsformat gesetzt: $LanguageTag"

    Set-WinHomeLocation -GeoId $GeoID
    Write-Log "System-Region beibehalten: $GeoID"

    Write-Log "Spracheinstellungen erfolgreich abgeschlossen."
} catch {
    Write-Log "Fehler beim Setzen der Sprache: $_"
}