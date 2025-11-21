Option Explicit

' ----------------------------------------------------------------------
' ApplyPhase3Schema.vbs
' Reads backend\.env and applies Phase 3 schema using psql (idempotent).
' ----------------------------------------------------------------------

Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
Dim sh  : Set sh  = CreateObject("WScript.Shell")

Dim root    : root    = "C:\Projects\MindLab_Starter_Project"
Dim back    : back    = root & "\backend"
Dim envPath : envPath = back & "\.env"
Dim dbDir   : dbDir   = back & "\db"
Dim sqlPath : sqlPath = dbDir & "\phase3_schema.sql"

If Not fso.FileExists(envPath) Then
  WScript.Echo "ERROR: .env not found at " & envPath
  WScript.Quit 1
End If

' --- parse .env ---
Dim dict : Set dict = CreateObject("Scripting.Dictionary")
dict.CompareMode = 1 ' TextCompare

Dim tf, line, eqPos, k, v
Set tf = fso.OpenTextFile(envPath, 1, False)
Do Until tf.AtEndOfStream
  line = Trim(tf.ReadLine)
  If Len(line) > 0 Then
    If Left(line,1) <> "#" And InStr(line,"=") > 0 Then
      eqPos = InStr(line,"=")
      k = Trim(Left(line, eqPos-1))
      v = Trim(Mid(line, eqPos+1))
      dict(k) = v
    End If
  End If
Loop
tf.Close

Dim DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_DATABASE
DB_HOST     = GetOr(dict,"DB_HOST","127.0.0.1")
DB_PORT     = GetOr(dict,"DB_PORT","5433")
DB_USER     = GetOr(dict,"DB_USER","postgres")
DB_PASSWORD = GetOr(dict,"DB_PASSWORD","password")
DB_DATABASE = GetOr(dict,"DB_DATABASE","mindlab")

' --- write Phase 3 SQL (idempotent) ---
If Not fso.FolderExists(dbDir) Then fso.CreateFolder dbDir

Dim sql
sql = sql & "CREATE EXTENSION IF NOT EXISTS ""uuid-ossp"";" & vbCrLf
sql = sql & "" & vbCrLf
sql = sql & "CREATE TABLE IF NOT EXISTS users (" & vbCrLf
sql = sql & "  id UUID PRIMARY KEY DEFAULT uuid_generate_v4()," & vbCrLf
sql = sql & "  email TEXT UNIQUE NOT NULL," & vbCrLf
sql = sql & "  password TEXT NOT NULL," & vbCrLf
sql = sql & "  xp INTEGER NOT NULL DEFAULT 0," & vbCrLf
sql = sql & "  level INTEGER NOT NULL DEFAULT 1," & vbCrLf
sql = sql & "  streak INTEGER NOT NULL DEFAULT 0" & vbCrLf
sql = sql & ");" & vbCrLf
sql = sql & "" & vbCrLf
sql = sql & "DO $$ BEGIN" & vbCrLf
sql = sql & "  BEGIN" & vbCrLf
sql = sql & "    ALTER TABLE users ADD COLUMN xp INTEGER NOT NULL DEFAULT 0;" & vbCrLf
sql = sql & "  EXCEPTION WHEN duplicate_column THEN NULL; END;" & vbCrLf
sql = sql & "  BEGIN" & vbCrLf
sql = sql & "    ALTER TABLE users ADD COLUMN level INTEGER NOT NULL DEFAULT 1;" & vbCrLf
sql = sql & "  EXCEPTION WHEN duplicate_column THEN NULL; END;" & vbCrLf
sql = sql & "  BEGIN" & vbCrLf
sql = sql & "    ALTER TABLE users ADD COLUMN streak INTEGER NOT NULL DEFAULT 0;" & vbCrLf
sql = sql & "  EXCEPTION WHEN duplicate_column THEN NULL; END;" & vbCrLf
sql = sql & "END $$;" & vbCrLf
sql = sql & "" & vbCrLf
sql = sql & "CREATE TABLE IF NOT EXISTS attempts (" & vbCrLf
sql = sql & "  id BIGSERIAL PRIMARY KEY," & vbCrLf
sql = sql & "  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE," & vbCrLf
sql = sql & "  puzzle_id INTEGER NOT NULL," & vbCrLf
sql = sql & "  correct BOOLEAN NOT NULL," & vbCrLf
sql = sql & "  at TIMESTAMPTZ NOT NULL DEFAULT now()" & vbCrLf
sql = sql & ");" & vbCrLf
sql = sql & "CREATE INDEX IF NOT EXISTS idx_attempts_user_at ON attempts(user_id, at DESC);" & vbCrLf

WriteUtf8NoBom sqlPath, sql

' --- find psql ---
Dim psql : psql = FindPsql()
If psql = "" Then
  WScript.Echo "ERROR: Could not locate psql.exe. Add PostgreSQL\bin to PATH or install PostgreSQL."
  WScript.Quit 2
End If

' --- run psql with ON_ERROR_STOP and in-process PGPASSWORD ---
sh.Environment("PROCESS")("PGPASSWORD") = DB_PASSWORD
Dim cmd
cmd = """" & psql & """ -h " & DB_HOST & " -p " & DB_PORT & " -U " & DB_USER & _
      " -d " & DB_DATABASE & " -v ON_ERROR_STOP=1 -f """ & sqlPath & """"

WScript.Echo "Applying Phase 3 schema to " & DB_HOST & ":" & DB_PORT & "/" & DB_DATABASE & " as " & DB_USER
Dim ex : Set ex = sh.Exec("cmd /c " & cmd)

Dim out : out = ""
Do Until ex.StdOut.AtEndOfStream
  out = out & ex.StdOut.ReadLine() & vbCrLf
Loop
Dim errTxt : errTxt = ""
Do Until ex.StdErr.AtEndOfStream
  errTxt = errTxt & ex.StdErr.ReadLine() & vbCrLf
Loop

If ex.Status = 0 Then
  WScript.Echo "SUCCESS: schema applied."
Else
  WScript.Echo "FAILED: psql exit code " & ex.ExitCode
  If Len(errTxt) > 0 Then WScript.Echo errTxt Else WScript.Echo out
  WScript.Quit 3
End If

' -------- helpers --------
Function GetOr(d, key, def)
  If d.Exists(key) Then GetOr = d(key) Else GetOr = def
End Function

Function FindPsql()
  Dim candidates
  candidates = Array( _
    "C:\Program Files\PostgreSQL\17\bin\psql.exe", _
    "C:\Program Files\PostgreSQL\16\bin\psql.exe", _
    "C:\Program Files\PostgreSQL\15\bin\psql.exe", _
    "C:\Program Files\PostgreSQL\14\bin\psql.exe", _
    "psql.exe", _
    "psql" _
  )
  Dim i
  For i = 0 To UBound(candidates)
    If InPath(candidates(i)) Then
      FindPsql = candidates(i)
      Exit Function
    End If
  Next
  FindPsql = ""
End Function

Function InPath(p)
  On Error Resume Next
  Dim f : f = p
  If InStr(p,"\") = 0 Then
    ' rely on PATH
    InPath = True
    Exit Function
  End If
  InPath = fso.FileExists(f)
  On Error GoTo 0
End Function

Sub WriteUtf8NoBom(path, text)
  Dim stm : Set stm = CreateObject("ADODB.Stream")
  stm.Type = 2 ' text
  stm.Charset = "utf-8"
  stm.Open
  stm.WriteText text
  stm.SaveToFile path, 2
  stm.Close
End Sub
