#https://www.petri.com/manage-windows-updates-with-powershell-module
#install Windows Updates
# For test run disable updates
# exit
$global:os=""
function whichWindows {
    $version=(Get-WMIObject win32_operatingsystem).name
     if ($version) {
        switch -Regex ($version) {
            '(Server 2016)' {
                $global:os="2016"
                printWindowsVersion
            }
            '(Server 2019)' {
                $global:os="2019"
                printWindowsVersion
            }
            '(Server 2022)' {
                    $global:os="2022"
                    printWindowsVersion
            }
            '(Microsoft Windows Server Standard|Microsoft Windows Server Datacenter)'{
                $ws_version=(Get-WmiObject win32_operatingsystem).buildnumber
                    switch -Regex ($ws_version) {
                        '16299' {
                            $global:os="1709"
                            printWindowsVersion
                        }
                        '17134' {
                            $global:os="1803"
                            printWindowsVersion
                        }
                        '17763' {
                            $global:os="1809"
                            printWindowsVersion
                        }
                        '18362' {
                            $global:os="1903"
                            printWindowsVersion
                        }
                        '18363' {
                            $global:os="1909"
                            printWindowsVersion
                        }
                        '19041' {
                            $global:os="2004"
                            printWindowsVersion
                        }
                        '19042' {
                            $global:os="20H2"
                            printWindowsVersion
                        }
                    }
            }
            '(Windows 10)' {
                Write-Output 'Phase 1 [INFO] - Windows 10 found'
                $global:os="10"
                printWindowsVersion
            }
            default {
                Write-Output "unknown"
                printWindowsVersion
            }
        }
     }
     else {
         throw "Buildnumber empty, cannot continue"
     }
    }
    function printWindowsVersion {
        if ($global:os) {
            Write-Output "Phase 1 [INFO] - Windows Server "$global:os" found."
        }
        else {
            Write-Output "Phase 1 [INFO] - Unknown version of Windows Server found."
        }
    }
Write-Output "Phase-4 [START] - Updates"
# let's check which windows
whichWindows

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
      Import-Module PSWindowsUpdate
      Get-WUServiceManager
      if ($global:os -ne '2022') {
        Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
    }

  }
  catch {
      Write-Output "Phase-4 [INFO]- Installation of PSWindowsUpdate failed, exiting"
      exit (1)
  }
  try {
          Write-Output "Phase-4 [INFO] - Updates pass started"
          Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
          Get-WUHistory
          Write-Output "Phase-4 [INFO] - Updates pass completed"
  }
  catch {
      Write-Output "Phase-4 [WARN] - Updates pass failed, not critical"
      exit (0)
  }

Write-Output "Phase-4 [END] - Updates"
exit 0
