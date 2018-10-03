# Create new azure admin user
Write-Output "Bootstrap: Start"
$username="adpacker"
$secure_pwd = ConvertTo-SecureString 'xBph2L?h' -AsPlainText -Force
Remove-LocalUser -Name $username -ErrorAction SilentlyContinue
New-LocalUser $username -Password $secure_pwd -FullName $username -Description "packer azure deploy user"
Add-LocalGroupMember -Group "Administrators" -Member $username
Write-Output "Bootstrap: End"