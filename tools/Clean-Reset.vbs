Dim shell, cmd
Set shell = CreateObject("WScript.Shell")
cmd = "powershell -ExecutionPolicy Bypass -File " "..\tools\Clean-Reset.ps1"