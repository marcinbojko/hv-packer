# Post updates entries, not required to do a reboot
Write-Output "Phase 5a [START] - Software"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#install Tabby
choco install tabby -y --ia="/ALLUSERS /S" --no-progress --limit-output
if (Test-Path ("$Env:ProgramFiles\Tabby")) {
  Write-Output "Phase 5a - adding paths for Tabby"
  [Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$Env:ProgramFiles\Tabby",[EnvironmentVariableTarget]::Machine)
}
Write-Output "Phase 5a [END]- Software"

