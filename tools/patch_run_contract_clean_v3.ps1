[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$repoRoot   = "C:\Projects\MindLab_Starter_Project"
$runnerPath = Join-Path $repoRoot "tools\run_contract_clean.ps1"
if (-not (Test-Path $runnerPath)) { throw "STOP: Missing runner: $runnerPath" }

# Backup runner to TEMP (never inside repo)
$bakDir = Join-Path $env:TEMP "mindlab_safe_backups"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
$bak = Join-Path $bakDir ("run_contract_clean.ps1.bak_{0}.ps1" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
Copy-Item -Force $runnerPath $bak
Write-Host ("OK: Backup => {0}" -f $bak) -ForegroundColor Green

# Load as lines for deterministic edits
$lines = Get-Content -Encoding UTF8 $runnerPath

# 1) Ensure Finish helper exists (insert near top, after $ErrorActionPreference if present)
$hasFinish = ($lines | Select-String -Pattern '^\s*function\s+Finish\s*\{' -SimpleMatch -Quiet)
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

  $idx = ($lines | Select-String -Pattern '^\s*\$ErrorActionPreference\s*=' | Select-Object -First 1).LineNumber
  if ($idx) {
    $insertAt = $idx # insert AFTER the line -> LineNumber is 1-based; array insert uses 0-based split
    $lines = @($lines[0..($insertAt-1)] + $finishBlock + $lines[$insertAt..($lines.Count-1)])
  } else {
    $lines = @($finishBlock + $lines)
  }

  Write-Host "OK: Inserted Finish helper." -ForegroundColor Green
} else {
  Write-Host "OK: Finish helper already present (skip)." -ForegroundColor Green
}

# 2) Ensure npm is invoked via npm.cmd and exit code is captured (no 'pm' ever)
# Replace any bare '& npm ' call lines for contract tests with '& $npmExe ...'
# Ensure $npmExe definition exists once.
if (-not ($lines | Select-String -Pattern '^\s*\$npmExe\s*=' -Quiet)) {
  $npmExeLine = '$npmExe = (Get-Command npm.cmd -ErrorAction Stop).Source'
  $idx2 = ($lines | Select-String -Pattern '^\s*\$ErrorActionPreference\s*=' | Select-Object -First 1).LineNumber
  if ($idx2) {
    $insertAt2 = $idx2
    $lines = @($lines[0..($insertAt2-1)] + @($npmExeLine,"") + $lines[$insertAt2..($lines.Count-1)])
  } else {
    $lines = @($npmExeLine,"") + $lines
  }
  Write-Host "OK: Added npm.cmd resolver." -ForegroundColor Green
} else {
  Write-Host "OK: npm.cmd resolver already present (skip)." -ForegroundColor Green
}

# 3) Patch the specific contract-test invocation to use $npmExe and capture exit codes
# NOTE: We keep $backend variable usage intact (NO quotes injected).
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*&\s*npm(\.cmd)?\s+--prefix\s+\$backend\s+test\s+--\s+--runInBand\s+--runTestsByPath\s+\$t\s*$') {
    $lines[$i] = '    & $npmExe --prefix $backend test -- --runInBand --runTestsByPath $t'
    # Insert exit capture immediately after if not already present
    if (($i+1) -lt $lines.Count -and $lines[$i+1] -notmatch '^\s*\$npmExit\s*=\s*\$LASTEXITCODE') {
      $insert = @(
        '    $npmExit = $LASTEXITCODE',
        '    if ($npmExit -ne 0) {',
        '      $failed++',
        '      Write-Host ("FAIL: npm test exited with code: {0}" -f $npmExit) -ForegroundColor Red',
        '    }'
      )
      $lines = @($lines[0..$i] + $insert + $lines[($i+1)..($lines.Count-1)])
    }
    Write-Host "OK: Patched npm test invocation + exit handling." -ForegroundColor Green
    break
  }
}

# 4) Fix script tail to be truthful: success ONLY when $failed == 0 (do not throw raw 'Contract tests green' on failure)
# Remove from first 'if ($failed -gt 0)' to EOF, then append correct tail.
$startEnd = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*if\s*\(\s*\$failed\s*-gt\s*0\s*\)\s*\{\s*$') { $startEnd = $i; break }
}
if ($startEnd -lt 0) { throw "STOP: Could not find tail failure block: if (`$failed -gt 0) { ... }" }

$lines = $lines[0..($startEnd-1)]
$tail = @(
  "",
  "if (`$failed -gt 0) {",
  "  Finish 1 (`"STOP: Contract run finished with failures: {0}`" -f `$failed)",
  "  return",
  "}",
  "",
  "Write-Host `"`"",
  "Write-Host `"== All contract tests green ==`" -ForegroundColor Green",
  "Finish 0 `"OK: Contract tests green.`"",
  "return",
  ""
)
$lines = @($lines + $tail)

# Write runner back
Set-Content -Encoding UTF8 -Path $runnerPath -Value $lines

# Parse check runner (MUST PASS)
$t=$null; $e=$null
[System.Management.Automation.Language.Parser]::ParseFile($runnerPath,[ref]$t,[ref]$e) | Out-Null
if ($e -and $e.Count -gt 0) {
  $e | Format-Table Message,Extent -AutoSize | Out-Host
  throw ("STOP: Runner parse errors after patch. Restore backup: {0}" -f $bak)
}

# Hard guards: no '.Statement' and no standalone 'pm'
if (Select-String -Path $runnerPath -Pattern '\.Statement\b' -Quiet) { throw "STOP: '.Statement' still present in runner." }
if (Select-String -Path $runnerPath -Pattern '(^|\s)pm(\s|$)' -Quiet) { throw "STOP: standalone 'pm' token found in runner." }

Write-Host "OK: Runner patched and validated (parse + guards)." -ForegroundColor Green
