# Start Teamviewer Installation
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $PSScriptRoot\TeamViewer_Host.msi /qn CUSTOMCONFIGID=vtcuuvt" -NoNewWindow -Wait

Start-Sleep -Seconds 30

# Teamviewer Assign Group
$DisplayName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name LastLoggedOnDisplayName).LastLoggedOnDisplayName

Start-Process -FilePath "C:\Program Files\TeamViewer\TeamViewer.exe" -ArgumentList "assign --api-token=5735986-zZjFqFbaFGpsa7MIBkJT --reassign --alias `"%COMPUTERNAME% | $DisplayName`" --grant-easy-access" -Wait

#Start-Sleep -Seconds 30
#Stop-Service -Name "TeamViewer"
#Start-Sleep -Seconds 10
#Start-Service -Name "TeamViewer"