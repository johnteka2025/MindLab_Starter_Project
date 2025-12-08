# ==============================
# MindLab — START OF DAY SCRIPT
# ==============================

Write-Host "=== MindLab START OF DAY ===" -ForegroundColor Cyan

# 1. Start backend
Write-Host "[1] Starting backend..." -ForegroundColor Yellow
cd C:\Projects\MindLab_Starter_Project
.\run_backend.ps1

# 2. Start frontend dev server
Write-Host "[2] Starting frontend..." -ForegroundColor Yellow
cd C:\Projects\MindLab_Starter_Project\frontend
npm install
npm run dev -- --port=5177

# 3. Full LOCAL check (backend + frontend + local tests)
Write-Host "[3] Running FULL LOCAL sanity..." -ForegroundColor Yellow
cd C:\Projects\MindLab_Starter_Project
.\run_all.ps1

# 4. Full PROD check (Render health + PROD test)
Write-Host "[4] Running FULL PROD sanity check..." -ForegroundColor Yellow
.\run_prod_full_check.ps1 -TraceOn

# 5. Optional quick PROD playwright only
Write-Host "[5] Running QUICK PROD browser check..." -ForegroundColor Yellow
.\run_prod_playwright_only.ps1

Write-Host "=== START OF DAY COMPLETE ===" -ForegroundColor Green
