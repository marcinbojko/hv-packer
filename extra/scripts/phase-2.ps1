# Phase 2 - generic and essential stuff
Write-Output "Start of Phase-2"
  Set-TimeZone -Id "Central European Standard Time" -Verbose
  try {
    Write-Output "Setting high performance power plan"
    powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
  }
  catch {
  }
  choco feature enable -n allowEmptyChecksums
  choco install conemu sysinternals dotnet4.7.2 -y --force
Write-Output "End of Phase-2"
exit 0
