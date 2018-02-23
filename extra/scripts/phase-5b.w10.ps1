# Post updates entries, not required to do a reboot
Write-Output "Start Phase 5b - After updating"
# Enable Store Updates
if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore')
    {
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore\'-name "AutoDownload" -Force -Verbose -ErrorAction SilentlyContinue
    }

# Enable consumer experience
if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent')
    {
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'-name "DisableWindowsConsumerFeatures" -Verbose -Force -ErrorAction SilentlyContinue
    }
Write-Output "End Phase 5b - After updating"