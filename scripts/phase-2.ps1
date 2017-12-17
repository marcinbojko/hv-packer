Write-Output "Start of Phase-2"
Set-TimeZone -Id "Central European Standard Time" -Verbose
choco feature enable -n allowEmptyChecksums
choco source add -n=public -s"https://www.myget.org/F/public-choco" --priority=10
choco install conemu sysinternals dotnet4.7 dotnet4.7.1 -y --force
choco install puppet-agent -ia '"PUPPET_MASTER_SERVER=foreman.spcph.local"' -y
Get-Service -name puppet -ErrorAction Silentlycontinue|Stop-Service -Force -ErrorAction Silentlycontinue
Set-Service -name puppet -StartupType Disabled
Remove-Item "c:\ProgramData\PuppetLabs\puppet\cache\" -Recurse -Force -ErrorAction Silentlycontinue
Remove-Item "c:\ProgramData\PuppetLabs\puppet\etc\ssl\" -Recurse -Force -ErrorAction Silentlycontinue
Write-Output "End of Phase-2"
