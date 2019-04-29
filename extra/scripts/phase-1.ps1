# Main Phase-1 script
# Windows Features, Firewall rules and registry entries,chocolatey

# Variables
$global:os=""
function whichWindows {
$version=(Get-WMIObject win32_operatingsystem).name
    switch -Regex ($version) {
        '(Server 2016)' {
            Write-Output "Server 2016 found"
            $global:os="2016"
        }
        '(Server 2019)' {
            Write-Output "Server 2019 found"
            $global:os="2019"
        }
        '(Microsoft Windows Server Standard|Microsoft Windows Server Datacenter)'{
            $ws_version=(Get-WmiObject win32_operatingsystem).buildnumber
                switch -Regex ($ws_version) {
                    '16299' {
                        Write-Output "Windows Server 1709 found"
                        $global:os="1709"
                    }
                    '17134' {
                        Write-Output "Windows Server 1803 found"
                        $global:os="1803"
                    }
                    '17763' {
                        Write-Output "Windows Server 1809 found"
                        $global:os="1809"
                    }
                }
        }
        '(Windows 10)' {
            Write-Output 'Windows 10 found'
            $global:os="10"
        }
        default
            {Write-Output "unknown"}
    }
}
whichWindows
# Phase 1 - Mandatory generic stuff
Write-Output "Start of Phase-1"
Import-Module ServerManager
#2016/1709/1803/1809
if ($global:os -notlike '2019') {
   # Install-WindowsFeature NET-Framework-Core,NET-Framework-Features,PowerShell-V2 -IncludeManagementTools
}
# 1709/1803/1809/2019
if ($global:os -notlike '2016') {
    Enable-NetFirewallRule -DisplayGroup "Windows Defender Firewall Remote Management" -Verbose
}
# 2016
if ($global:os -eq '2016') {
    Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management" -Verbose
}



# features and firewall rules common for all Windows Servers
try {
    Install-WindowsFeature NET-Framework-45-Core,Telnet-Client,RSAT-Role-Tools -IncludeManagementTools
    Install-WindowsFeature SNMP-Service,SNMP-WMI-Provider -IncludeManagementTools
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Verbose
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Verbose
    Enable-NetFirewallRule -DisplayGroup "Remote Service Management" -Verbose
    Enable-NetFirewallRule -DisplayGroup "Performance Logs and Alerts" -Verbose
    Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)" -Verbose
    Enable-NetFirewallRule -DisplayGroup "Remote Service Management" -Verbose
    Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -Verbose
}
catch {
}

# Terminal services and sysprep registry entries
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -Verbose -Force
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0 -Verbose -Force
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 -Verbose -Force
    Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus'  -Name  'GeneralizationState' -Value 7 -Verbose -Force
}
catch {
}

# remove Windows Defender
try {
    Remove-WindowsFeature -Name Windows-Defender-Features -IncludeManagementTools -ErrorAction SilentlyContinue -Verbose
}
catch {
}
# Install chocolatey
try {
    Set-ExecutionPolicy Bypass; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
catch {
    Write-Output "Phase 1 choco install problem, exiting"
    exit (-1)
}

#Remove 260 Character Path Limit
if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem') {
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'-name "LongPathsEnabled" -Value 1 -Verbose -Force
}

Write-Output "End of Phase 1"
exit 0
