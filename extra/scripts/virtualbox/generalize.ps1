# Generalize
$vboxguestinstalled=$false

Write-Output "Starting Phase 5a - generalize and prepare sysprep scripts"
New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force


# Installing Guest Additions
Write-Host 'Installing Virtualbox Guest Additions'
if (Test-Path d:\VBoxWindowsAdditions.exe) {
  Write-Host "Mounting Drive D: with VBoxWindowsAdditions"
  & d:\VBoxWindowsAdditions.exe /S
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
  $vboxguestinstalled=$true
}
if (Test-Path e:\VBoxWindowsAdditions.exe) {
  Write-Host "Mounting Drive E: with VBoxWindowsAdditions"
  & E:\VBoxWindowsAdditions.exe /S
  Write-Host "Sleeping for 60 seconds so we are sure the tools are installed before reboot"
  Start-Sleep -s 60
  $vboxguestinstalled=$true
}
Write-Output "Ending Phase 5a - generalize and prepare sysprep scripts"
if ($vboxguestinstalled) {
  exit 0
}
else {
  Write-Output "Virtualbox Guest Addition Failed - exiting"
  exit (-1)
}
