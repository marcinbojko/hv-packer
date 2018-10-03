# remove deploy user
Write-Output "Post-Phase-4: Start"
$username="adpacker"
Get-WMIObject -Class Win32_UserProfile | Where-Object {($_.LocalPath -like "*$username*")} | Remove-WMIObject
Remove-LocalUser -Name $username -ErrorAction SilentlyContinue
Write-Output "Post-Phase-4: End"
