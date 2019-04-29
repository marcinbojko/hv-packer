# This script is called from the answerfile

# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx

Write-Output "Bootstrap: Copy unattend.xml to C:\Windows\Panther\Unattend\"
New-Item C:\Windows\Panther\Unattend -Type Directory
New-Item c:\Scripts -Type Directory
Copy-Item a:\unattend.xml C:\Windows\Panther\Unattend\ -Force
New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force
Write-Output "Bootstrap: Copy certificates"
try {
    Copy-Item a:\vbox-sha256.cer c:\Scripts -Force
    Copy-Item a:\vbox-sha1.cer c:\Scripts -Force
    certutil -addstore -f "TrustedPublisher" c:\Scripts\vbox-sha256.cer
    certutil -addstore -f "TrustedPublisher" c:\Scripts\vbox-sha1.cer
}
catch {
    Write-Output "Bootstrap failed"
}

# Get network connections
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'))
$connections = $networkListManager.GetNetworkConnections()

$connections |ForEach-Object {
    Write-Host "Bootstrap: Setting network config"
    $_.GetNetwork().GetName() + 'category was previously set to' + $_.GetNetwork().GetCategory() | Out-File c:\windows\temp\logfile.txt
    $_.GetNetwork().SetCategory(1)
    $_.GetNetwork().GetName() + 'change to ' + $_.GetNetwork().GetCategory() | Out-File C:\windows\temp\logfile.txt -Append
}

Function Enable-WinRM {
    Write-Host "Bootstrap: Enable WinRM"
    netsh advfirewall firewall set rule group="remote administration" new enable=yes
    netsh advfirewall firewall add rule name="Open Port 5985" dir=in action=allow protocol=TCP localport=5985
    Write-Output "Bootstrap: Configuring WinRM"
    winrm quickconfig -q
    winrm quickconfig -transport:http
    winrm set winrm/config '@{MaxTimeoutms="7200000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
    winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
    winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    Write-Output "Bootstrap: Setting WinRM to autostart"
    net stop winrm
    sc.exe config winrm start= auto
    net start winrm
}

Get-WmiObject -Class Win32_UserAccount -Filter "name = 'vagrant'" | Set-WmiInstance -Arguments @{PasswordExpires = 0 }
Enable-WinRM
Write-Output "Bootstrap: End"