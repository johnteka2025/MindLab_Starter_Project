# C:\Projects\MindLab_Starter_Project\PATCH_09A_fix_puzzle_text_encoding_SAFE.ps1
# Fix: Replace common mojibake sequences in backend puzzle JSON files.
# Golden Rules: absolute paths, backups, sanity checks, always return to project root.

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$backendSrc  = Join-Path $projectRoot "backend\src"

$targets = @(
  (Join-Path $backendSrc "puzzles\index.json"),
  (Join-Path $backendSrc "puzzles.json"),
  (Join-Path $backendSrc "puzzles\legacy\puzzles.json")
)

function Backup-And-Clean {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath
  )

  if (-not (Test-Path $FilePath)) {
    Write-Host "Skip (not found): $FilePath" -ForegroundColor Yellow
    return
  }

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = "$FilePath.bak_encodingfix_$ts"
  Copy-Item $FilePath $bak -Force
  Write-Host "Backup created: $bak" -ForegroundColor Green

  $raw = Get-Content -Path $FilePath -Raw -Encoding UTF8

  # Replace the most common mojibake sequences if present
  $fixed = $raw
  $fixed = $fixed -replace "âœ“", ""      # stray checkmark mojibake
  $fixed = $fixed -replace "â€™", "'"     # smart apostrophe
  $fixed = $fixed -replace "â€œ", '"'     # left quote
  $fixed = $fixed -replace "â€�", '"'     # right quote

  if ($fixed -ne $raw) {
    Set-Content -Path $FilePath -Value $fixed -Encoding UTF8
    Write-Host "Cleaned: $FilePath" -ForegroundColor Green
  } else {
    Write-Host "No change needed: $FilePath" -ForegroundColor Cyan
  }
}

try {
  if (-not (Test-Path $projectRoot)) { throw "Project root not found: $projectRoot" }
  if (-not (Test-Path $backendSrc))  { throw "Backend src not found: $backendSrc" }

  foreach ($t in $targets) {
    Backup-And-Clean -FilePath $t
  }

  # Sanity: hit /puzzles after cleanup
  Set-Location $projectRoot
  $resp = Invoke-WebRequest "http://localhost:8085/puzzles" -UseBasicParsing
  Write-Host ("Sanity /puzzles => " + $resp.StatusCode) -ForegroundColor Green

  Write-Host "PATCH_09A GREEN: encoding cleanup completed." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
