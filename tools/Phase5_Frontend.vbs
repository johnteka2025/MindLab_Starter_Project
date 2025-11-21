Option Explicit
Dim sh, ps
Set sh = CreateObject("WScript.Shell")
ps = "powershell -ExecutionPolicy Bypass -NoProfile -File """ & _
     Replace(WScript.ScriptFullName, "Phase5_Frontend.vbs", "Phase5_Frontend.ps1") & """"
sh.Run ps, 1, False
