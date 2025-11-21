[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$BaseUrl,
  [string[]]$Paths=@("/api/health","/health","/healthz","/api/ping","/"),
  [int]$TimeoutSec=8,
  [int]$WarmupSec=30
)
function Fail([string]$m){ throw "STOP: $m" }
function Ok([string]$m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

# Warm-up on health endpoints first
$healthFirst = @("/api/health","/health","/healthz")
$deadline = (Get-Date).AddSeconds($WarmupSec)
$ready = $false; $used = $null
while((Get-Date) -lt $deadline -and -not $ready){
  foreach($p in $healthFirst){
    try{
      $u = "$BaseUrl$p"
      $r = Invoke-WebRequest -UseBasicParsing -Method GET -Uri $u -TimeoutSec $TimeoutSec
      if($r.StatusCode -ge 200 -and $r.StatusCode -lt 300){ $ready=$true; $used=$p; break }
    }catch{ Start-Sleep -Milliseconds 400 }
  }
  if(-not $ready){ Start-Sleep -Seconds 1 }
}
if(-not $ready){ Fail "API warm-up failed: none of $($healthFirst -join ', ') responded under $WarmupSec s. Try: docker logs -n 200 mindlab-api" }
Ok "Warm-up OK via $used"

# Compact tests
$any=$false
foreach($p in $Paths){
  $u="$BaseUrl$p"
  try{
    $r=Invoke-WebRequest -UseBasicParsing -Method GET -Uri $u -TimeoutSec $TimeoutSec
    if($r.StatusCode -ge 200 -and $r.StatusCode -lt 300){
      Ok ("GET {0} -> {1}" -f $p,$r.StatusCode); $any=$true
    } else {
      Warn ("GET {0} -> {1}" -f $p,$r.StatusCode)
    }
  }catch{
    Warn ("GET {0} failed: {1}" -f $p,$_.Exception.Message)
  }
}
if(-not $any){ Fail "No test endpoint succeeded. Check: docker logs -f mindlab-api" }
Ok "API tests passed."
