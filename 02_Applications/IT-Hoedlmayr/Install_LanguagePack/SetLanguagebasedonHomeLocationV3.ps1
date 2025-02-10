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
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Log-Start
Write-Log "-------------------------------------"
Write-Log "-------------------------------------"
Write-Log "$timestamp PowerShell Version: ${PSVersion}"
Write-Log "-------------------------------------"
Write-Log "-------------------------------------"
Write-Log "Spracheinstellungen starten..."

# Install required modules to obtain Autopilot Profiles from Intune
# see https://learn.microsoft.com/en-us/autopilot/tutorial/existing-devices/install-modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name WindowsAutopilotIntune -MinimumVersion 5.4.0 -Force
Install-Module -Name Microsoft.Graph.Groups -Force
Install-Module -Name Microsoft.Graph.Authentication -Force
Install-Module Microsoft.Graph.Identity.DirectoryManagement -Force

Import-Module -Name WindowsAutopilotIntune -MinimumVersion 5.4
Import-Module -Name Microsoft.Graph.Groups
Import-Module -Name Microsoft.Graph.Authentication
Import-Module -Name Microsoft.Graph.Identity.DirectoryManagement

# Set PSGallery as a trusted repository
try {
    Write-Log "Setting PSGallery as a trusted repository..."
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    Write-Log "PSGallery is now a trusted repository."
} catch {
    Write-Log "Error setting PSGallery as a trusted repository: $_"
    throw
}

# Prüfen, ob das Modul installiert ist und ggf. installieren
$moduleName = "LanguagePackManagement"
$module = Get-Module -ListAvailable -Name $moduleName
if ($module) {
    $moduleStatus = "INSTALLIERT"
} else {
    $moduleStatus = "NICHT INSTALLIERT"
    try {
        Write-Log "Das Modul 'LanguagePackManagement' ist nicht installiert. Installation wird gestartet..."
        Install-Module -Name $moduleName -Force -Scope AllUsers
        Write-Log "Das Modul 'LanguagePackManagement' wurde erfolgreich installiert."
        Import-Module $moduleName
        Write-Log "Das Modul 'LanguagePackManagement' wurde erfolgreich importiert."
    } catch {
        Write-Log "Fehler bei der Installation des Moduls 'LanguagePackManagement': $_"
        throw
    }
}
Write-Log "Das benoetigte Powershell Modul 'LanguagePackManagement' ist ${ModuleStatus}"

# Aktuelle Region (GeoID) auslesen
try {
    $GeoID = (Get-WinHomeLocation).GeoID
    Write-Log "Erkannte GeoID: $GeoID"
} catch {
    Write-Log "Fehler beim Abrufen der GeoID: $_"
    throw
}

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
try {
    Install-Language-Pack -LanguageTag $LanguageTag
} catch {
    Write-Log "Fehler bei der Installation des Sprachpakets: $_"
    throw
}

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
try {
    Set-Language-Settings -LanguageTag $LanguageTag
} catch {
    Write-Log "Fehler beim Anwenden der Spracheinstellungen: $_"
    throw
}

# Log-Ende
Write-Log "Spracheinstellungen abgeschlossen."

# Abschluss der Transcript-Protokollierung
try {
    Stop-Transcript
    Write-Log "Transcript-Protokollierung erfolgreich beendet."
} catch {
    Write-Log "Fehler beim Beenden von Stop-Transcript: $_"
}
