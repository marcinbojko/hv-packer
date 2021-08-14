#https://www.petri.com/manage-windows-updates-with-powershell-module
#install Windows Updates
# For test run disable updates
# exit
Write-Output "Phase-4 [START] - Updates"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    Write-Output "Phase-4 [INFO] - Installing Nuget"
    Get-PackageProvider -Name "Nuget" -ForceBootstrap -Verbose -ErrorAction Stop
}
catch {
    Write-Output "Phase-4 [WARN] - Installation of nuget failed, exiting"
}
# workaround for lastest PSWindowsUpdate

try {
    Write-Output "Phase-4 [INFO] - Installing PSWindowsUpdate"
    Install-Module PSWindowsUpdate -Force -Confirm:$false -Verbose -ErrorAction Stop
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
}
catch {
    Write-Output "Phase-4 [INFO]- Installation of PSWindowsUpdate failed, exiting"
    exit (1)
}

try {
    $modversion=((get-module -listavailable -name pswindowsupdate -ErrorAction SilentlyContinue).version.major|select-object -first 1)
    if ($modversion -gt 1) {
        Write-Output "Phase-4 [INFO] - Updates pass started"
        Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -IgnoreReboot -ErrorAction SilentlyContinue
        Write-Output "Phase-4 [INFO] - Updates pass completed"
        }
    else {
        Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
        }
}
catch {
    Write-Output "Phase-4 [WARN] - Updates pass failed, not critical"
    exit (0)
}
Write-Output "Phase-4 [END] - Updates"
exit 0
