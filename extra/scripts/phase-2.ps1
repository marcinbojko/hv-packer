# Phase 2 - generic and essential stuff
$goterror=0

Write-Output "Start of Phase-2"
  try {
    Set-TimeZone -Id "Central European Standard Time" -Verbose
  }
  catch {
    Write-Output "Phase 2 - set timezone went wrong"
    $goterror=1
  }
  try {
    Write-Output "Setting high performance power plan"
    powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
  }
  catch {
    Write-Output "Phase 2 - set powercfg went wrong"
    $goterror=1
  }
  try {
    choco feature enable -n allowEmptyChecksums
    choco install conemu sysinternals dotnetfx -y --force
  }
  catch {
    Write-Output "Phase 2 - choco install base packages went wrong"
    $goterror=1
  }

  Write-Output "End of Phase-2"
  if ($goterror) {
    Write-Output "End of Phase-2 something went wrong"
    exit (-1)
  }
  else {
    exit 0
  }
