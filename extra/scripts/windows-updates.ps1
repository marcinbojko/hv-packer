#https://www.petri.com/manage-windows-updates-with-powershell-module
#install Windows Updates
# For test run disable updates
# exit
Write-Output "Start Phase-4 - Updates"
try {
    Write-Output "Start Phase-4 - Installing Nuget"
    Get-PackageProvider -Name "Nuget" -ForceBootstrap -Verbose -ErrorAction Stop
}
catch {
    Write-Output "Start Phase-4 - Installation of nuget failed, exiting"
}
# workaround for lastest PSWindowsUpdate

try {
    Write-Output "Start Phase-4 - Installing PSWindowsUpdate"
    Install-Module PSWindowsUpdate -Force -Confirm:$false -Verbose -ErrorAction Stop
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
}
catch {
    Write-Output "Start Phase-4 - Installation of PSWindowsUpdate failed, exiting"
    exit (1)
}

try {
    $modversion=((get-module -listavailable -name pswindowsupdate -ErrorAction SilentlyContinue).version.major|select-object -first 1)
    if ($modversion -gt 1) {
        Write-Output "End Phase-4 - Updates pass started"
        Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -IgnoreReboot -ErrorAction SilentlyContinue
        Write-Output "End Phase-4 - Updates pass completed"
        }
    else {
        Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
        }
}
catch {
    Write-Output "End Phase-4 - Updates pass failed, not critical"
    exit (0)
}
Write-Output "End Phase-4 - Updates"
exit 0
