# Hole den Benutzer, der den Explorer-Prozess ausführt
$user = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" |
ForEach-Object { $_ | Invoke-CimMethod -MethodName GetOwner } |
Select-Object -Unique -ExpandProperty User

# Überprüfen, ob der Benutzer nicht DefaultUser0 ist und ob ein Benutzer tatsächlich angemeldet ist
if ($user -ne $null -and $user -ne "DefaultUser0") {
$activeuser = $True
} else {
$activeuser = $False
}

# Ausgabe des Ergebnisses
$activeuser