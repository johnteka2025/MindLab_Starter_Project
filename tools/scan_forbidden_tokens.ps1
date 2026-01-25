[CmdletBinding()]
param(
  [string[]]$IncludeGlobs = @(
    ".\tools\*.ps1",
    ".\backend\**\*.js",
    ".\backend\**\*.cjs",
    ".\backend\package.json"
  ),

  # Only forbid as an ACTUAL COMMAND token at start-of-line (optionally preceded by &)
  [string[]]$ForbiddenCommandTokens = @("pm"),

  # Exclude guard/scan scripts from scanning (they may contain examples/regex strings)
  [string[]]$ExcludePaths = @(
    "\tools\guard_no_pm.ps1",
    "\tools\scan_forbidden_tokens.ps1"
  )
)

$ErrorActionPreference = "Stop"

function Get-Files([string[]]$globs) {
  $all = @()
  foreach ($g in $globs) {
    $all += Get-ChildItem -Path $g -File -ErrorAction SilentlyContinue
  }
  # de-dupe
  $all | Sort-Object FullName -Unique
}

$files = Get-Files $IncludeGlobs
if (-not $files -or $files.Count -eq 0) { throw "No files matched IncludeGlobs." }

# apply excludes
$files = $files | Where-Object {
  $p = $_.FullName
  foreach ($ex in $ExcludePaths) { if ($p -like "*$ex") { return $false } }
  return $true
}

$hits = @()

foreach ($tok in $ForbiddenCommandTokens) {
  # Match only actual command usage:
  #   pm test
  #   & pm test
  # Not matches:
  #   "Unknown command: 'pm'"
  #   $pattern = 'pm'
  $pattern = "^(?i)\s*(&\s*)?$([regex]::Escape($tok))(\s|$)"

  foreach ($f in $files) {
    $m = Select-String -Path $f.FullName -Pattern $pattern -AllMatches -ErrorAction SilentlyContinue
    if ($m) { $hits += $m }
  }
}

if ($hits.Count -gt 0) {
  $hits |
    Select-Object Path, LineNumber, Line |
    Sort-Object Path, LineNumber |
    Format-Table -AutoSize

  throw ("Forbidden COMMAND token(s) found: {0}" -f ($ForbiddenCommandTokens -join ", "))
}

Write-Host ("OK: No forbidden COMMAND tokens found: {0}" -f ($ForbiddenCommandTokens -join ", ")) -ForegroundColor Green
exit 0
