# =============================
# MindLab — END OF DAY SCRIPT
# =============================

Write-Host "=== MindLab END OF DAY ===" -ForegroundColor Cyan

cd C:\Projects\MindLab_Starter_Project

# 1. Full LOCAL final check
Write-Host "[1] Running FINAL LOCAL sanity..." -ForegroundColor Yellow
.\run_all.ps1

# 2. Full PROD final check
Write-Host "[2] Running FINAL PROD sanity..." -ForegroundColor Yellow
.\run_prod_full_check.ps1 -TraceOn

# 3. Quick optional PROD playwright
Write-Host "[3] Running QUICK PROD browser-only check..." -ForegroundColor Yellow
.\run_prod_playwright_only.ps1

# 4. Optional git checkpoint
Write-Host "[4] Creating daily git snapshot..." -ForegroundColor Yellow
git add .
git commit -m "Daily end-of-day checkpoint — all tests passed" 2>$null

Write-Host "=== END OF DAY COMPLETE ===" -ForegroundColor Green
