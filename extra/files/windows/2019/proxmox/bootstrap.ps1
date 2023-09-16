# This script is called from the answerfile

# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx

#Write-Host "Copy unattend.xml to C:\Windows\Panther\Unattend\"
#New-Item C:\Windows\Panther\Unattend -Type Directory

# Get network connections
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'))
$connections = $networkListManager.GetNetworkConnections()

$connections |ForEach-Object {
    Write-Host "Setting network config"
    $_.GetNetwork().GetName() + 'category was previously set to' + $_.GetNetwork().GetCategory() | Out-File c:\windows\temp\logfile.txt
    $_.GetNetwork().SetCategory(1)
    $_.GetNetwork().GetName() + 'change to ' + $_.GetNetwork().GetCategory() | Out-File C:\windows\temp\logfile.txt -Append
}

# Install Virtio Drivers

function Enable-Virtio {
Write-Host "Installing Virtio Drivers"
# Search and Install virtio-win-gt-x64.msi Script

# Get all file system drives
$drives = Get-PSDrive -PSProvider 'FileSystem'

# Loop through each drive to find and run the MSI installer
foreach ($drive in $drives) {
    $scriptFile = Join-Path $drive.Root 'virtio-win-gt-x64.msi'

    # Check if the MSI file exists on the current drive
    if (Test-Path $scriptFile) {
        # Run the MSI installer with the specified arguments
        Start-Process msiexec -Wait -ArgumentList '/i', $scriptFile, '/log', 'C:\Windows\Temp\qemu-drivers.log', '/qn', '/passive', '/norestart', 'ADDLOCAL=ALL' -ErrorAction SilentlyContinue
    }
}
# Search and Install virtio-win-gt-x64.msi Script
Write-Host "Installing QEMU Guest Agent"
# Get all file system drives
$drives = Get-PSDrive -PSProvider 'FileSystem'

# Loop through each drive to find and run the MSI installer
foreach ($drive in $drives) {
    $scriptFile = Join-Path $drive.Root '/guest-agent/qemu-ga-x86_64.msi'

    # Check if the MSI file exists on the current drive
    if (Test-Path $scriptFile) {
        # Run the MSI installer with the specified arguments
        Start-Process msiexec -Wait -ArgumentList '/i', $scriptFile, '/log', 'C:\Windows\Temp\qemu-guest-agent.log', '/qn', '/passive', '/norestart', 'ADDLOCAL=ALL' -ErrorAction SilentlyContinue
    }
    }
}

# Write-Host "Installing SPICE"
# # Search and Install virtio-win-guest-tools.exe

# # Get all file system drives
# $drives = Get-PSDrive -PSProvider 'FileSystem'

# # Loop through each drive to find and run the MSI installer
# foreach ($drive in $drives) {
#     $scriptFile = Join-Path $drive.Root 'virtio-win-guest-tools.exe'

#     # Check if the MSI file exists on the current drive
#     if (Test-Path $scriptFile) {
#         # Run the MSI installer with the specified arguments
#         Start-Process msiexec -Wait -ArgumentList '/i', $scriptFile, '/log', 'C:\Windows\Temp\qemu-drivers.log', '/qn', '/passive', '/norestart', 'ADDLOCAL=ALL' -ErrorAction SilentlyContinue
#     }
# }
If (Get-service -Name QEMU-GA -ErrorAction SilentlyContinue) {
    Write-Host "Starting QEMU Guest Agent"
    Start-Service -Name QEMU-GA -ErrorAction SilentlyContinue
}

If (Get-service -Name spice-agent -ErrorAction SilentlyContinue) {
    Write-Host "Starting SPICE"
    Start-Service -Name spice-agent -ErrorAction SilentlyContinue
}

Function Enable-WinRM {
Write-Host "Enable WinRM"
netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM open Port 5985" dir=in action=allow protocol=TCP localport=5985

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

net stop winrm
sc.exe config winrm start= auto
net start winrm

}

Get-WmiObject -Class Win32_UserAccount -Filter "name = 'Administrator'" | Set-WmiInstance -Arguments @{PasswordExpires = 0 }
Enable-Virtio
Enable-WinRM
