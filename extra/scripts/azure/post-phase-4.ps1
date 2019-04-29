# remove deploy user
Write-Output "Post-Phase-4: Start"
$username="adpacker"
try {
  Get-WMIObject -Class Win32_UserProfile | Where-Object {($_.LocalPath -like "*$username*")} | Remove-WMIObject -Verbose
  Write-Output "Profile of $username removed"
}
catch {
  Write-Output "Failure in removing WMI profile for: $username"
}

try {
  Remove-LocalUser -Name $username -ErrorAction SilentlyContinue -Verbose
  Write-Output "Account of $username removed"
}
catch {
  Write-Output "Failure in removing local user: $username"
}
Write-Output "Post-Phase-4: End"
