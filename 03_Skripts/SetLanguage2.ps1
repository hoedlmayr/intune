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
$LanguageTag = if ($LanguageMap[$GeoID]) { $LanguageMap[$GeoID] } else { "en-US" }
Write-Log "Eingestellte Sprache: $LanguageTag"

[System.Environment]::SetEnvironmentVariable("InstalledLanguage", $LanguageTag, "Machine")



# Installation für alle Benutzer durch Registrierung im Store
Function Register-LXP-ForAllUsers {
    param ([string]$LanguageTag)

    # Paket aus dem Store suchen
    $LXP_Package = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*LanguageExperiencePack*$LanguageTag*" }

    if (-not $LXP_Package) {
        Write-Log "LXP-Paket für $LanguageTag nicht gefunden. Versuche Installation..."
        $StoreAppName = "Microsoft.LanguageExperiencePack$($LanguageTag.Replace('-',''))"
        Start-Process -FilePath "explorer.exe" -ArgumentList "ms-windows-store://pdp/?ProductId=$StoreAppName" -Wait
        Start-Sleep -Seconds 10
    }

    # Alle Benutzer registrieren
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*LanguageExperiencePack*$LanguageTag*" } | ForEach-Object {
        Write-Log "Registriere LXP für alle Benutzer: $($_.PackageFullName)"
        Add-AppxPackage -Register -DisableDevelopmentMode "$($_.InstallLocation)\AppxManifest.xml"
    }
}

# LXP für die erkannte Sprache installieren
Install-LXP -LanguageTag $LanguageTag
Register-LXP-ForAllUsers -LanguageTag $LanguageTag

# Spracheinstellungen setzen
try {
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
    Write-Log "Fehler beim Setzen der Sprache: $_"
}

# Neustart für Aktivierung
#Write-Log "System wird in 30 Sekunden neu gestartet..."
#Start-Sleep -Seconds 30
#Restart-Computer -Force



# LXP für die Sprache installieren (falls noch nicht vorhanden)
#Function Install-LXP {
#    param ([string]$LanguageTag)

    # Überprüfen, ob das LXP bereits installiert ist
#    $LXPInstalled = Get-WindowsCapability -Online | Where-Object { $_.Name -like "*Language.Basic~~~$LanguageTag*" }

#    if ($LXPInstalled.State -ne "Installed") {
#        Write-Log "Installiere LXP für $LanguageTag..."
#        Add-WindowsCapability -Online -Name "Language.Basic~~~$LanguageTag"
#        Write-Log "LXP für $LanguageTag erfolgreich installiert."
#    } else {
#        Write-Log "LXP für $LanguageTag ist bereits installiert."
#    }
#}