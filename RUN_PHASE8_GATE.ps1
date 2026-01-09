param()

$ErrorActionPreference = "Stop"

Set-Location "C:\Projects\MindLab_Starter_Project"

Write-Host "GATE: repo clean check..." -ForegroundColor Cyan
$st = git status --porcelain
if ($st) { Write-Host $st; throw "Repo not clean. Stop." }

Write-Host "GATE: ignore rules check..." -ForegroundColor Cyan

# probes
New-Item -ItemType Directory -Force .\frontend\coverage | Out-Null
New-Item -ItemType File -Force .\frontend\coverage\__ignore_probe__.txt | Out-Null
New-Item -ItemType Directory -Force .\backend\coverage | Out-Null
New-Item -ItemType File -Force .\backend\coverage\__ignore_probe__.txt | Out-Null
New-Item -ItemType Directory -Force .\_quarantine | Out-Null
New-Item -ItemType File -Force .\_quarantine\__ignore_probe__.txt | Out-Null

$hit1 = git check-ignore -v .\frontend\coverage\__ignore_probe__.txt
$hit2 = git check-ignore -v .\backend\coverage\__ignore_probe__.txt
$hit3 = git check-ignore -v .\_quarantine\__ignore_probe__.txt

if (-not $hit1) { throw "frontend/coverage not ignored" }
if (-not $hit2) { throw "backend/coverage not ignored" }
if (-not $hit3) { throw "_quarantine not ignored" }

Remove-Item -Recurse -Force .\frontend\coverage, .\backend\coverage, .\_quarantine -ErrorAction SilentlyContinue

Write-Host "GATE: fullstack sanity..." -ForegroundColor Cyan
powershell -NoProfile -ExecutionPolicy Bypass -File ".\RUN_FULLSTACK_SANITY.ps1"

Write-Host "GATE PASS" -ForegroundColor Green
