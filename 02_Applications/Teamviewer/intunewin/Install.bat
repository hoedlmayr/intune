start /wait msiexec.exe /i "%~dp0\TeamViewer_Host.msi" /qn CUSTOMCONFIGID=vtcuuvt
ping -n 30 127.0.0.1>nul
"C:\Program Files\TeamViewer\TeamViewer.exe" assign --api-token=5735986-zZjFqFbaFGpsa7MIBkJT --reassign --alias "%COMPUTERNAME% | %USERNAME" --grant-easy-access
ping -n 30 127.0.0.1>nul
net stop teamviewer
ping -n 10 127.0.0.1>nul
net start teamviewer