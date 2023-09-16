# Enable docker
param (
  [string] $requiredVersion = "20.10.4",
  [boolean] $installCompose = $True,
  [string] $composeVersion = "",
  [string] $dockerLocation = "",
  [string] $configDockerLocation = "C:\ProgramData\Docker\config"
)

Write-Output "Phase 5b [START] - Start Phase 5b-Docker"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output "Phase 5b [INFO] - Required Version of docker is : $requiredVersion"
Write-Output "Phase 5b [INFO] - Install compose is set to     : $installCompose"
Write-Output "Phase 5b [INFO] - Docker compose is set to      : $composeVersion"
Write-Output "Phase 5b [INFO] - Docker location is set to     : $dockerLocation"

try {
  Write-Output "Phase 5b [INFO] - Install Dockermsftprovider"
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Confirm:$false -Force
  Update-Module DockerMsftProvider -Force -Confirm:$false
}
catch {
  Write "Phase 5b [ERROR] - Install/Update module problem"
  exit (1)
}
Write-Output "Phase 5b [INFO] - Install Dockermsftprovider succesful"
try {
  Write-Output "Phase 5b [INFO] - Install Docker package"
  # display all versions
  Write-Output "Phase 5b [INFO] - Display all Docker packages"
  Find-Package -providerName DockerMsftProvider -AllVersions
  # install version
  Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion $RequiredVersion -Confirm:$false -Force
  Set-Service -Name docker -StartupType Automatic
}
catch {
  Write "Phase 5b [ERROR] - Install-Package Docker problem"
  exit (1)
}
Write-Output "Phase 5b [INFO] - Install Docker package successful"

if ($installCompose) {
  try {
    if ($composeVersion) {
      choco install docker-compose -y --version $composeVersion --no-progress --limit-output
    }
    else {
      choco install docker-compose -y --no-progress --limit-output
    }

  }
  catch {
    Write "Phase 5b [ERROR] - Install docker-compose problem"
    exit (1)
  }
}

If (! $dockerLocation) {
  Write-Output "Phase 5b [INFO] - Not changing default docker location"
}
else {
  try {
      Write-Output "Phase 5b [INFO] - changing default docker location"
      Stop-Service docker -Force
      $dataRoot=@{ "data-root"="$dockerLocation" }
      if (! (Test-Path -Path $configDockerLocation )) {
        New-Item -ItemType directory -Path $configDockerLocation
      }
      New-Item $configDockerLocation\daemon.json -Force
      Write-Output $dataRoot|ConvertTo-Json|Set-Content $configDockerLocation\daemon.json
      Start-Service docker
  }
  catch {

  }
}
Write-Output "Phase 5b [END] - End Phase 5b"

