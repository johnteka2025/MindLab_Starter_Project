[CmdletBinding()] param(
  [string]$Project="mindlab",
  [string]$BackendService="backend",
  [string]$HealthUrl="http://localhost:8085/api/health",
  [int]$WaitSeconds=150
)
. "$PSScriptRoot\_common.ps1"
Info "[BACKEND] Start '$BackendService'"

# Gate: config must pass
Ensure-Compose-Config -Project $Project

# Up the service
$cmp = Get-ComposeCmd; $common = Resolve-ComposeArgs -Project $Project
& $cmp.Exe @($cmp.Args + $common + @("up","-d",$BackendService))
if ($LASTEXITCODE -ne 0) { Err "compose up failed."; exit 10 }

# Wait for health
$deadline = (Get-Date).AddSeconds($WaitSeconds); $ok=$false
do {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Uri $HealthUrl -TimeoutSec 5
    if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) { $ok=$true; break }
  } catch {}
  Start-Sleep 2
  Write-Host "[BACKEND] Waiting for $HealthUrl ..." -ForegroundColor DarkYellow
} while ((Get-Date) -lt $deadline)

if (-not $ok) {
  Err "Backend not healthy within $WaitSeconds sec."
  Warn "Last 120 lines of backend logs:"
  & $cmp.Exe @($cmp.Args + $common + @("logs","--no-color",$BackendService,"--tail=120")) | Out-Host
  exit 11
}
Ok "[BACKEND] Healthy at $HealthUrl"
