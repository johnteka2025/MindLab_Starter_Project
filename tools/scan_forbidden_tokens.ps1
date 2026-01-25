[CmdletBinding()]
param(
  [string[]]$Tokens = @("pm"),
  [string[]]$IncludeGlobs = @(
    ".\tools\*.ps1",
    ".\backend\**\*.ps1",
    ".\backend\**\*.js",
    ".\backend\**\*.cjs",
    ".\backend\package.json",
    ".\package.json"
  ),
  [string[]]$ExcludeGlobs = @(
    ".\**\node_modules\**",
    ".\**\.git\**",
    ".\**\dist\**",
    ".\**\build\**"
  )
)

$ErrorActionPreference = "Stop"

function Resolve-Globs {
  param([string[]]$Globs)
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($g in $Globs) {
    $items = Get-ChildItem -Path $g -File -ErrorAction SilentlyContinue
    foreach ($i in $items) { $out.Add($i.FullName) }
  }
  $out.ToArray() | Sort-Object -Unique
}

$files = Resolve-Globs -Globs $IncludeGlobs
if (-not $files -or $files.Count -eq 0) { throw "No files matched IncludeGlobs." }

$excludeFiles = Resolve-Globs -Globs $ExcludeGlobs
if ($excludeFiles -and $excludeFiles.Count -gt 0) {
  $excludeSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  foreach ($e in $excludeFiles) { [void]$excludeSet.Add($e) }

  $filtered = New-Object System.Collections.Generic.List[string]
  foreach ($f in $files) { if (-not $excludeSet.Contains($f)) { $filtered.Add($f) } }
  $files = $filtered.ToArray()
}

if (-not $files -or $files.Count -eq 0) { throw "No files left after excludes." }

$hits = @()

foreach ($t in $Tokens) {
  # ONLY flag REAL command invocation at start-of-line (optionally preceded by '&')
  # Flags:  pm test   /  & pm test
  # Ignores: "Unknown command: pm"
  $escaped = [regex]::Escape($t)
  $pattern = "^\s*&?\s*$escaped(\s|$)"

  $m = Select-String -Path $files -Pattern $pattern -AllMatches -ErrorAction SilentlyContinue
  if ($m) { $hits += $m }
}

if ($hits.Count -gt 0) {
  $hits |
    Select-Object Path, LineNumber, Line |
    Sort-Object Path, LineNumber |
    Format-Table -AutoSize
  throw ("Forbidden command token(s) found: {0}" -f ($Tokens -join ", "))
}

Write-Host ("OK: No forbidden COMMAND tokens found: {0}" -f ($Tokens -join ", ")) -ForegroundColor Green
exit 0
