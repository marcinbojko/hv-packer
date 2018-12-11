Write-Output "Start Phase-5c - Cleaning/zeroing/compacting"
Write-Output "Phase-5c.1: Cleaning updates.."

# Clean WU downloads
Stop-Service -Name wuauserv -Force
    if (Test-Path -Path c:\Windows\SoftwareDistribution\Download ) {
        Remove-Item c:\Windows\SoftwareDistribution\Download\* -Recurse -Force
    }
    if (Test-Path -Path c:\Windows\Prefetch) {
        Remove-Item c:\Windows\Prefetch\*.* -Recurse -Force
    }
Start-Service -Name wuauserv

# Disable Windows Error Reporting
Disable-WindowsErrorReporting -ErrorAction SilentlyContinue
# remove logs
wevtutil el | Foreach-Object {wevtutil cl "$_"}

# resetbase/thin winsxs
dism /online /cleanup-image /StartComponentCleanup /ResetBase
dism /online /cleanup-Image /SPSuperseded

# Remove leftovers from deploy
if (Test-Path -Path c:\Windows\Temp ) {
    Remove-Item c:\Windows\Temp\* -Recurse -Force
}

# optimize disk
Write-Output "Phase-5c.2: Defragging.."
if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
    Optimize-Volume -DriveLetter C -Defrag -verbose
    } else {
    Defrag.exe c: /H
}

Write-Output "Phase-5c.3: Zeroing out empty space..."
 $startDTM = (Get-Date)
 $FilePath="c:\zero.tmp"
 $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
 $ArraySize= 4096kb
 $SpaceToLeave= $Volume.Size * 0.001
 $FileSize= $Volume.FreeSpace - $SpacetoLeave
 $ZeroArray= new-object byte[]($ArraySize)

 $Stream= [io.File]::OpenWrite($FilePath)
 try {
    $CurFileSize = 0
     while($CurFileSize -lt $FileSize) {
         $Stream.Write($ZeroArray,0, $ZeroArray.Length)
         $CurFileSize +=$ZeroArray.Length
     }
 }
 finally {
     if($Stream) {
         $Stream.Close()
     }
 }
 Remove-Item $FilePath -Recurse -Force
 $endDTM = (Get-Date)
 "Zeroing took: $(($endDTM-$startDTM).totalseconds) seconds"

Write-Output "End of Phase-5c"
exit 0