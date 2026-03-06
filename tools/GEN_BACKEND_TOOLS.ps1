Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $TOOLS="$REPO\tools"
  $GEN="$TOOLS\GEN_BACKEND_TOOLS.ps1"
  New-Item -ItemType Directory -Force -Path $TOOLS | Out-Null

  function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

  function Write-FileViaVbs([string]$Path, [string]$Text) {
    $tmp = Join-Path $env:TEMP ("write_utf8_" + [Guid]::NewGuid().ToString("N") + ".vbs")
    $bytes = [Text.Encoding]::UTF8.GetBytes(($Text -replace "`r`n","`n" -replace "`r",""))
    $b64 = [Convert]::ToBase64String($bytes)

@'
Option Explicit
Dim fso, outPath, b64, xml, node, bytes, stm
Set fso = CreateObject("Scripting.FileSystemObject")
outPath = WScript.Arguments(0)
b64 = WScript.Arguments(1)
Set xml = CreateObject("MSXML2.DOMDocument.6.0")
Set node = xml.createElement("b64")
node.dataType = "bin.base64"
node.text = b64
bytes = node.nodeTypedValue
Set stm = CreateObject("ADODB.Stream")
stm.Type = 1
stm.Open
stm.Write bytes
stm.Position = 0
stm.Type = 2
stm.Charset = "utf-8"
stm.Position = 0
Dim txt
txt = stm.ReadText(-1)
stm.Close
Dim parent
parent = fso.GetParentFolderName(outPath)
If parent <> "" Then
  If Not fso.FolderExists(parent) Then fso.CreateFolder(parent)
End If
Dim ts
Set ts = fso.CreateTextFile(outPath, True, True)
ts.Write txt
ts.Close
WScript.Echo "OK_WRITE=" & outPath
'@ | Set-Content -Path $tmp -Encoding ASCII

    $null = & cscript.exe //nologo $tmp $Path $b64
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    if(-not (Test-Path $Path)){ Stop-With "STOP: write failed -> $Path" }

    # OK_PARSE (compile-only; does not execute)
    $cmd = "Set-StrictMode -Version Latest; `$ErrorActionPreference='Stop'; [void][ScriptBlock]::Create((Get-Content -Raw '$Path')); 'OK_PARSE'"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: parse gate failed -> $Path" }
  }

  # Backup broken generator if present
  if(Test-Path $GEN){
    $bak="$TOOLS\backups"
    New-Item -ItemType Directory -Force -Path $bak | Out-Null
    $stamp=Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $GEN "$bak\GEN_BACKEND_TOOLS.ps1.bak_$stamp" -Force
  }

  $genText = @"
Set-StrictMode -Version Latest
`$ErrorActionPreference="Stop"

function Stop-With([string]`$m){ Write-Host `$m -ForegroundColor Red; throw `$m }

function Write-FileViaVbs([string]`$Path, [string]`$Text) {
  `$tmp = Join-Path `$env:TEMP ("write_utf8_" + [Guid]::NewGuid().ToString("N") + ".vbs")
  `$bytes = [Text.Encoding]::UTF8.GetBytes((`$Text -replace "`r`n","`n" -replace "`r",""))
  `$b64 = [Convert]::ToBase64String(`$bytes)

@'
Option Explicit
Dim fso, outPath, b64, xml, node, bytes, stm
Set fso = CreateObject("Scripting.FileSystemObject")
outPath = WScript.Arguments(0)
b64 = WScript.Arguments(1)
Set xml = CreateObject("MSXML2.DOMDocument.6.0")
Set node = xml.createElement("b64")
node.dataType = "bin.base64"
node.text = b64
bytes = node.nodeTypedValue
Set stm = CreateObject("ADODB.Stream")
stm.Type = 1
stm.Open
stm.Write bytes
stm.Position = 0
stm.Type = 2
stm.Charset = "utf-8"
stm.Position = 0
Dim txt
txt = stm.ReadText(-1)
stm.Close
Dim parent
parent = fso.GetParentFolderName(outPath)
If parent <> "" Then
  If Not fso.FolderExists(parent) Then fso.CreateFolder(parent)
End If
Dim ts
Set ts = fso.CreateTextFile(outPath, True, True)
ts.Write txt
ts.Close
WScript.Echo "OK_WRITE=" & outPath
'@ | Set-Content -Path `$tmp -Encoding ASCII

  `$null = & cscript.exe //nologo `$tmp `$Path `$b64
  Remove-Item `$tmp -Force -ErrorAction SilentlyContinue
  if(-not (Test-Path `$Path)){ Stop-With "STOP: write failed -> `$Path" }

  # OK_PARSE (compile-only)
  `$cmd = "Set-StrictMode -Version Latest; `$ErrorActionPreference='Stop'; [void][ScriptBlock]::Create((Get-Content -Raw '`$Path')); 'OK_PARSE'"
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `$cmd | Out-Host
  if(`$LASTEXITCODE -ne 0){ Stop-With "STOP: parse gate failed -> `$Path" }
}

try{
  `$REPO="C:\Projects\MindLab_Starter_Project"
  `$BACKEND="`$REPO\backend"
  `$TOOLS="`$REPO\tools"
  New-Item -ItemType Directory -Force -Path "`$TOOLS\logs","`$TOOLS\pids","`$TOOLS\backups" | Out-Null

  `$START="`$TOOLS\BACKEND_DEV_START.ps1"
  `$STOP ="`$TOOLS\BACKEND_DEV_STOP.ps1"
  `$HEALTH="`$TOOLS\HEALTH_CHECK.ps1"
  `$PATCH="`$TOOLS\PATCH_RUN_ALL_GATES.ps1"

  `$startText=@"
Set-StrictMode -Version Latest
`$ErrorActionPreference="Stop"
function Stop-With([string]`$m){ Write-Host `$m -ForegroundColor Red; throw `$m }

try{
  `$REPO="C:\Projects\MindLab_Starter_Project"
  `$BACKEND="`$REPO\backend"
  `$TOOLS="`$REPO\tools"
  `$LOGDIR="`$TOOLS\logs"
  `$PIDDIR="`$TOOLS\pids"
  `$PORT=8085
  `$STAMP=(Get-Date -Format "yyyyMMdd_HHmmss")
  `$outLog="`$LOGDIR\backend_dev_`$STAMP.out.log"
  `$errLog="`$LOGDIR\backend_dev_`$STAMP.err.log"
  `$pidFile="`$PIDDIR\backend_dev.pid"

  if(!(Test-Path `$BACKEND)){ Stop-With "STOP: missing backend -> `$BACKEND" }
  New-Item -ItemType Directory -Force -Path `$LOGDIR,`$PIDDIR | Out-Null

  # kill any listener on port
  `$conns = netstat -ano | Select-String -Pattern (":`$PORT\s+.*LISTENING\s+(\d+)$")
  foreach(`$m in `$conns){
    `$parts = (`$m.Line -split '\s+') | Where-Object { `$_ }
    `$listenPid = [int]`$parts[-1]
    Stop-Process -Id `$listenPid -Force -ErrorAction SilentlyContinue
  }

  Push-Location `$BACKEND
  if(!(Test-Path "`$BACKEND\node_modules")){
    & cmd.exe /d /c "npm install" | Out-Host
    if(`$LASTEXITCODE -ne 0){ Stop-With "STOP: npm install failed" }
  }
  Pop-Location

  `$p = Start-Process -FilePath "cmd.exe" -ArgumentList @("/d","/c","npm run dev") -WorkingDirectory `$BACKEND -WindowStyle Hidden -PassThru -RedirectStandardOutput `$outLog -RedirectStandardError `$errLog
  Set-Content -Path `$pidFile -Value (`$p.Id.ToString()) -Encoding ASCII

  Write-Host ("OK: backend started. PID=" + `$p.Id) -ForegroundColor Green
  Write-Host ("OUT_LOG=" + `$outLog) -ForegroundColor Cyan
  Write-Host ("ERR_LOG=" + `$errLog) -ForegroundColor Cyan
}
catch{ Write-Host `$_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER to exit" }
"@
  Write-FileViaVbs `$START `$startText

  `$stopText=@"
Set-StrictMode -Version Latest
`$ErrorActionPreference="Stop"
try{
  `$REPO="C:\Projects\MindLab_Starter_Project"
  `$PIDFILE="`$REPO\tools\pids\backend_dev.pid"
  `$PORT=8085

  if(Test-Path `$PIDFILE){
    `$pidText=(Get-Content `$PIDFILE -Raw).Trim()
    if(`$pidText -match '^\d+$'){
      `$backendPid=[int]`$pidText
      Stop-Process -Id `$backendPid -Force -ErrorAction SilentlyContinue
    }
    Remove-Item `$PIDFILE -Force -ErrorAction SilentlyContinue
  }

  `$conns = netstat -ano | Select-String -Pattern (":`$PORT\s+.*LISTENING\s+(\d+)$")
  foreach(`$m in `$conns){
    `$parts = (`$m.Line -split '\s+') | Where-Object { `$_ }
    `$listenPid = [int]`$parts[-1]
    Stop-Process -Id `$listenPid -Force -ErrorAction SilentlyContinue
  }

  Write-Host "OK: backend stopped" -ForegroundColor Green
}
catch{ Write-Host `$_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER to exit" }
"@
  Write-FileViaVbs `$STOP `$stopText

  `$healthText=@"
Set-StrictMode -Version Latest
`$ErrorActionPreference="Stop"
function Stop-With([string]`$m){ Write-Host `$m -ForegroundColor Red; throw `$m }

try{
  `$PORT=8085
  `$url="http://127.0.0.1:`$PORT/health"
  `$deadline=(Get-Date).AddSeconds(90)

  while((Get-Date) -lt `$deadline){
    try{
      `$r = Invoke-WebRequest -UseBasicParsing -Uri `$url -TimeoutSec 5
      if(`$r.StatusCode -ge 200 -and `$r.StatusCode -lt 300){
        Write-Host ("OK: /health reachable -> " + `$r.StatusCode) -ForegroundColor Green
        return
      }
    } catch { Start-Sleep -Seconds 2 }
    Start-Sleep -Seconds 1
  }
  Stop-With "STOP: /health not reachable after 90s -> `$url"
}
catch{ Write-Host `$_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER to exit" }
"@
  Write-FileViaVbs `$HEALTH `$healthText

  `$patchText=@"
Set-StrictMode -Version Latest
`$ErrorActionPreference="Stop"
function Stop-With([string]`$m){ Write-Host `$m -ForegroundColor Red; throw `$m }

try{
  `$REPO="C:\Projects\MindLab_Starter_Project"
  `$TOOLS="`$REPO\tools"
  `$TARGET="`$TOOLS\RUN_ALL_GATES.ps1"
  if(!(Test-Path `$TARGET)){ Stop-With "STOP: missing -> `$TARGET" }

  `$new=@'
Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Stop-With([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $BACKEND="$REPO\backend"
  $TOOLS="$REPO\tools"
  $LOGDIR="$TOOLS\logs"

  & "$TOOLS\CLEAN_REPO.ps1"

  Push-Location $BACKEND
  if(!(Test-Path "$BACKEND\node_modules")){
    & cmd.exe /d /c "npm install" | Out-Host
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: npm install failed" }
  }

  & node -c "src\server.cjs"
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (server.cjs)" }

  if(Test-Path "src\routes\daily.cjs"){
    & node -c "src\routes\daily.cjs"
    if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (daily.cjs)" }
  }
  Pop-Location

  & "$TOOLS\BAN_PID_SCAN.ps1"
  & "$TOOLS\PHASE2_SMOKE.ps1"

  & "$TOOLS\BACKEND_DEV_STOP.ps1" | Out-Null
  & "$TOOLS\BACKEND_DEV_START.ps1" | Out-Null

  try{
    & "$TOOLS\HEALTH_CHECK.ps1" | Out-Null
  } catch {
    if(Test-Path $LOGDIR){
      $latest = Get-ChildItem $LOGDIR -Filter "backend_dev_*.err.log" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
      if($latest){
        Write-Host ("ERR_LOG=" + $latest.FullName) -ForegroundColor Cyan
        Get-Content $latest.FullName -Tail 120 | Out-Host
      }
    }
    throw
  }

  Set-Location $REPO
  $s = git status --porcelain
  if($s){ $s | Out-Host; Stop-With "STOP: repo became dirty after gates" }

  Write-Host "OK: RUN_ALL_GATES PASSED" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER to exit" }
'@

  Set-Content -Path $TARGET -Value $new -Encoding UTF8
  Write-Host "OK: RUN_ALL_GATES patched" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER to exit" }
"@
  Write-FileViaVbs `$PATCH `$patchText

  Write-Host "OK: created scripts (each printed OK_PARSE during creation):" -ForegroundColor Green
  Write-Host `$START
  Write-Host `$STOP
  Write-Host `$HEALTH
  Write-Host `$PATCH
}
catch{ Write-Host `$_ -ForegroundColor Red; throw }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }
"@

  Write-FileViaVbs $GEN $genText
  Write-Host "OK: recreated generator -> $GEN" -ForegroundColor Green
}
catch{ Write-Host $_ -ForegroundColor Red }
finally{ Read-Host "Press ENTER (PowerShell stays open)" }