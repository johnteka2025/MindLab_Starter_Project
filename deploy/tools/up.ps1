$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "== Bringing stack up ==" -ForegroundColor Cyan
docker compose -f .\prod\docker-compose.prod.yml --env-file .\prod\.env up -d --build

Write-Host "Waiting for DB to be healthy..."
$deadline = (Get-Date).AddMinutes(2)
do {
  $db = ""; try { $db = docker inspect -f "{{.State.Health.Status}}" mindlab-db } catch {}
  if ($db -eq "healthy") { break }
  Start-Sleep -Seconds 2
} until ((Get-Date) -gt $deadline)
if ($db -ne "healthy") { throw "Postgres did not become healthy (state: $db)" }

Write-Host "Waiting for API container to be ready..."
$deadline = (Get-Date).AddMinutes(2)
do {
  $api = ""; try { $api = docker inspect -f "{{.State.Health.Status}}" mindlab-api } catch {}
  if ($api -eq "healthy") { break }
  Start-Sleep -Seconds 2
} until ((Get-Date) -gt $deadline)

Write-Host "Verifying /api/health via http://localhost ..." -ForegroundColor Cyan
$ok = $false
$deadline = (Get-Date).AddMinutes(1)
do {
  try {
    $r = Invoke-RestMethod "http://localhost/api/health" -TimeoutSec 3
    if ($r -and $r.ok -eq $true) { $ok = $true; break }
  } catch {}
  Start-Sleep -Seconds 2
} until ((Get-Date) -gt $deadline)
if (-not $ok) { throw "Front-door /api/health did not return { ok: true } in time" }

Write-Host "Stack is up and healthy." -ForegroundColor Green
