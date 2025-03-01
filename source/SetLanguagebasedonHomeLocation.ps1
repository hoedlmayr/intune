# Log-Datei definieren
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LanguageSetup.log"
$TranscriptFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LanguageSetupTranscript.log"

# Funktion zum Schreiben in die Log-Datei
Function Write-Log {
    param (
        [string]$Message
    ) 
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
}
# Start der Transcript-Protokollierung
try {
    Write-Log "Start-Transcript wird gestartet..."
    Start-Transcript -Path $TranscriptFile -Append -Force
    Write-Log "Transcript-Protokollierung gestartet: $TranscriptFile"
} catch {
    Write-Log "Fehler beim Starten von Start-Transcript: $_"
}

# PowerShell-Version abrufen
$PSVersion = $PSVersionTable.PSVersion

# Log-Start
Write-Log "-------------------------------------"
Write-Log "-------------------------------------"
Write-Log "$timestamp PowerShell Version: ${PSVersion}"
Write-Log "-------------------------------------"
Write-Log "-------------------------------------"
Write-Log "Spracheinstellungen starten..."

# Prüfen, ob das Modul installiert ist
$moduleName = "LanguagePackManagement"
$module = Get-Module -ListAvailable -Name $moduleName
if ($module) {
    $moduleStatus = "INSTALLIERT"
} else {
    $moduleStatus = "NICHT INSTALLIERT"
}
Write-Log "Das benoetigte Powershell Modul 'LanguagePackManagement' ist ${ModuleStatus}"

# Aktuelle Region (GeoID) auslesen
$GeoID = (Get-WinHomeLocation).GeoID
Write-Log "Erkannte GeoID: $GeoID"

# Mapping von GeoID zu Sprache
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
$LanguageTag = if ($LanguageMap[$GeoID]) { $LanguageMap[$GeoID] } else { "en-US" }
Write-Log "Eingestellte Sprache: $LanguageTag"

[System.Environment]::SetEnvironmentVariable("InstalledLanguage", $LanguageTag, "Machine")

# Funktion zur Installation von Sprachpaketen
Function Install-Language-Pack {
    param ([string]$LanguageTag)

    try {
        # Überprüfen, ob die Sprache bereits installiert ist
        $InstalledLanguages = Get-WinUserLanguageList
        if ($InstalledLanguages.LanguageTag -contains $LanguageTag) {
            Write-Log "Sprachpaket $LanguageTag ist bereits installiert."
            return
        }

        # Sprachpaket installieren
        Write-Log "Installiere Sprachpaket: $LanguageTag..."
        Install-Language -Language $LanguageTag

        Write-Log "Sprachpaket $LanguageTag erfolgreich installiert."
    } catch {
        Write-Log "Fehler bei der Installation des Sprachpakets ${LanguageTag}: $_"
        throw
    }
}

# Sprache installieren
Install-Language-Pack -LanguageTag $LanguageTag

# Spracheinstellungen setzen
Function Set-Language-Settings {
    param ([string]$LanguageTag)

    try {
        # Überprüfen, ob die Sprache bereits gesetzt ist
        $CurrentSettings = Get-WinUserLanguageList
        if ($CurrentSettings.LanguageTag -contains $LanguageTag) {
            Write-Log "Spracheinstellungen sind bereits korrekt: $LanguageTag"
            return
        }

        # UI-Sprache und Systemsprache setzen
        Set-WinUILanguageOverride -Language $LanguageTag
        Write-Log "UI-Sprache erfolgreich gesetzt: $LanguageTag"

        Set-WinUserLanguageList $LanguageTag -Force
        Write-Log "Benutzersprache gesetzt: $LanguageTag"

        Set-WinSystemLocale -SystemLocale $LanguageTag
        Write-Log "Systemsprache gesetzt: $LanguageTag"

        Set-SystemPreferredUILanguage $LanguageTag
        Write-Log "SystemPreferredUILanguage gesetzt: $LanguageTag"

        Set-Culture $LanguageTag
        Write-Log "Regionsformat gesetzt: $LanguageTag"

        Set-WinHomeLocation -GeoId $GeoID
        Write-Log "System-Region beibehalten: $GeoID"

        Write-Log "Spracheinstellungen erfolgreich abgeschlossen."
    } catch {
        Write-Log "Fehler beim Setzen der Spracheinstellungen: $_"
        throw
    }
}

# Spracheinstellungen anwenden
Set-Language-Settings -LanguageTag $LanguageTag

# Log-Ende
Write-Log "Spracheinstellungen abgeschlossen."

# Abschluss der Transcript-Protokollierung
try {
    Stop-Transcript
    Write-Log "Transcript-Protokollierung erfolgreich beendet."
} catch {
    Write-Log "Fehler beim Beenden von Stop-Transcript: $_"
}
