Write-Output "Start Phase-4 - Cleaning/zeroing/compacting"
Write-Output "Phase-4.1: Cleaning updates.."
Stop-Service -Name wuauserv -Force
Remove-Item c:\Windows\SoftwareDistribution\Download\* -Recurse -Force
Start-Service -Name wuauserv

wevtutil el | Foreach-Object {wevtutil cl "$_"}

Write-Output "Phase-4.2: Defragging.."
if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
    Optimize-Volume -DriveLetter C -Defrag -Retrim
    } else {
    Defrag.exe c: /H
}

Write-Output "Phase-4.3: Zeroing out empty space..."
 $startDTM = (Get-Date)
 $FilePath="c:\zero.tmp"
 $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
 $ArraySize= 4096kb
 $SpaceToLeave= $Volume.Size * 0.05
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
Write-Output "End of Phase-4"