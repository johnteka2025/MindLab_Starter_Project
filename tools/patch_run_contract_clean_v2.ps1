[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$runner = "C:\Projects\MindLab_Starter_Project\tools\run_contract_clean.ps1"
if (-not (Test-Path $runner)) { throw "STOP: Missing runner: $runner" }

# Backup to TEMP
$bakDir = Join-Path $env:TEMP "mindlab_safe_backups"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
$bak = Join-Path $bakDir ("run_contract_clean.ps1.bak_{0}.ps1" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
Copy-Item -Force $runner $bak
Write-Host ("OK: Backup => {0}" -f $bak) -ForegroundColor Green

# Parse before
$t=$null; $e=$null
[System.Management.Automation.Language.Parser]::ParseFile($runner,[ref]$t,[ref]$e) | Out-Null
if ($e -and $e.Count -gt 0) {
  $e | Format-Table Message,Extent -AutoSize | Out-Host
  throw "STOP: Runner has parse errors BEFORE patch. Restore from git/backup."
}

$raw = Get-Content -Raw -Encoding UTF8 $runner

# 1) Ensure Finish helper exists (insert after $ErrorActionPreference)
if ($raw -notmatch '(?m)^\s*function\s+Finish\s*\{') {
  $finish = @(
'function Finish {'
'  param([Parameter(Mandatory=$true)][int]$Code,[Parameter(Mandatory=$true)][string]$Message)'
'  if ($Code -ne 0) { Write-Host $Message -ForegroundColor Red } else { Write-Host $Message -ForegroundColor Green }'
'  $global:LASTEXITCODE = $Code'
'  return'
'}'
''
  ) -join "`r`n"

  if ($raw -notmatch '(?m)^\s*\$ErrorActionPreference\s*=') {
    throw "STOP: Cannot find `$ErrorActionPreference to insert Finish after."
  }

  $raw = [regex]::Replace(
    $raw,
    '(?m)^(\s*\$ErrorActionPreference\s*=\s*[^\r\n]+(\r?\n))',
    ('$1' + $finish + "`r`n"),
    1
  )

  Write-Host "OK: Inserted Finish()." -ForegroundColor Green
} else {
  Write-Host "OK: Finish() already present (skip)." -ForegroundColor Green
}

# 2) Ensure npm executable is resolved and used (avoid 'pm' typo)
if ($raw -notmatch '(?m)^\s*\$npmExe\s*=') {
  $raw = [regex]::Replace(
    $raw,
    '(?m)^(\s*\$backend\s*=.*(\r?\n))',
    ('$1' + '$npmExe = (Get-Command npm.cmd -ErrorAction Stop).Source' + "`r`n"),
    1
  )
  Write-Host "OK: Added npm.cmd resolver ($npmExe)." -ForegroundColor Green
} else {
  Write-Host "OK: npm resolver already present (skip)." -ForegroundColor Green
}

# 3) Patch the call line to use $npmExe and capture exit code
$callPattern = '(?m)^\s*&\s*npm\s+--prefix\s+\$backend\s+test\s+--\s+--runInBand\s+--runTestsByPath\s+\$t\s*$'
if ($raw -notmatch $callPattern) {
  throw "STOP: Could not find: & npm --prefix $backend test -- --runInBand --runTestsByPath $t"
}

$replacement = @(
'    & $npmExe --prefix $backend test -- --runInBand --runTestsByPath $t'
'    $npmExit = $LASTEXITCODE'
'    if ($npmExit -ne 0) {'
'      $failed++'
'      Write-Host ("FAIL: npm test exited with code: {0}" -f $npmExit) -ForegroundColor Red'
'    }'
) -join "`r`n"

$raw = [regex]::Replace($raw, $callPattern, $replacement, 1)
Write-Host "OK: Patched npm invocation and exit capture." -ForegroundColor Green

# 4) Patch script tail: fail => Finish 1; success => Finish 0 (no false green)
$tailPattern = '(?ms)^\s*if\s*\(\s*\$failed\s*-gt\s*0\s*\)\s*\{.*\z'
if ($raw -notmatch $tailPattern) {
  throw "STOP: Could not locate script tail starting with: if ($failed -gt 0) {"
}

$correctTail = @(
'if ($failed -gt 0) {'
'  Finish 1 ("STOP: Contract run finished with failures: {0}" -f $failed)'
'  return'
'}'
''
'Write-Host ""'
'Write-Host "== All contract tests green ==" -ForegroundColor Green'
'Finish 0 "OK: Contract tests green."'
'return'
) -join "`r`n"

$raw = [regex]::Replace($raw, $tailPattern, $correctTail, 1)
Write-Host "OK: Rewrote script tail (truthful exit behavior)." -ForegroundColor Green

# Write back
Set-Content -Encoding UTF8 -Path $runner -Value $raw

# Parse after
$t=$null; $e=$null
[System.Management.Automation.Language.Parser]::ParseFile($runner,[ref]$t,[ref]$e) | Out-Null
if ($e -and $e.Count -gt 0) {
  $e | Format-Table Message,Extent -AutoSize | Out-Host
  throw ("STOP: Patch produced parse errors. Restore from backup: {0}" -f $bak)
}

Write-Host "OK: Patch applied and runner parses." -ForegroundColor Green
