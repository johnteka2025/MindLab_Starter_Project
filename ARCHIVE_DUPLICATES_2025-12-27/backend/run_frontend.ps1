param(
  [string]$ApiBase = "http://127.0.0.1:8085",
  [int]$Port = 5177
)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\frontend"

"VITE_API_BASE=$ApiBase" | Set-Content .\.env.local -Encoding utf8

# Install deps
if ((Test-Path "package-lock.json") -or (Test-Path "npm-shrinkwrap.json")) { npm ci } else { npm i }

# Unstick esbuild if needed, then (re)start vite
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse .\node_modules\esbuild -ErrorAction SilentlyContinue
npm rebuild esbuild | Out-Null

npm run dev -- --port $Port --strictPort
