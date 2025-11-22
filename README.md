# MindLab Starter Project

MindLab is a small full-stack app with:
- A Node/Express backend (port 8085)
- A Vite/React frontend served from /app
- Health and puzzles APIs
- Playwright end-to-end tests
- PowerShell smoke scripts
- Docker image and Docker-based smoke test
- GitHub Actions CI

---

## 1. Prerequisites

- Node.js (v18+ recommended)
- npm
- PowerShell
- Docker Desktop
- Git

---

## 2. Running the Backend

Open PowerShell and run:
  cd C:\Projects\MindLab_Starter_Project\backend
  npm install
  npm start

Backend routes:
- http://127.0.0.1:8085/
- http://127.0.0.1:8085/health
- http://127.0.0.1:8085/puzzles
- http://127.0.0.1:8085/app

---

## 3. Build & Serve Frontend (Production)

From PowerShell:
  cd C:\Projects\MindLab_Starter_Project\frontend
  npm install
  npm run build

Then copy the build into backend/static:
  cd C:\Projects\MindLab_Starter_Project
  Remove-Item -Recurse -Force backend\static\* -ErrorAction SilentlyContinue
  Copy-Item -Recurse -Force frontend\dist\* backend\static\

Make sure the backend is running with:
  cd C:\Projects\MindLab_Starter_Project\backend
  npm start

---

## 4. Run Playwright Tests

Backend MUST be running first.

In a new PowerShell window:
  cd C:\Projects\MindLab_Starter_Project\frontend
  npx playwright test --trace=on

---

## 5. Local Smoke Test (full_smoke.ps1)

This script:
- checks port 8085
- starts backend
- waits for /health
- runs Playwright tests
- stops backend

Run from project root:
  cd C:\Projects\MindLab_Starter_Project
  .\full_smoke.ps1

Expected: FULL SMOKE TEST PASSED ✅

---

## 6. Docker Smoke Test (docker_smoke.ps1)

This script:
- builds Docker image mindlab-fullapp:latest
- runs container on port 8085
- waits for /health
- runs Playwright tests
- stops and removes container

Run from project root:
  cd C:\Projects\MindLab_Starter_Project
  .\docker_smoke.ps1

Expected: DOCKER SMOKE TEST PASSED ✅

---

## 7. Basic Git Commands

From project root:
  cd C:\Projects\MindLab_Starter_Project
  git status
  git add .
  git commit -m "Your message here"
  git push origin master

---

## 8. GitHub Actions CI

Workflow file:
  .github\workflows\ci.yml

On each push to master, CI will:
- build frontend
- copy dist to backend/static
- start backend
- run Playwright tests
