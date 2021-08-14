Write-Output "Phase 5c [START] - Vagrant"
# Create Vagrant account
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Disable UAC
reg add HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /d 0 /t REG_DWORD /f /reg:64
# Disable password complexity
secedit /export /cfg c:\secpol.cfg
(Get-Content C:\secpol.cfg) -Replace "PasswordComplexity = 1","PasswordComplexity = 0" | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\secpol.cfg -Force
# Create user
$Password = ConvertTo-SecureString "vagrant" -AsPlainText -Force -Verbose
New-LocalUser "vagrant" -Password $Password -FullName "vagrant" -Description "Vagrant user"
Add-LocalGroupMember -Group "Administrators" -Member "vagrant"
Write-Output "Phase 5c [END] - Vagrant"
