# Log-Datei definieren
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LanguageSetup.log"
$TranscriptFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LanguageSetupTranscript.log"

# Start der Transcript-Protokollierung
try {
    Write-Log "Start-Transcript wird gestartet..."
    Start-Transcript -Path $TranscriptFile -Append -Force
    Write-Log "Transcript-Protokollierung gestartet: $TranscriptFile"
} catch {
    Write-Log "Fehler beim Starten von Start-Transcript: $_"
}


###############################


        #Installing Language (-CopyToSettings = Set Windows Display Language, regional and locale formats)
        Install-Language de-de -CopyToSettings
		
		#Sets the system locale for the current computer. (Systemweite System Location)
        Set-WinSystemLocale -SystemLocale de-de
		
		#Sets the provided language as the System Preferred UI Language.
        Set-SystemPreferredUILanguage de-de
        
        $LanguageTag="de-de"
        [System.Environment]::SetEnvironmentVariable("InstalledLanguage", $LanguageTag, "Machine")


###############################



# Abschluss der Transcript-Protokollierung
try {
    Stop-Transcript
    Write-Log "Transcript-Protokollierung erfolgreich beendet."
} catch {
    Write-Log "Fehler beim Beenden von Stop-Transcript: $_"
}
