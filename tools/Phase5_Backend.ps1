<# Phase5_Backend.ps1
   Backend polish:
   - CORS (simple dev policy)
   - JWT check helper returns clear 401 (no token / bad token / expired)
   - Global error handler => {error:"server"}
   - Health check + start if needed
#>

param(
  [int]$ApiPort = 8085
)

$ErrorActionPreference = 'Stop'
function Say  ($m,$c='Cyan'){ Write-Host $m -ForegroundColor $c }
function Ok   ($m){ Write-Host $m -ForegroundColor Green }
function Warn ($m){ Write-Warning $m }
function Fail ($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root  = Split-Path -Parent $here
$Back  = Join-Path $Root 'backend'
if (-not (Test-Path $Back)) { Fail "Backend folder not found at $Back" }

$Srv = Join-Path $Back 'src\server.js'
if (-not (Test-Path $Srv)) { Fail "server.js not found at $Srv" }

Say "Project root : $Root" 'DarkGray'
Say "Backend path : $Back" 'DarkGray'

# --- Ensure safety helpers file (imported by server.js) ---
$uxPath = Join-Path $Back 'src\uxhelpers.js'
@'
import cors from "cors";
import jwt from "jsonwebtoken";

export function devCors(){
  return cors({
    origin: true,
    credentials: true,
    methods: ["GET","POST","OPTIONS"],
    allowedHeaders: ["Content-Type","Authorization"]
  });
}

export function mustAuth(jwtSecret){
  return (req,res,next)=>{
    const hdr = req.headers["authorization"] || "";
    const tok = hdr.startsWith("Bearer ") ? hdr.slice(7) : "";
    if(!tok) return res.status(401).json({error:"no token"});
    try{
      req.user = jwt.verify(tok, jwtSecret);
      return next();
    }catch(e){
      if(e?.name === "TokenExpiredError") return res.status(401).json({error:"expired"});
      return res.status(401).json({error:"bad token"});
    }
  };
}

export function globalError(){
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  return (err, req, res, next)=>{
    console.error("[server error]", err?.message || err);
    if (res.headersSent) return;
    res.status(500).json({error:"server"});
  };
}
'@ | Set-Content -Encoding UTF8 $uxPath
Ok "Wrote $uxPath"

# --- Patch server.js to use helpers if not already present ---
$code = Get-Content $Srv -Raw

if ($code -notmatch "from './uxhelpers.js'") {
  $code = "import { devCors, globalError } from './uxhelpers.js';`r`n" + $code
}
# Add dev CORS once near app creation
if ($code -notmatch "app.use\\(devCors\\(\\)\\)") {
  $code = $code -replace "(const app = express\\(\\);)","`$1`r`napp.use(devCors());"
}
# Add global error handler at end if missing
if ($code -notmatch "globalError\\(\\)") {
  if ($code -match "app\\.listen\\([^)]*\\);") {
    $code = $code -replace "(app\\.listen\\([^)]*\\);)","app.use(globalError());`r`n`$1"
  } else {
    $code += "`r`napp.use(globalError());"
  }
}

Set-Content -Encoding UTF8 $Srv $code
Ok "Patched $Srv (CORS + error handler)"

# --- Start backend if not listening and health check ---
$listen = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ? LocalPort -eq $ApiPort
if (-not $listen) {
  Say "Starting backend: npm run dev (:$ApiPort) ..." Yellow
  Start-Process -FilePath "npm" -ArgumentList "run","dev" -WorkingDirectory $Back
  Start-Sleep -Seconds 3
} else {
  Say "Backend already listening on :$ApiPort" 'DarkGray'
}

$deadline=(Get-Date).AddSeconds(60); $ok=$false; $last=$null
while(-not $ok -and (Get-Date) -lt $deadline){
  try{
    $last = Invoke-RestMethod "http://127.0.0.1:$ApiPort/health" -TimeoutSec 3
    if($last.ok -and $last.db){ $ok=$true; break }
  }catch{ $last=$_.Exception.Message }
  Start-Sleep -Seconds 1
}
if($ok){
  Ok "Backend healthy on :$ApiPort -> { ok=$($last.ok), db=$($last.db) }"
}else{
  Fail "Backend NOT healthy on :$ApiPort. Last: $last"
}

