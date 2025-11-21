[CmdletBinding()] param(
  [string]$Project="mindlab",
  [string]$ApiBase="http://localhost:8085",
  [string]$WebBase="http://localhost:5177"
)
. "$PSScriptRoot\_common.ps1"
Info "[SANITY] Begin"

# Required scripts present
$required = @("ops\0_reset.ps1","ops\1_sanity.ps1","ops\2_start-backend.ps1","ops\4_test-core.ps1","ops\5_test-contract.ps1")
$missing = $required | Where-Object { -not (Test-Path (Join-Path $script:ROOT $_)) }
if ($missing) { Err ("Missing scripts:`n  " + ($missing -join "`n  ")); exit 2 }
Ok "Required scripts present."

# Docker reachable
try { docker info *> $null; Ok "Docker daemon reachable." } catch { Err "Docker daemon NOT reachable. Start Docker Desktop."; exit 3 }

# Compose config gate
try { Ensure-Compose-Config -Project $Project } catch { exit 4 }

# Ports (just informative)
Warn "Port 8085 should be FREE before start." 
Warn "Port 5177 should be FREE before start." 
Ok "[SANITY] Complete"
