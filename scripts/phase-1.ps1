Write-Output "Start of Phase-1"
Import-Module ServerManager
Install-WindowsFeature net-framework-core
Install-WindowsFeature net-framework-features
Install-WindowsFeature SNMP-Service -IncludeManagementTools
Install-WindowsFeature SNMP-WMI-Provider -IncludeManagementTools
Install-WindowsFeature Telnet-Client
Install-WindowsFeature RSAT-Role-Tools
Install-WindowsFeature PowerShell-V2
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Verbose
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Verbose
Enable-NetFirewallRule -DisplayGroup "Remote Service Management" -Verbose
Enable-NetFirewallRule -DisplayGroup "Performance Logs and Alerts" -Verbose
Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management" -Verbose
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)" -Verbose
Enable-NetFirewallRule -DisplayGroup "Remote Service Management" -Verbose
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -Verbose
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -Verbose
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0 -Verbose
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 -Verbose
Remove-WindowsFeature -Name Windows-Defender-Features -IncludeManagementTools -ErrorAction SilentlyContinue -Verbose
Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Set-ExecutionPolicy Bypass; Invoke-Expression ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))
Write-Output "End of Phase 1"
