#https://www.petri.com/manage-windows-updates-with-powershell-module
#install Windows Updates
# For test run disable updates
# exit
Write-Output "Start Phase-4 - Updates"
Install-PackageProvider -Name Nuget -Force
# workaround for lastest PSWindowsUpdate

Install-Module PSWindowsUpdate -Force -Confirm:$false -ErrorAction SilentlyContinue
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false

$modversion=((get-module -listavailable -name pswindowsupdate -ErrorAction SilentlyContinue).version.major|select-object -first 1)

if ($modversion -gt 1) {
    Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -IgnoreReboot
    }
else {
    Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreReboot
    }
Write-Output "End Phase-4 - Updates"
exit 0
