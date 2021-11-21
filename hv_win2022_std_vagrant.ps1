# Build images

# Get Start Time
$startDTM = (Get-Date)

# Variables
$template_file="./templates/hv_win2022_g2_vagrant.pkr.hcl"
$var_file="./variables/variables_win2022_std.pkvars.hcl"
$machine="Windows Server 2022 Standard Gen-2 Vagrant"
$vbox="./vbox/packer-windows-2022-std-g2.box"
$vbox_checksum="./vbox/packer-windows-2022-std-g2.box.sha256"

$packer_log=0

if ((Test-Path -Path "$template_file") -and (Test-Path -Path "$var_file")) {
  Write-Output "Template and var file found"
  Write-Output "Building: $machine"
  try {
    $env:PACKER_LOG=$packer_log
    packer validate -var-file="$var_file" "$template_file"
  }
  catch {
    Write-Output "Packer validation failed, exiting."
    exit (-1)
  }
  try {
    $env:PACKER_LOG=$packer_log
    packer version
    packer build --force -var-file="$var_file" "$template_file"
    if ($?) {
      Write-Output "Calculating checksums"
      Get-FileHash -Algorithm SHA256 -Path "$vbox"|Out-File "$vbox_checksum" -Verbose
    }
  }
  catch {
    Write-Output "Packer build failed, exiting."
    exit (-1)
  }
}
else {
  Write-Output "Template or Var file not found - exiting"
  exit (-1)
}

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" -ForegroundColor Yellow
