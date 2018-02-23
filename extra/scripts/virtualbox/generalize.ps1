Write-Output "Starting Phase 5a - generalize and prepare sysprep scripts"

New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force

# Installing Guest Additions
Write-Host 'Installing Guest Additions or Parallels Tools'
if (Test-Path d:\VBoxWindowsAdditions.exe) {
  Write-Host "Mounting Drive with VBoxWindowsAdditions"
  & d:\VBoxWindowsAdditions.exe /S
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
}
if (Test-Path e:\VBoxWindowsAdditions.exe) {
  Write-Host "Mounting Drive with VBoxWindowsAdditions"
  & E:\VBoxWindowsAdditions.exe /S
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
}

Write-Output "Ending Phase 5a - generalize and prepare sysprep scripts"
exit 0