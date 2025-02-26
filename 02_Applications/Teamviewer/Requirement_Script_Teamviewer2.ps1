Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\teamviewer_requirement_check.log"

#function Get-LoggedInDetails() {
    <#
    .SYNOPSIS
    This function checks if a logged-in user exists and returns True or False.
    .DESCRIPTION
    This function finds the logged-in user SID and username when running as System.
    If a user is found, it returns $true; otherwise, it returns $false.
    .EXAMPLE
    Get-LoggedInDetails
    Returns $true if a user is logged in, otherwise $false.
    .NOTES
    NAME: Get-LoggedInDetails
    Written by: Andrew Taylor (Modified)
    #>

    ## Find logged-in username
   # $user = Get-WmiObject Win32_Process -Filter "Name='explorer.exe'" |
   #     ForEach-Object { $_.GetOwner() } |
   #     Select-Object -Unique -Expand User
    $user = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" |
    ForEach-Object { $_ | Invoke-CimMethod -MethodName GetOwner } |
    Select-Object -Unique -ExpandProperty User

    Write-Host "following User is currently logged in: $user"

    if ($user -ne $null) { 
        Write-Host "User is logged in"
        exit 0 
    } else { 
        Write-Host "No user is logged in"
        exit 1 
    }

#}

Stop-Transcript