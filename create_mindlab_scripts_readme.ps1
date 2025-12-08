# create_mindlab_scripts_readme.ps1
# Generates README_MindLab_Scripts.md documenting all core .ps1 scripts.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
Set-Location $root

Write-Host "=== Generating README_MindLab_Scripts.md ===" -ForegroundColor Cyan
Write-Host "[INFO] Project root: $root" -ForegroundColor DarkCyan

$readmePath = Join-Path $root "README_MindLab_Scripts.md"

$md = @"
# MindLab PowerShell Scripts Overview

Project root: \`C:\\Projects\\MindLab_Starter_Project\`

This document explains the **core PowerShell scripts** that live in the project root
and how to use them in your daily workflow.

---

## 1. Daily Workflow Scripts

### 1.1 \`run_mindlab_daily_routine.ps1\` (MORNING)

**Purpose:**  
Runs the full **morning start sequence** to make sure the project is healthy before
you start new work.

**Actions:**
- Runs \`backup_mindlab_snapshot.ps1\` if present (full snapshot backup).
- Runs \`run_quick_daily_stack.ps1\` (backend + daily + UI tests).
- Runs \`run_route_sanity.ps1\` (checks key backend routes).
- Runs \`curl_dev_daily_auto.ps1\` (auto-detects dev port and curls /app and /app/daily).

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_mindlab_daily_routine.ps1
\`\`\`

---

### 1.2 \`run_mindlab_evening_wrap.ps1\` (EVENING)

**Purpose:**  
Runs the **end-of-day checks** and a final snapshot before you close for the day.

**Actions:**
- Runs \`run_quick_daily_stack.ps1\` (final backend + UI sanity).
- Runs \`run_all.ps1\` if present (optional broader sanity).
- Runs \`backup_mindlab_snapshot.ps1\` (final snapshot).

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_mindlab_evening_wrap.ps1
\`\`\`

---

## 2. Health & Sanity Scripts

### 2.1 \`run_quick_daily_stack.ps1\`

**Purpose:**  
Master health check for the project. Runs fast checks for backend, frontend,
and daily UI tests.

**Typical actions (depending on how it was set up):**
- Backend health endpoint checks.
- Core API route checks.
- Key Playwright test suite for /app and possibly /app/daily.

**How to run directly:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_quick_daily_stack.ps1
\`\`\`

---

### 2.2 \`run_route_sanity.ps1\`

**Purpose:**  
Verifies that key backend routes are up (for example: \`/health\`, \`/puzzles\`,
\`/progress\`, \`/app\`, and \`/daily\`).

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_route_sanity.ps1
\`\`\`

---

### 2.3 \`curl_dev_daily_auto.ps1\`

**Purpose:**  
Checks which Vite dev port is active (from 5177 to 5181) and then curls
\`/app\` and/or \`/app/daily\` to confirm the dev frontend is responding.

**Typical use:**
- After you start the dev server, you can use this to confirm which port is live.

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\curl_dev_daily_auto.ps1
\`\`\`

---

## 3. Backend & Frontend Dev Servers

### 3.1 \`run_backend_dev.ps1\`

**Purpose:**  
Starts the backend server on **port 8085** with the proper environment variables
(for example, \`PUBLIC_BASE_URL=/app/\`).

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_backend_dev.ps1
\`\`\`

Run this in its own PowerShell window and leave it running while you work.

---

### 3.2 \`run_frontend_dev_daily.ps1\`

**Purpose:**  
Starts the Vite dev server for the frontend, typically on **port 5177** with \`/app\`
as the base path. Used when working on /app and /app/daily in dev mode.

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_frontend_dev_daily.ps1
\`\`\`

Run this in a separate window from the backend dev script.

---

## 4. Backup and Meta Scripts

### 4.1 \`backup_mindlab_snapshot.ps1\`

**Purpose:**  
Creates a timestamped **snapshot backup** of key project files into a folder under
\`backups\\\`. Often also compresses into a .zip for safekeeping.

**When to run:**
- Automatically as part of morning and evening routines.
- Manually before risky changes.

**How to run manually:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\backup_mindlab_snapshot.ps1
\`\`\`

---

### 4.2 \`setup_mindlab_daily_suite.ps1\`

**Purpose:**  
One-time (or occasional) generator script that creates or updates:
- \`run_mindlab_daily_routine.ps1\`
- \`run_mindlab_evening_wrap.ps1\`

You normally **do not need** to run this every day — only when we decide to
change how the daily routines behave.

**How to run (only when needed):**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\setup_mindlab_daily_suite.ps1
\`\`\`

---

### 4.3 \`run_project_inventory.ps1\`

**Purpose:**  
Generates a **complete inventory** of all files in the project and saves it under
\`meta\\MindLab_File_Inventory_YYYY-MM-DD_HHMMSS.txt\`. Also optionally calls
\`backup_mindlab_snapshot.ps1\`.

Use this when you are cleaning the project or want a full snapshot of the
filesystem for reference.

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\run_project_inventory.ps1
\`\`\`

---

### 4.4 \`organize_ps1_scripts.ps1\`

**Purpose:**  
Cleans up the project root by moving non-core \`.ps1\` scripts into an archive
folder under \`meta\\ps1_archive_YYYY-MM-DD_HHMMSS\\\`.  
Keeps only the core scripts listed in this README in the root.

**How to run:**
\`\`\`powershell
Set-Location 'C:\\Projects\\MindLab_Starter_Project'
.\organize_ps1_scripts.ps1
\`\`\`

---

## 5. Recommended Daily Usage

### Morning

1. Open **Admin PowerShell**.
2. Run:
   \`\`\`powershell
   Set-Location 'C:\\Projects\\MindLab_Starter_Project'
   .\run_mindlab_daily_routine.ps1
   \`\`\`
3. Fix any red errors before starting new development.

### During the day

- Use:
  - \`run_backend_dev.ps1\` (backend window)
  - \`run_frontend_dev_daily.ps1\` (frontend window)
- Use \`curl_dev_daily_auto.ps1\` if you’re not sure which dev port is live.

### Evening

1. Finish your work.
2. Run:
   \`\`\`powershell
   Set-Location 'C:\\Projects\\MindLab_Starter_Project'
   .\run_mindlab_evening_wrap.ps1
   \`\`\`
3. Then close your dev windows.

---

This README is meant as your **map of the PowerShell world** inside MindLab so
that future working sessions are calm, predictable, and stable.
"@

$md | Set-Content -Path $readmePath -Encoding UTF8

$info = Get-Item $readmePath
Write-Host "[OK] README_MindLab_Scripts.md written." -ForegroundColor Green
Write-Host "     Path: $($info.FullName)" -ForegroundColor Green
Write-Host "     Size: $($info.Length) bytes" -ForegroundColor Green

Write-Host "=== Done. You can open it with: notepad README_MindLab_Scripts.md ===" -ForegroundColor Cyan
