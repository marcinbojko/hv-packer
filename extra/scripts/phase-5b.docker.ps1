# Post updates entries, not required to do a reboot
# Enable docker
$requiredVersion="18.09"
$installCompose = $true

Write-Output "Start Phase 5b-Docker"
try {
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
  Update-Module DockerMsftProvider -Force
  Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion $RequiredVersion -Confirm:$false -Force
  Set-Service -Name docker -StartupType Automatic
}
catch {
  Write "Phase 5b-docker failed"
  exit (-1)
}
if ($installCompose) {
  try {
    choco install docker-compose -y
  }
  catch {
  }
}
Write-Output "End Phase 5b"

