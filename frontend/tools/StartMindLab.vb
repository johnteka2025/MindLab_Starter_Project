Set sh = CreateObject("WScript.Shell")
sh.Run "powershell -ExecutionPolicy Bypass -File ""C:\Projects\MindLab_Starter_Project\tools\Start-Backend.ps1""", 1, False
WScript.Sleep 2000
sh.Run "powershell -ExecutionPolicy Bypass -File ""C:\Projects\MindLab_Starter_Project\tools\Start-Frontend.ps1""", 1, False
