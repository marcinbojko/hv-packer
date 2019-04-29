Write-Output "Start of Phase-1 - Enabling RDP, disabling NLA, reset SysprepStatus and show file extensions"

# features

#if (Get-WindowsOptionalFeature -online -FeatureName Microsoft-Windows-Subsystem-Linux)
#    {Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart}
#else
#    {write-output "No feature"}
#
#if (Get-WindowsOptionalFeature -online -FeatureName SimpleTCP)
#    {Enable-WindowsOptionalFeature -Online -FeatureName SimpleTCP -NoRestart}
#else
#    {write-output "No feature"}
#
#if (Get-WindowsOptionalFeature -online -FeatureName MicrosoftWindowsPowerShellV2)
#    {Enable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart}
#else
#    {write-output "No feature"}

#if (Get-WindowsOptionalFeature -online -FeatureName NetFx3) {
#    if (Test-Path d:\) {
#        {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart  -Source:D:\sources\sxs}
#    }
#    if (Test-Path e:\) {
#        {Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart  -Source:e:\sources\sxs}
#    }
#}
#else
#    {write-output "No feature"}

# Firewall rules
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Enable-NetFirewallRule -DisplayGroup "Network Discovery"
Enable-NetFirewallRule -DisplayGroup "Performance Logs and Alerts"
Enable-NetFirewallRule -DisplayGroup "Core Networking"
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
Enable-NetFirewallRule -DisplayGroup "Remote Service Management"
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"

# Enable Remote Desktop features
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -Force
# Disable NLA
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0 -Force
# Sysprep
Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus' -Name 'GeneralizationState' -Value 7 -Force
# Misc
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force

# Disable Store Updates
if (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore\'))
    {
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore' -Verbose -Force
    }
   Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore\'-name "AutoDownload" -Value 2 -Verbose -Force
# Disable consumer experience
# if (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'))
#     {
#         New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Verbose -Force
#         Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'-name "DisableWindowsConsumerFeatures" -Value 1 -Verbose -Force
#     }

#Remove 260 Character Path Limit
if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem')
    {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'-name "LongPathsEnabled" -Value 1 -Verbose -Force
    }

# Enable Chocolatey
Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Enable Ansible
# Set-ExecutionPolicy Bypass;Invoke-Expression ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))
# Spectre and Meltdown AV
# if (!(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat'))
#     {
#         New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat' -Verbose -Force
#     }
#     Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat'-name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Value 0 -Verbose -Force
# Write-Output "End of Phase 1"
exit 0