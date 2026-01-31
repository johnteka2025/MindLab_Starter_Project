[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$runner = ".\tools\run_contract_clean.ps1"
if (-not (Test-Path $runner)) { throw "STOP: Missing runner: $runner" }

# Backup to TEMP (never inside repo)
$bakDir = Join-Path $env:TEMP "mindlab_safe_backups"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
$bak = Join-Path $bakDir ("run_contract_clean.ps1.bak_{0}.ps1" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
Copy-Item -Force $runner $bak
Write-Host "OK: Backup => $bak" -ForegroundColor Green

$lines = Get-Content -Encoding UTF8 $runner

# --- 0) Guard: exactly one CmdletBinding at the very top region ---
# We only validate here; we do NOT attempt to rewrite structure automatically.
$cbCount = ($lines | Select-String -SimpleMatch "[CmdletBinding()]" | Measure-Object).Count
if ($cbCount -ne 1) {
  throw "STOP: Expected exactly 1 [CmdletBinding()] in runner, found $cbCount. Restore from HEAD and re-run."
}

# --- 1) Ensure Finish() exists (insert after $ErrorActionPreference line) ---
$hasFinish = ($lines | Select-String -Pattern '^\s*function\s+Finish\s*\{' -Quiet)
if (-not $hasFinish) {
  $finishBlock = @(
    "",
    "function Finish {",
    "  param(",
    "    [Parameter(Mandatory=`$true)][int]`$Code,",
    "    [Parameter(Mandatory=`$true)][string]`$Message",
    "  )",
    "  if (`$Code -ne 0) { Write-Host `$Message -ForegroundColor Red } else { Write-Host `$Message -ForegroundColor Green }",
    "  `$global:LASTEXITCODE = `$Code",
    "  return",
    "}",
    ""
  )

  $eapIdx = -1
  for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*\$ErrorActionPreference\s*=\s*') { $eapIdx = $i; break }
  }
  if ($eapIdx -lt 0) { throw "STOP: Could not locate `$ErrorActionPreference assignment." }

  # Insert right after ErrorActionPreference line
  $lines = @($lines[0..$eapIdx] + $finishBlock + $lines[($eapIdx+1)..($lines.Count-1)])
  Write-Host "OK: Inserted Finish() helper." -ForegroundColor Green
} else {
  Write-Host "OK: Finish() already present (skip)." -ForegroundColor Green
}

# --- 2) Ensure npm resolver uses npm.cmd (or npm) and NOT pm ---
# Replace any existing npm resolver line(s) with a stable one (idempotent).
# We do NOT touch comments mentioning "pm".
$npmResolver = '$npmExe = (Get-Command npm.cmd -ErrorAction SilentlyContinue).Source; if (-not $npmExe) { $npmExe = (Get-Command npm -ErrorAction Stop).Source }'

# Remove existing assignments to $npmCmd or $npmExe to avoid duplicates
$lines = $lines | Where-Object { $_ -notmatch '^\s*\$(npmCmd|npmExe)\s*=' }

# Insert resolver right after ErrorActionPreference if not present
$hasResolver = ($lines | Select-String -SimpleMatch '$npmExe =' -Quiet)
if (-not $hasResolver) {
  $eapIdx2 = -1
  for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*\$ErrorActionPreference\s*=\s*') { $eapIdx2 = $i; break }
  }
  if ($eapIdx2 -lt 0) { throw "STOP: Could not locate `$ErrorActionPreference assignment (2)." }
  $lines = @($lines[0..$eapIdx2] + @($npmResolver, "") + $lines[($eapIdx2+1)..($lines.Count-1)])
  Write-Host "OK: Inserted npm resolver." -ForegroundColor Green
}

# --- 3) Replace calls that invoke npm directly to use $npmExe ---
for ($i=0; $i -lt $lines.Count; $i++) {
  # common patterns we saw: "& npm ..." or "npm ..." or "& $npmCmd ..."
  if ($lines[$i] -match '^\s*&\s*npm(\.cmd)?\b') {
    $lines[$i] = ($lines[$i] -replace '^\s*&\s*npm(\.cmd)?\b', '& $npmExe')
  }
  if ($lines[$i] -match '^\s*&\s*\$npmCmd\b') {
    $lines[$i] = ($lines[$i] -replace '^\s*&\s*\$npmCmd\b', '& $npmExe')
  }
}

# --- 4) After the npm test line, capture exit code and increment failures ---
# Find line that runs: & $npmExe --prefix $backend test -- --runInBand --runTestsByPath $t
$npmLineIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*&\s*\$npmExe\s+--prefix\s+\$backend\s+test\s+--\s+--runInBand\s+--runTestsByPath\s+\$t\s*$') {
    $npmLineIdx = $i
    break
  }
}

if ($npmLineIdx -lt 0) {
  throw "STOP: Could not locate the npm test invocation line. Open tools\run_contract_clean.ps1 and ensure it matches expected format."
}

# If exit-capture already present right after, skip
$alreadyExit = $false
if ($npmLineIdx + 1 -lt $lines.Count) {
  if ($lines[$npmLineIdx + 1] -match '\$npmExit\s*=\s*\$LASTEXITCODE') { $alreadyExit = $true }
}

if (-not $alreadyExit) {
  $exitBlock = @(
    '    $npmExit = $LASTEXITCODE',
    '    if ($npmExit -ne 0) {',
    '      $failed++',
    '      Write-Host ("FAIL: npm test exited with code: {0}" -f $npmExit) -ForegroundColor Red',
    '    }'
  )
  $lines = @($lines[0..$npmLineIdx] + $exitBlock + $lines[($npmLineIdx+1)..($lines.Count-1)])
  Write-Host "OK: Added npm exit-code handling." -ForegroundColor Green
} else {
  Write-Host "OK: npm exit-code handling already present (skip)." -ForegroundColor Green
}

# --- 5) Replace end-of-script behavior to use Finish() instead of throw ---
# We look for the block: if ($failed -gt 0) { throw ... }
# and replace with Finish calls.
$startFailIdx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*if\s*\(\s*\$failed\s*-gt\s*0\s*\)\s*\{\s*$') { $startFailIdx = $i; break }
}
if ($startFailIdx -lt 0) { throw "STOP: Could not locate end failure block: if (`$failed -gt 0) { ... }" }

# Find closing brace for that if block (simple scan)
$endFailIdx = -1
for ($i=$startFailIdx+1; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*\}\s*$') { $endFailIdx = $i; break }
}
if ($endFailIdx -lt 0) { throw "STOP: Could not locate end of failure block (closing brace)." }

$replacementEnd = @(
  'if ($failed -gt 0) {',
  '  Finish 1 ("STOP: Contract run finished with failures: {0}" -f $failed)',
  '}',
  '',
  'Write-Host ""',
  'Write-Host "== All contract tests green ==" -ForegroundColor Green',
  'Finish 0 "OK: Contract tests green."'
)

# Replace the old block with new end section
$lines = @($lines[0..($startFailIdx-1)] + $replacementEnd)

Set-Content -Encoding UTF8 -Path $runner -Value $lines
Write-Host "OK: Patch applied to tools\run_contract_clean.ps1" -ForegroundColor Green

# Final sanity: parse must succeed
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $runner).Path,[ref]$tokens,[ref]$errors) | Out-Null
if ($errors -and $errors.Count -gt 0) {
  $errors | Format-Table Message,Extent -AutoSize | Out-Host
  throw "STOP: Patch produced parse errors. Restore from backup: $bak"
}

Write-Host "OK: Runner parses after patch." -ForegroundColor Green
