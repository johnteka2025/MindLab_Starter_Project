$ErrorActionPreference = "Stop"

function Fail($msg) {
  Write-Host "[FAIL] $msg" -ForegroundColor Red
  exit 1
}

function Ok($msg) {
  Write-Host "[OK] $msg" -ForegroundColor Green
}

Write-Host "=== MindLab Phase 2.0 — Invariants Check (API) ===" -ForegroundColor Cyan

$backend = "http://localhost:8085"

# 0) Health
try {
  $h = Invoke-RestMethod "$backend/health" -TimeoutSec 3
  Ok "Backend /health reachable."
} catch {
  Fail "Backend /health not reachable. Start backend first. Error: $($_.Exception.Message)"
}

# 1) GET /progress (before)
try {
  $before = Invoke-RestMethod "$backend/progress" -TimeoutSec 3
  Ok "GET /progress (before) returned JSON."
} catch {
  Fail "GET /progress failed. Error: $($_.Exception.Message)"
}

if ($null -eq $before.total -or $null -eq $before.solved) { Fail "GET /progress missing total/solved fields." }
if (-not ($before.total -is [int] -or $before.total -is [long] -or $before.total -is [double])) { Fail "progress.total is not numeric." }
if (-not ($before.solved -is [int] -or $before.solved -is [long] -or $before.solved -is [double])) { Fail "progress.solved is not numeric." }

if ($before.total -lt 0) { Fail "progress.total < 0" }
if ($before.solved -lt 0) { Fail "progress.solved < 0" }
if ($before.solved -gt $before.total) { Fail "progress.solved > progress.total" }

Write-Host "Before: total=$($before.total) solved=$($before.solved)" -ForegroundColor Gray

# 2) POST /progress/solve
$body = @{ puzzleId = 1 } | ConvertTo-Json
try {
  $solve = Invoke-RestMethod "$backend/progress/solve" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 3
  Ok "POST /progress/solve returned JSON."
} catch {
  Fail "POST /progress/solve failed. Error: $($_.Exception.Message)"
}

# 3) GET /progress (after)
try {
  $after = Invoke-RestMethod "$backend/progress" -TimeoutSec 3
  Ok "GET /progress (after) returned JSON."
} catch {
  Fail "GET /progress (after) failed. Error: $($_.Exception.Message)"
}

if ($after.solved -lt $before.solved) { Fail "Solved went backwards: before=$($before.solved) after=$($after.solved)" }
if ($after.solved -gt $after.total) { Fail "After: solved > total" }

Write-Host "After : total=$($after.total) solved=$($after.solved)" -ForegroundColor Gray
Ok "Invariants check PASSED."
