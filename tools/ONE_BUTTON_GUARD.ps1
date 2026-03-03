Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Stop-With([string]$msg){
  Write-Host $msg -ForegroundColor Red
  throw $msg
}

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $BACKEND="$REPO\backend"
  $LOGS="$REPO\tools\logs"
  $PIDS="$REPO\tools\pids"
  $PORT=8085
  $BASE="http://127.0.0.1:$PORT"
  $pidFile="$PIDS\backend_$PORT.pid"

  New-Item -ItemType Directory -Force -Path $LOGS,$PIDS | Out-Null
  Set-Location $REPO

  # A) Line endings guard (prevents CRLF add failures)
  git config core.safecrlf false | Out-Host
  git config core.autocrlf false | Out-Host

  if(-not (Test-Path "$REPO\.gitattributes")){
@"
*.js   text eol=lf
*.cjs  text eol=lf
*.mjs  text eol=lf
*.json text eol=lf
*.ps1  text eol=crlf
*.psm1 text eol=crlf
"@ | Set-Content -Path "$REPO\.gitattributes" -Encoding UTF8
  }
  git add .gitattributes | Out-Host
  git add --renormalize . | Out-Host

  # B) Ensure daily.cjs tracked (shim expected)
  if(-not (Test-Path "$REPO\backend\src\routes\daily.cjs")){
    Stop-With "STOP: missing backend\src\routes\daily.cjs"
  }
  & cmd.exe /d /c "cd /d ""$REPO\backend"" && node -c ""src\routes\daily.cjs"""
  if($LASTEXITCODE -ne 0){ Stop-With "STOP: node -c failed (daily.cjs)" }

  git add -f -- "backend/src/routes/daily.cjs" | Out-Host
  $tracked = git ls-files -- "backend/src/routes/daily.cjs"
  if(-not $tracked){ Stop-With "STOP: daily.cjs not tracked" }

  # C) Restart backend (port-safe)
  if(Test-Path $pidFile){
    $backendPid=[int](Get-Content $pidFile -Raw).Trim()
    if(Get-Process -Id $backendPid -ErrorAction SilentlyContinue){
      Stop-Process -Id $backendPid -Force -ErrorAction SilentlyContinue
    }
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
  }

  $listeners=Get-NetTCPConnection -LocalPort $PORT -State Listen -ErrorAction SilentlyContinue
  foreach($l in $listeners){
    try{ Stop-Process -Id $l.OwningProcess -Force -ErrorAction SilentlyContinue }catch{}
  }

  $ts=Get-Date -Format "yyyyMMdd_HHmmss"
  $out="$LOGS\backend_dev_$ts.out.log"
  $err="$LOGS\backend_dev_$ts.err.log"
  $cmd="cd /d ""$BACKEND"" && set NODE_ENV=test && set PORT=$PORT && npm run dev 1>> ""$out"" 2>> ""$err"""
  $p=Start-Process -FilePath "cmd.exe" -ArgumentList "/d","/c",$cmd -PassThru -WindowStyle Minimized
  Set-Content -Path $pidFile -Value $p.Id -Encoding ascii

  # D) /health gate
  $ok=$false
  for($i=0;$i -lt 120;$i++){
    try{
      $h=Invoke-WebRequest "$BASE/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
      if($h -and $h.StatusCode -eq 200){ $ok=$true; break }
    }catch{}
    Start-Sleep -Milliseconds 500
  }
  if(-not $ok){ Stop-With "STOP: /health not reachable. ERR_LOG=$err" }

  # E) Contract gate (no $pid variable; use $puzzleId)
  function Post([string]$path,[object]$obj){
    $json=$obj | ConvertTo-Json -Depth 10
    try{
      $r=Invoke-WebRequest -Method Post ($BASE+$path) -UseBasicParsing -TimeoutSec 10 -ContentType "application/json" -Body $json
      return @{ status=$r.StatusCode; body=$r.Content }
    }catch{
      $status=$null
      if($_.Exception.Response){ $status=[int]$_.Exception.Response.StatusCode }
      return @{ status=$status; body="" }
    }
  }
  function Get([string]$path){
    $r=Invoke-WebRequest ($BASE+$path) -UseBasicParsing -TimeoutSec 10
    return @{ status=$r.StatusCode; body=$r.Content }
  }

  $r0=Post "/__test__/reset" @{}
  if($r0.status -ne 204){ Stop-With "STOP: reset1 not 204" }

  $d=Get "/daily"
  if($d.status -ne 200){ Stop-With "STOP: /daily not 200" }

  $puzzleId=(ConvertFrom-Json $d.body).puzzles[0].id
  if(-not $puzzleId){ Stop-With "STOP: puzzleId missing" }

  $a1=Post "/daily/answer" @{ puzzleId=$puzzleId; answer="x" }
  if($a1.status -ne 200){ Stop-With "STOP: answer1 not 200" }

  $a2=Post "/daily/answer" @{ puzzleId=$puzzleId; answer="x" }
  if($a2.status -ne 409){ Stop-With "STOP: answer2 not 409" }

  $r1=Post "/__test__/reset" @{}
  if($r1.status -ne 204){ Stop-With "STOP: reset2 not 204" }

  $a3=Post "/daily/answer" @{ puzzleId=$puzzleId; answer="x" }
  if($a3.status -ne 200){ Stop-With "STOP: answer_after_reset not 200" }

  Write-Host "OK: ONE_BUTTON_GUARD passed" -ForegroundColor Green
  Write-Host ("PID_FILE="+$pidFile) -ForegroundColor Cyan
  Write-Host ("OUT_LOG="+$out) -ForegroundColor Cyan
  Write-Host ("ERR_LOG="+$err) -ForegroundColor Cyan
}
catch{
  Write-Host $_ -ForegroundColor Red
}
finally{
  Read-Host "Press ENTER to exit"
}
