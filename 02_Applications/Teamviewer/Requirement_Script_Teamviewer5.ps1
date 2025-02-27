Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\teamviewer_requirement_check.log"

$user = Get-WmiObject Win32_Process -Filter "Name='explorer.exe'" |
ForEach-Object { $_.GetOwner() } |
Select-Object -Unique -Expand User

    if ($user -ne $null) { 
        $activeuser = $True 
    } else { 
        $activeuser = $False 
    }
    $activeuser 

Stop-Transcript