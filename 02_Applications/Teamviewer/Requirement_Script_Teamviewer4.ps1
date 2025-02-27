$user = Get-WmiObject Win32_Process -Filter "Name='explorer.exe'" |
ForEach-Object { $_.GetOwner() } |
Select-Object -Unique -Expand User

    Write-Host "following User is currently logged in: $user"

    if ($user -ne $null) { 
        Write-Host "User is logged in"
        $activeuser = $True 
    } else { 
        Write-Host "No user is logged in"
        $activeuser = $False 
    }
    $activeuser 
