# RUN_FULLSTACK_SANITY.ps1


# Full-stack must-pass sanity checks for MindLab (Golden Rules compliant).


Set-StrictMode -Version Latest


$ErrorActionPreference = "Stop"





function Fail([string]$msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; exit 1 }


function Ok([string]$msg)   { Write-Host "OK: $msg" -ForegroundColor Green }





$ROOT     = "C:\Projects\MindLab_Starter_Project"


$FRONTEND = Join-Path $ROOT "frontend"


$BACKEND  = Join-Path $ROOT "backend"





# --- Paths (must exist)


if (-not (Test-Path $ROOT))     { Fail "Project root missing: $ROOT" }


if (-not (Test-Path $FRONTEND)) { Fail "Frontend missing: $FRONTEND" }


if (-not (Test-Path $BACKEND))  { Fail "Backend missing: $BACKEND" }


Ok "Canonical paths exist."





# --- Critical files (must exist)


$critical = @(


  (Join-Path $FRONTEND ".env.local"),


  (Join-Path $FRONTEND "src\api.ts"),


  (Join-Path $FRONTEND "src\daily-challenge\DailyChallengeDetailPage.tsx"),


  (Join-Path $FRONTEND "src\pages\SolvePuzzle.tsx"),


  (Join-Path $BACKEND  "src\server.cjs"),


  (Join-Path $BACKEND  "src\data\progress.json"),


  (Join-Path $ROOT     "RUN_BACKEND_SANITY.ps1")


)





foreach ($p in $critical) {


  if (-not (Test-Path $p)) { Fail "Missing critical file: $p" }


}


Ok "Critical files exist."





# --- Backend sanity (must-pass)


Ok "Running backend sanity..."


& powershell -ExecutionPolicy Bypass -File (Join-Path $ROOT "RUN_BACKEND_SANITY.ps1")


if ($LASTEXITCODE -ne 0) { Fail "Backend sanity failed (exit code $LASTEXITCODE)." }


Ok "Backend sanity passed."





# --- Frontend env quick check (must contain API base)


$envPath = Join-Path $FRONTEND ".env.local"


$envText = Get-Content $envPath -Raw


if ($envText -notmatch 'VITE_API_BASE_URL\s*=\s*http:\/\/localhost:8085') {


  Fail "frontend\.env.local missing/incorrect VITE_API_BASE_URL=http://localhost:8085"


}


Ok "frontend\.env.local contains VITE_API_BASE_URL=http://localhost:8085"





# --- Optional: check if frontend dev server responds (best-effort; does not start it)


try {


  $r = Invoke-WebRequest -UseBasicParsing "http://localhost:5177/" -TimeoutSec 2


  Ok "Frontend dev server responded on http://localhost:5177/ (Status $($r.StatusCode))."


} catch {


  Write-Host "WARN: Frontend dev server not reachable on http://localhost:5177/ (this is OK if it's not running)." -ForegroundColor Yellow


}






# ------------------------------
# PHASE 5 CHECKS (difficulty filtering)
# ------------------------------
try {
  # Use existing backendUrl if the script defines it; else default
  if (-not (Get-Variable -Name backendUrl -ErrorAction SilentlyContinue)) {
    $backendUrl = 'http://localhost:8085'
  }

  function Get-HttpStatus([string]$url) {
    try {
      $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 10
      return [int]$r.StatusCode
    } catch {
      $resp = $_.Exception.Response
      if($resp -and $resp.StatusCode) {
        return [int]$resp.StatusCode.value__
      }
      throw
    }
  }

  $s = Get-HttpStatus ($backendUrl + '/difficulty')
  if($s -ne 200){ throw ('STOP: /difficulty expected 200 but got ' + $s) }
  Write-Host 'OK: /difficulty -> 200'

  foreach($d in @('easy','medium','hard')){
    $s2 = Get-HttpStatus ($backendUrl + '/puzzles?difficulty=' + $d)
    if($s2 -ne 200){ throw ('STOP: /puzzles?difficulty=' + $d + ' expected 200 but got ' + $s2) }
  }
  Write-Host 'OK: /puzzles?difficulty=easy|medium|hard -> 200'

  $sBad = Get-HttpStatus ($backendUrl + '/puzzles?difficulty=INVALID')
  if($sBad -ne 400){ throw ('STOP: /puzzles?difficulty=INVALID expected 400 but got ' + $sBad) }
  Write-Host 'OK: /puzzles?difficulty=INVALID -> 400 (expected)'
} catch {
  throw
}

Ok "Full-stack sanity completed."


exit 0


