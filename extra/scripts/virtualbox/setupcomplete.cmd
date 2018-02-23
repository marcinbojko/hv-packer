:: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-vista/cc766314(v=ws.10)
:: Things that should be done after system starts
cmd.exe /c sc config winrm start=auto
cmd.exe /c net start winrm
