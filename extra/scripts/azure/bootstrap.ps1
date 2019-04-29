# Create new azure admin user
Write-Output "Bootstrap: Start"
Get-ExecutionPolicy -Verbose
Import-Module ServerManager
$username="adpacker"
$secure_pwd = ConvertTo-SecureString 'xBph2L?h' -AsPlainText -Force
Remove-LocalUser -Name $username -ErrorAction SilentlyContinue -Verbose
try {
  New-LocalUser $username -Password $secure_pwd -FullName $username -Description "packer azure deploy user" -Verbose
  Add-LocalGroupMember -Group "Administrators" -Member $username -Verbose
}
catch {
  Write-Output "Adding user $username failed"
}

Write-Output "Bootstrap: End"