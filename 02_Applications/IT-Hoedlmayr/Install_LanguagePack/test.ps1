
# Prüfen, ob das Modul installiert ist
$moduleName = "LanguagePackManagement"
$module = Get-Module -ListAvailable -Name $moduleName

if ($module) {
    $moduleStatus = "INSTALLIERT"
} else {
    $moduleStatus = "NICHT INSTALLIERT"
}
