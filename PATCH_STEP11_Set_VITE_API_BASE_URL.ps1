# PATCH_STEP11_Set_VITE_API_BASE_URL.ps1
# Purpose: Ensure frontend\.env.local contains VITE_API_BASE_URL=http://localhost:8085
# Golden Rules: backup-first, minimal change, deterministic result

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail([string]$msg) { Write-Host ('ERROR: ' + $msg) -ForegroundColor Red; exit 1 }
function Ok([string]$msg) { Write-Host ('OK: ' + $msg) -ForegroundColor Green }

$FILE = 'C:\Projects\MindLab_Starter_Project\frontend\.env.local'
if (-not (Test-Path $FILE)) { Fail ('.env.local not found: ' + $FILE) }

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$bak = $FILE + '.bak_' + $ts
Copy-Item $FILE $bak -Force
Ok ('Backup created: ' + $bak)

$lines = Get-Content $FILE -ErrorAction Stop

$target = 'VITE_API_BASE_URL=http://localhost:8085'
$found = $false

for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*VITE_API_BASE_URL\s*=') {
    $lines[$i] = $target
    $found = $true
  }
}

if (-not $found) {
  if ($lines.Count -gt 0 -and $lines[$lines.Count-1].Trim().Length -ne 0) { $lines += '' }
  $lines += $target
  Ok 'Added VITE_API_BASE_URL to .env.local'
} else {
  Ok 'Updated existing VITE_API_BASE_URL in .env.local'
}

Set-Content $FILE ($lines -join "`r`n") -Encoding UTF8
Ok 'Patch completed successfully.'
