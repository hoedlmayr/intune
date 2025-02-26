   $user = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" |
    ForEach-Object { $_ | Invoke-CimMethod -MethodName GetOwner } |
    Select-Object -Unique -ExpandProperty User

    Write-Host "following User is currently logged in: $user"

    if ($user -ne $null) { 
        Write-Host "User is logged in"
        $activeuser = $True 
    } else { 
        Write-Host "No user is logged in"
        $activeuser = $False 
    }
    $activeuser 
