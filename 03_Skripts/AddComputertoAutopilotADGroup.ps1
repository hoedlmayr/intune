# Variablen definieren
$OU = "OU=Deploy_Autopilot,OU=NewClients,OU=Hoedlmayr,DC=hji,DC=local"    # Ersetze mit deiner OU-DN
$ADGroupName = "Autopilot_Devices"         # Name der AD-Gruppe

# Active Directory-Modul laden
Import-Module ActiveDirectory

# Alle Computer in der angegebenen OU abrufen
$Computers = Get-ADComputer -SearchBase $OU -Filter * -Properties DistinguishedName

# Überprüfen, ob die Gruppe existiert
if (-not (Get-ADGroup -Filter {Name -eq $ADGroupName})) {
    Write-Host "Die Gruppe '$ADGroupName' existiert nicht. Bitte überprüfe den Gruppennamen." -ForegroundColor Red
    exit 1
}

# Alle Computer der Gruppe hinzufügen
foreach ($Computer in $Computers) {
    $ComputerName = $Computer.DistinguishedName

    # Prüfen, ob der Computer bereits Mitglied der Gruppe ist
    $IsMember = Get-ADGroupMember -Identity $ADGroupName | Where-Object { $_.DistinguishedName -eq $ComputerName }

    if (-not $IsMember) {
        try {
            Add-ADGroupMember -Identity $ADGroupName -Members $ComputerName -ErrorAction Stop
            Write-Host "Computer '$($Computer.Name)' wurde der Gruppe '$ADGroupName' hinzugefügt." -ForegroundColor Green
        } catch {
            Write-Host "Fehler beim Hinzufügen von '$($Computer.Name)' zur Gruppe '$ADGroupName': $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Computer '$($Computer.Name)' ist bereits Mitglied der Gruppe '$ADGroupName'." -ForegroundColor Yellow
    }
}
