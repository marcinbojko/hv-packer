# Phase 2 - generic and essential stuff
$goterror=0
$packages=@("sysinternals","dotnetfx")
$packages_count=$packages.Count
$packages_attempt=1
$packages_success=$false
$packages_success_count=0
$packages_attempt_max=10
$packages_exit_codes=@(0,1605,1614,1641,3010)


Write-Output "Phase 2 [START] - Start of Phase 2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  try {
    Set-TimeZone -Id "Central European Standard Time" -Verbose
  }
  catch {
    Write-Output "Phase 2 [INFO] - set timezone went wrong"
    $goterror=1
  }
  try {
    Write-Output "Phase 2 [INFO] - Setting high performance power plan"
    powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
  }
  catch {
    Write-Output "Phase 2 [ERROR] - Set powercfg went wrong"
    $goterror=1
  }
  choco feature enable -n allowEmptyChecksums
  choco feature enable -name=usePackageExitCodes
  Write-Output "Phase 2 [INFO] - Chocolatey packagess installing, $packages_count to go"
  #safely install packages
  foreach ($package in $packages) {
    $packages_attempt=1
    $packages_success=$false
    do {
      try {
        Write-Output "Phase 2 [INFO] - Chocolatey installing $package attempt nr. $packages_attempt of $packages_attempt_max"
        choco upgrade $package -y --no-progress --limit-output
        Write-Output "Phase 2 [INFO] - Chocolatey installing $package attempt nr. $packages_attempt exit code: $LASTEXITCODE"
        if ($packages_exit_codes.Contains($LASTEXITCODE)) {
            $packages_success=$true
            $packages_success_count++
            Write-Output "Phase 2 [INFO] - Chocolatey installing $package installed succesfuly in $packages_attempt attempt of $packages_attempt_max"
        }
        else {
          $goterror=1
        }
      }
      catch {
        Write-Output "Phase 2 [INFO] - Packages installing retry nr. $packages_attempt of $packages_attempt_max "
      }
      $packages_attempt++
    }
    until ($packages_attempt -eq $packages_attempt_max -or $packages_success)
  }
  if (-not $packages_success) {
    $goterror=1
    Write-Output "Phase 2 [ERROR] - chocolatey packages installation went wrong"
    Write-Output "Phase 2 [WARN] - End of Phase 2 Succesfuly installed $packages_success_count of $packages_count"
    exit (1)
  }
  Write-Output "Phase 2 [INFO] - Succesfuly installed $packages_success_count of $packages_count"
  Write-Output "Phase 2 [END] - End of Phase 2"
  if ($goterror) {
    Write-Output "Phase 2 [ERROR] - something went wrong"
    exit (1)
  }
  else {
    exit 0
  }
