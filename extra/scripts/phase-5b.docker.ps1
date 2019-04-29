# Enable docker
$requiredVersion="18.09"
$installCompose = $true

Write-Output "Start Phase 5b-Docker"
try {
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Force -Confirm:$false
  Update-Module DockerMsftProvider -Force -Confirm:$false
}
catch {
  Write "Phase 5b-docker failed - Install/Update module problem"
  exit (-1)
}

try {
  Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion $RequiredVersion -Confirm:$false -Force
  Set-Service -Name docker -StartupType Automatic
}
catch {
  Write "Phase 5b-docker failed - Install-Package Docker problem"
  exit (-1)
}


if ($installCompose) {
  try {
    choco install docker-compose -y
  }
  catch {
    Write "Phase 5b-docker failed - Install docker-compose problem"
  }
}
Write-Output "End Phase 5b"

