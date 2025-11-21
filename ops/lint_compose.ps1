[CmdletBinding()]
param([string]$Project = "mindlab")

$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
$ROOT = "C:\Projects\MindLab_Starter_Project"; Set-Location $ROOT
New-Item -ItemType Directory -Force -Path ".\tests\.artifacts" | Out-Null

# 1) locate compose file
$composeCandidates = @("docker-compose.yml","docker-compose.yaml","compose.yml","compose.yaml")
$composePath = $composeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $composePath) { Write-Host "[ERROR] No compose file found in $ROOT" -ForegroundColor Red; exit 2 }
Write-Host "[INFO] Using compose file: $composePath" -ForegroundColor Cyan

$src   = Get-Content -Raw $composePath
$lines = $src -split "`r?`n"
$issues = @()
function Add-Issue([string]$Rule,[string]$Line,[int]$Num,[string]$Fix){
  $issues += [pscustomobject]@{ Rule=$Rule; LineNo=$Num; Line=$Line.TrimEnd(); SuggestedFix=$Fix }
}

for ($i=0; $i -lt $lines.Count; $i++) {
  $ln = $lines[$i]

  # A) URL-like values missing scheme, e.g. API_BASE: host:8085
  if ($ln -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*[:=]\s*([A-Za-z0-9\.\-]+):(\d+)\s*$') {
    $k = $matches[1]; $hname=$matches[2]; $port=$matches[3]
    if ($k -match '(API|BASE|URL|SERVER|ENDPOINT)') {
      $fix = ("Change to: {0}: http://{1}:{2}" -f $k,$hname,$port)
      Add-Issue "URL missing scheme" $ln ($i+1) $fix
    }
  }

  # B) //host:port
  if ($ln -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*[:=]\s*//([A-Za-z0-9\.\-]+):(\d+)\s*$') {
    $k = $matches[1]; $hname=$matches[2]; $port=$matches[3]
    $fix = ("Change to: {0}: http://{1}:{2}" -f $k,$hname,$port)
    Add-Issue "URL begins with // (no proto)" $ln ($i+1) $fix
  }

  # C) ports with spaces around colon
  if ($ln -match '^\s*-\s*\d+\s*:\s*\d+\s*$') {
    Add-Issue "ports mapping has spaces" $ln ($i+1) 'Use quotes: - "8085:8080"'
  }

  # D) Windows path volumes
  if ($ln -match '^\s*-\s*([A-Za-z]):\\([^:]+):') {
    $drive = $matches[1].ToLower(); $rest = ($matches[2] -replace '\\','/')
    $fix = ("Use: - /{0}/{1}:/app   (adjust right side as needed)" -f $drive,$rest)
    Add-Issue "Windows path in volume" $ln ($i+1) $fix
  }
}

# 2) sanitized content
$san = $src
$san = [regex]::Replace($san,
  '(^\s*([A-Za-z_][A-Za-z0-9_]*)\s*[:=]\s*)//([A-Za-z0-9\.\-]+):(\d+)\s*$',
  { param($m) ($m.Groups[1].Value + 'http://' + $m.Groups[3].Value + ':' + $m.Groups[4].Value) },
  'Multiline')

$san = [regex]::Replace($san,
  '(^\s*((?:API|BASE|URL|SERVER|ENDPOINT)[A-Za-z0-9_]*)\s*[:=]\s*)([A-Za-z0-9\.\-]+):(\d+)\s*$',
  { param($m) ($m.Groups[1].Value + 'http://' + $m.Groups[3].Value + ':' + $m.Groups[4].Value) },
  'Multiline')

$san = [regex]::Replace($san,
  '(^\s*-\s*)(\d+)\s*:\s*(\d+)\s*$',
  { param($m) ($m.Groups[1].Value + '"' + $m.Groups[2].Value + ':' + $m.Groups[3].Value + '"') },
  'Multiline')

$san = [regex]::Replace($san,
  '(^\s*-\s*)([A-Za-z]):\\([^:]+):',
  { param($m)
      $lhs = '/' + $m.Groups[2].Value.ToLower() + '/' + ($m.Groups[3].Value -replace '\\','/')
      $m.Groups[1].Value + $lhs + ':'
  }, 'Multiline')

# 3) outputs
$report = ".\tests\.artifacts\compose_lint_report.txt"
$sanPath = ".\compose.sanitized.yml"
if ($issues.Count -gt 0) {
  ($issues | Format-Table -AutoSize | Out-String) | Set-Content -Path $report -Encoding UTF8
  Write-Host "[REPORT] $report" -ForegroundColor Green
}
Set-Content -Path $sanPath -Value $san -Encoding UTF8
Write-Host "[WROTE] $sanPath" -ForegroundColor Green

# 4) validate sanitized compose
function Get-ComposeCmd {
  if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker compose version *> $null
    if ($LASTEXITCODE -eq 0) { return @{Exe="docker"; Args=@("compose")} }
  }
  if (Get-Command docker-compose -ErrorAction SilentlyContinue) { return @{Exe="docker-compose"; Args=@()} }
  throw "Docker Compose not found. Install/start Docker Desktop."
}
$cmp = Get-ComposeCmd

Write-Host "[CHECK] docker compose -f compose.sanitized.yml config -q" -ForegroundColor Cyan
& $cmp.Exe @($cmp.Args + @("-f",$sanPath,"-p",$Project,"config","-q")) *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "[FAIL] Sanitized compose still fails. Open $sanPath and $report." -ForegroundColor Red
  exit 11
}
Write-Host "[PASS] Sanitized compose parses." -ForegroundColor Green
