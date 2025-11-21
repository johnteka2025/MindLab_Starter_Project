Dim shell, cmd
Set shell = CreateObject("WScript.Shell")
cmd = "powershell -ExecutionPolicy Bypass -File " "..\tools\Collect-Logs.ps1"