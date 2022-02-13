# Phase 3 - stuff which is not generic
# Uncomment next line to skip this
# exit 0
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Version="6.26.0",
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('true','false','$true','$false','0','1')]
    [boolean]$AddPrivateChoco=$true,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PuppetMaster="foreman.spcph.local"
)

Write-Output "Phase 3 [START] - Start of Phase 3"
$PuppetConfig="$Env:ProgramData\PuppetLabs\puppet\etc\puppet.conf"
Write-Output "Phase 3 [INFO] - Puppet version  is: $Version"
Write-Output "Phase 3 [INFO] - AddPrivateChoco is: $AddPrivateChoco"
Write-Output "Phase 3 [INFO] - PuppetMaster    is: $PuppetMaster"
Write-Output "Phase 3 [INFO] - PuppetConfig    is: $PuppetConfig"

    # add my myget source
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        # this is private my-get repo - not everybody needs it
        if ($AddPrivateChoco) {
          Write-Output "Phase 3 [INFO] - adding myget repository"
          $ErrorActionPreference = "Stop"
          choco source add -n=public -s"https://www.myget.org/F/public-choco" --priority=10
          if ($LASTEXITCODE -ne 0) {
            exit (1)
          }
        }
    }
    catch {
        Write-Output "Phase 3 [ERROR] - Install source failed"
        exit (1)
    }
    try {
        # install puppet/stop/clean
        Write-Output "Phase 3 [INFO] - Installing puppet in version: $Version"
        $ErrorActionPreference = "Stop"
        choco install puppet-agent --version $Version -y --no-progress --limit-output
        if ($LASTEXITCODE -ne 0) {
          exit (1)
        }
        if (Test-Path -Path $PuppetConfig) {
            Write-Output "Phase 3 [INFO] - Puppet config found in: $PuppetConfig"
            $filecontent=Get-Content $PuppetConfig
            $filecontent -replace "(^server=).*","server=$PuppetMaster"|Set-Content $PuppetConfig
        }
        else {
            Write-Output "Phase 3 [INFO] - Puppet config not found"
        }
    }
    catch {
        Write-Output "Phase 3 [ERROR] - install puppet-agent failed"
        exit (1)
    }
    try {
        Get-Service -name puppet -ErrorAction Silentlycontinue|Stop-Service -Force -ErrorAction Silentlycontinue
        Set-Service -name puppet -StartupType Disabled
        Remove-Item "c:\ProgramData\PuppetLabs\puppet\cache\" -Recurse -Force -ErrorAction Silentlycontinue
        Remove-Item "c:\ProgramData\PuppetLabs\puppet\etc\ssl\" -Recurse -Force -ErrorAction Silentlycontinue
    }
    catch {
        Write-Output "Phase 3 [ERROR] - Cleaning or stopping failed"
        exit (1)
    }
Write-Output "Phase 3 [END] - End of Phase 3"
exit 0
