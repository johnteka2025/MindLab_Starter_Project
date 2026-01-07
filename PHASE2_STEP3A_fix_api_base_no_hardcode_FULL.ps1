# PHASE2_STEP3A_fix_api_base_require_env_FULL.ps1
# Goal:
# - Remove any hardcoded fallback like "http://127.0.0.1:8085" from frontend\src\api.ts
# - Require VITE_API_BASE_URL at runtime with a dev-friendly error
# - Backup before changes
# - Return to project root (Golden Rule)
# - Write UTF8 NO BOM to avoid quote/encoding weirdness

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section($msg) {
  Write-Host ""
  Write-Host "============================================================" -ForegroundColor DarkGray
  Write-Host $msg -ForegroundColor Cyan
  Write-Host "============================================================" -ForegroundColor DarkGray
}

function Ensure-Dir($p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
}

# --- Root (Golden Rule: run from project root) ---
$ROOT = (Resolve-Path (Join-Path $PSScriptRoot ".")).Path
Set-Location $ROOT

Write-Section "PHASE 2 - STEP 3A: Require VITE_API_BASE_URL (no hardcoded fallback) in frontend\src\api.ts"
Write-Host ("Root: " + (Get-Location)) -ForegroundColor Gray

$apiPath = Join-Path $ROOT "frontend\src\api.ts"
if (-not (Test-Path $apiPath)) {
  throw "Missing required file: $apiPath"
}

# --- Backup ---
$backupDir = Join-Path $ROOT "backups\phase2_step3A_api_ts"
Ensure-Dir $backupDir

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = Join-Path $backupDir ("api.ts.bak_" + $ts)
Copy-Item -Force $apiPath $backupPath

Write-Host ("Backed up: " + $backupPath) -ForegroundColor Green

# --- New api.ts content (FULL FILE REWRITE) ---
# IMPORTANT: single-quoted here-string so PowerShell does NOT expand ${} or interpret quotes.
$content = @'
/**
 * frontend/src/api.ts
 *
 * Single source of truth for backend base URL and API calls.
 *
 * Policy: NO hardcoded backend URL in source code.
 * Requirement: set VITE_API_BASE_URL at runtime (frontend/.env.local for local dev).
 *
 * Example (frontend/.env.local):
 *   VITE_API_BASE_URL=http://127.0.0.1:8085
 */

export type ApiOptions = {
  signal?: AbortSignal;
  headers?: Record<string, string>;
};

function readEnvBase(): string {
  const env = (import.meta as any)?.env ?? {};
  const raw = (env.VITE_API_BASE_URL ?? "").toString().trim();

  if (!raw) {
    // Dev-friendly, explicit message
    throw new Error(
      "Missing VITE_API_BASE_URL. Create frontend/.env.local with VITE_API_BASE_URL=http://127.0.0.1:8085 and restart `npm run dev`."
    );
  }

  // Normalize: remove trailing slash
  return raw.endsWith("/") ? raw.slice(0, -1) : raw;
}

export const API_BASE: string = readEnvBase();

export async function apiGet<T>(path: string, opts?: ApiOptions): Promise<T> {
  const url = path.startsWith("http") ? path : `${API_BASE}${path.startsWith("/") ? "" : "/"}${path}`;
  const res = await fetch(url, {
    method: "GET",
    signal: opts?.signal,
    headers: {
      ...(opts?.headers ?? {}),
    },
  });
  if (!res.ok) throw new Error(`GET ${path} failed: ${res.status}`);
  return (await res.json()) as T;
}

export async function apiPostJson<T>(path: string, body: any, opts?: ApiOptions): Promise<T> {
  const url = path.startsWith("http") ? path : `${API_BASE}${path.startsWith("/") ? "" : "/"}${path}`;
  const res = await fetch(url, {
    method: "POST",
    signal: opts?.signal,
    headers: {
      "Content-Type": "application/json",
      ...(opts?.headers ?? {}),
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`POST ${path} failed: ${res.status}`);
  return (await res.json()) as T;
}

/* Convenience types/functions used by the UI (keep stable exports) */
export type HealthResponse = { ok: boolean; status: string; message?: string };
export type Puzzle = { id: number | string; question: string; options?: string[]; correctIndex?: number };
export type Progress = { total: number; solved: number };

export function getHealth(opts?: ApiOptions) {
  return apiGet<HealthResponse>("/health", opts);
}

export function getPuzzles(opts?: ApiOptions) {
  return apiGet<Puzzle[]>("/puzzles", opts);
}

export function getProgress(opts?: ApiOptions) {
  return apiGet<Progress>("/progress", opts);
}

export function solvePuzzle(puzzleId: number | string, opts?: ApiOptions) {
  return apiPostJson<{ ok: boolean } | any>("/progress/solve", { puzzleId }, opts);
}
'@

# --- Write UTF8 NO BOM ---
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($apiPath, $content, $utf8NoBom)
Write-Host ("WROTE: " + $apiPath) -ForegroundColor Green

# --- Ensure frontend/.env.local exists (template) ---
$envLocal = Join-Path $ROOT "frontend\.env.local"
if (-not (Test-Path $envLocal)) {
  $envTemplate = @'
# Local dev only (do not commit secrets)
VITE_API_BASE_URL=http://127.0.0.1:8085
'@
  [System.IO.File]::WriteAllText($envLocal, $envTemplate, $utf8NoBom)
  Write-Host ("CREATED: " + $envLocal) -ForegroundColor Yellow
  Write-Host "NOTE: Restart `npm run dev` so Vite picks up the env file." -ForegroundColor Yellow
} else {
  Write-Host ("OK: exists: " + $envLocal) -ForegroundColor Green
}

# --- Golden Rule: return to root ---
Set-Location $ROOT
Write-Host ("Returned to: " + (Get-Location)) -ForegroundColor Green
Write-Host "STEP 3A COMPLETE." -ForegroundColor Green
