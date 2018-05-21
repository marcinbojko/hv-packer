# Phase 3 - less generic stuff
# Uncomment next line to skip this
# exit 0
Write-Output "Start of Phase-3"
    # add your stuff here
    # add my myget source
    choco source add -n=public -s"https://www.myget.org/F/public-choco" --priority=10
    choco install puppet-agent -ia '"PUPPET_MASTER_SERVER=foreman.spcph.local"' -y
    Get-Service -name puppet -ErrorAction Silentlycontinue|Stop-Service -Force -ErrorAction Silentlycontinue
    Set-Service -name puppet -StartupType Disabled
    Remove-Item "c:\ProgramData\PuppetLabs\puppet\cache\" -Recurse -Force -ErrorAction Silentlycontinue
    Remove-Item "c:\ProgramData\PuppetLabs\puppet\etc\ssl\" -Recurse -Force -ErrorAction Silentlycontinue
Write-Output "End of Phase-3"
exit 0
