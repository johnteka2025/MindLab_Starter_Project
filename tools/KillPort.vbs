Option Explicit
If WScript.Arguments.Count = 0 Then
  WScript.Echo "Usage: cscript //nologo KillPort.vbs <port>"
  WScript.Quit 1
End If
Dim port : port = WScript.Arguments(0)
Dim sh : Set sh = CreateObject("WScript.Shell")
Dim ex : Set ex = sh.Exec("cmd /c netstat -ano | findstr /r /c:"":*" & port & " """)
Dim pids : pids = ""
Do Until ex.StdOut.AtEndOfStream
  Dim line, parts, pid
  line = Trim(ex.StdOut.ReadLine())
  If Len(line) > 0 Then
    parts = Split(Replace(line, vbTab, " "))
    pid = parts(UBound(parts))
    If InStr("," & pids & ",", "," & pid & ",") = 0 Then
      If pids = "" Then pids = pid Else pids = pids & "," & pid
    End If
  End If
Loop
If pids = "" Then
  WScript.Echo "No listeners on port " & port
  WScript.Quit 0
End If
Dim i, pidArr : pidArr = Split(pids, ",")
For i = 0 To UBound(pidArr)
  sh.Run "cmd /c taskkill /PID " & pidArr(i) & " /F", 0, True
Next
WScript.Echo "Killed PIDs: " & pids
