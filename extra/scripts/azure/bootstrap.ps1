# Create new azure admin user
Write-Output "Bootstrap: Start"
$username="azroot"
$secure_pwd = ConvertTo-SecureString 'P@$$w0rd' -AsPlainText -Force
Remove-LocalUser -Name $username -ErrorAction SilentlyContinue
New-LocalUser $username -Password $secure_pwd -FullName $username -Description "azure deploy user"
Add-LocalGroupMember -Group "Administrators" -Member $username
Write-Output "Bootstrap: End"