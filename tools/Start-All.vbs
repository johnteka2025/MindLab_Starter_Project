Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = "C:\Projects\MindLab_Starter_Project"
' backend first (so DB/schema done), then frontend
sh.Run "powershell -ExecutionPolicy Bypass -File .\tools\Start-Backend.ps1", 1, True
sh.Run "powershell -ExecutionPolicy Bypass -File .\tools\Start-Frontend.ps1", 1, True
