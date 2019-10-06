# Enable docker
param (
  [string] $requiredVersion = "19.03.1",
  [boolean] $installCompose = $True,
  [string] $dockerLocation = "",
  [string] $configDockerLocation = "C:\ProgramData\Docker\config"
)

Write-Output "Start Phase 5b-Docker"
Write-Output "Required Version of docker is: $requiredVersion"
Write-Output "Install compose is set to: $installCompose"
Write-Output "Docker location is set to: $dockerLocation"

try {
  Write-Output "Phase 5b-docker - Install Dockermsftprovider"
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Confirm:$false -Verbose -Force
  Update-Module DockerMsftProvider -Force -Confirm:$false -Verbose
}
catch {
  Write "Phase 5b-docker failed - Install/Update module problem"
  exit (-1)
}

try {
  Write-Output "Phase 5b-docker - Install Docker Package"
  Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion $RequiredVersion -Confirm:$false -Verbose -Force
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

If (! $dockerLocation) {
  Write-Output "Phase 5b-docker Not changing default docker location"
}
else {
  try {
      Write-Output "Phase 5b-docker - changing default docker location"
      Stop-Service docker -Force
      $dataRoot=@{ "data-root"="$dockerLocation" }
      if (! (Test-Path -Path $configDockerLocation )) {
        New-Item -ItemType directory -Path $configDockerLocation
      }
      New-Item $configDockerLocation\daemon.json -Force
      Write-Output $dataRoot|ConvertTo-Json|Set-Content $configDockerLocation\daemon.json
      Start-Service docker
  }
  catch {}
}
Write-Output "End Phase 5b"

