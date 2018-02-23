# Phase 1 - Mandatory generic stuff
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
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -Verbose -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0 -Verbose -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 -Verbose -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus'  -Name  'GeneralizationState' -Value 7 -Verbose -Force
Remove-WindowsFeature -Name Windows-Defender-Features -IncludeManagementTools -ErrorAction SilentlyContinue -Verbose
Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Set-ExecutionPolicy Bypass; Invoke-Expression ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))

#Remove 260 Character Path Limit
if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem')
    {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'-name "LongPathsEnabled" -Value 1 -Verbose -Force
    }

# Spectre and Meltdown AV
if (!(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat'))
    {
        New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat' -Verbose -Force
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat'-name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Value 0 -Verbose -Force
    }
# Spectre and Meltdown Mitigations enable
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'-name "FeatureSettingsOverride" -Value 0 -Verbose -Force
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'-name "FeatureSettingsOverrideMask" -Value 3 -Verbose -Force

Write-Output "End of Phase 1"
exit 0
