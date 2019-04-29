# Phase 3 - stuff which is not generic
# Uncomment next line to skip this

# exit 0
Write-Output "Start of Phase-3"
    $puppet_version="5.5.13"
    # add your stuff here
    # add my myget source
    try {
        choco source add -n=public -s"https://www.myget.org/F/public-choco" --priority=10
        # install puppet/stop/clean
        choco install puppet-agent --version $puppet_version -ia '"PUPPET_MASTER_SERVER=foreman.spcph.local"' -y
    }
    catch {
        Write-Output "Phase-3 - Install source or install puppet-agent failed"
    }
    try {
        Get-Service -name puppet -ErrorAction Silentlycontinue|Stop-Service -Force -ErrorAction Silentlycontinue
        Set-Service -name puppet -StartupType Disabled
        Remove-Item "c:\ProgramData\PuppetLabs\puppet\cache\" -Recurse -Force -ErrorAction Silentlycontinue
        Remove-Item "c:\ProgramData\PuppetLabs\puppet\etc\ssl\" -Recurse -Force -ErrorAction Silentlycontinue
    }
    catch {
        Write-Output "Phase-3 - Cleaning or stopping "
    }
Write-Output "End of Phase-3"
exit 0
