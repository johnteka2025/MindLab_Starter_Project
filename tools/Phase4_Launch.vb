Set sh = CreateObject("WScript.Shell")
sh.Run "powershell -ExecutionPolicy Bypass -File C:\Projects\MindLab_Starter_Project\tools\Phase4_Backend_Run.ps1", 1, False
WScript.Sleep 2000
sh.Run "powershell -ExecutionPolicy Bypass -File C:\Projects\MindLab_Starter_Project\tools\Phase4_Frontend_Run.ps1", 1, False
