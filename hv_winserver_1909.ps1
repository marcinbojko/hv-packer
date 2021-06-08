# Build images

$template_file="./templates/hv_winserver_g2.pkr.hcl"
$var_file="./variables/variables_winserver_1909.pkvars.hcl"
$machine="Windows Server 1909 Standard Gen-2"
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

