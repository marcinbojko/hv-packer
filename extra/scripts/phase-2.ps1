# Phase 2 - generic and essential stuff
$goterror=0
$packages=@("conemu","sysinternals","dotnetfx")
$packages_count=$packages.Count
$packages_attempt=1
$packages_success=$false
$packages_success_count=0
$packages_attempt_max=4
$packages_exit_codes=@(0,1605,1614,1641,3010)


Write-Output "Start of Phase 2"
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
  choco feature enable -n allowEmptyChecksums
  Write-Output "Phase 2 - Chocolatey packagess installing, $packages_count to go"
  #safely install packages
  foreach ($package in $packages) {
    $packages_attempt=1
    $packages_success=$false
    do {
      try {
        Write-Output "Phase 2 - Chocolatey installing $package attempt nr. $packages_attempt of $packages_attempt_max"
        choco upgrade $package -y --no-progress
        Write-Output "Phase 2 - Chocolatey installing $package attempt nr. $packages_attempt exit code: $LASTEXITCODE"
        if ($packages_exit_codes.Contains($LASTEXITCODE)) {
            $packages_success=$true
            $packages_success_count++
            Write-Output "Phase 2 - Chocolatey installing $package installed succesfuly in $packages_attempt attempt of $packages_attempt_max"
        }
        else {
          $goterror=1
        }
      }
      catch {
        Write-Output "Phase 2 - Packages installing retry nr. $packages_attempt of $packages_attempt_max "
      }
      $packages_attempt++
    }
    until ($packages_attempt -eq $packages_attempt_max -or $packages_success)
  }
  if (-not $packages_success) {
    $goterror=1
    Write-Output "End of Phase 2 chocolatey packages went wrong"
    Write-Output "End of Phase 2 Succesfuly installed $packages_success_count of $packages_count"
    exit (1)
  }
  Write-Output "End of Phase 2 Succesfuly installed $packages_success_count of $packages_count"
  Write-Output "End of Phase 2"
  if ($goterror) {
    Write-Output "End of Phase 2 something went wrong"
    exit (1)
  }
  else {
    exit 0
  }
