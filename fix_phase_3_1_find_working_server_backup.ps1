<#
fix_phase_3_1_find_working_server_backup.ps1

Goal:
- server.cjs is currently invalid JS (Node can't require it).
- Latest backups are also invalid.
- Scan ALL server.cjs.BEFORE backups and find the newest one that Node can require.
- Restore that working backup to backend\src\server.cjs.
- Log what was chosen.
#>

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function Ensure-Dir([string]$p){
  if(!(Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null }
}

function Timestamp(){
  return (Get-Date).ToString("yyyyMMdd_HHmmss")
}

function Backup-Current([string]$src, [string]$backupRoot){
  Ensure-Dir $backupRoot
  $destDir = Join-Path $backupRoot ("SERVER_CJS_CURRENT_{0}" -f (Timestamp))
  Ensure-Dir $destDir
  $dest = Join-Path $destDir "server.cjs.CURRENT.BEFORE_SCAN"
  Copy-Item $src $dest -Force
  Ok "Backed up current server.cjs => $dest"
  return $dest
}

function Node-Check-Require([string]$backendDir){
  Push-Location $backendDir
  try {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "node"
    $psi.Arguments = "-e `"require('./src/server.cjs')`""
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $p = [System.Diagnostics.Process]::Start($psi)
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()

    if($p.ExitCode -eq 0){
      return @{ ok=$true; msg="" }
    } else {
      return @{ ok=$false; msg=($stderr + "`n" + $stdout).Trim() }
    }
  }
  finally {
    Pop-Location
  }
}


# -------------------
# MAIN
# -------------------

$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir "src\server.cjs"
$BackupRoot  = Join-Path $ProjectRoot "backups\manual_edits"
$LogDir      = Join-Path $ProjectRoot "logs"
Ensure-Dir $LogDir
$LogFile     = Join-Path $LogDir ("PHASE_3_1_find_working_server_backup_{0}.log" -f (Timestamp))

Info "ProjectRoot: $ProjectRoot"
Info "BackendDir : $BackendDir"
Info "ServerFile : $ServerFile"
Info "BackupRoot : $BackupRoot"
Info "LogFile    : $LogFile"

if(!(Test-Path $BackendDir)){ Fail "BackendDir not found: $BackendDir" }
if(!(Test-Path $ServerFile)){ Fail "Server file not found: $ServerFile" }
if(!(Test-Path $BackupRoot)){ Fail "Backup root not found: $BackupRoot" }

Backup-Current $ServerFile $BackupRoot | Out-Null

# Collect ALL server.cjs.BEFORE backups (deep scan)
$all = Get-ChildItem -Path $BackupRoot -Recurse -File -Filter "server.cjs.BEFORE" |
  Sort-Object LastWriteTime -Descending

if(!$all -or $all.Count -eq 0){
  Fail "No server.cjs.BEFORE backups found under: $BackupRoot"
}

Info ("Found {0} server.cjs.BEFORE backups. Scanning newest -> oldest..." -f $all.Count)

"=== Scan Start: $(Get-Date) ===" | Out-File -FilePath $LogFile -Encoding UTF8
"ServerFile: $ServerFile" | Out-File -FilePath $LogFile -Append -Encoding UTF8
"BackupRoot: $BackupRoot" | Out-File -FilePath $LogFile -Append -Encoding UTF8
"" | Out-File -FilePath $LogFile -Append -Encoding UTF8

$found = $null
$idx = 0

foreach($b in $all){
  $idx++
  Info ("[{0}/{1}] Testing backup: {2}" -f $idx, $all.Count, $b.FullName)
  "TEST: $($b.FullName)" | Out-File -FilePath $LogFile -Append -Encoding UTF8

  # Restore candidate
  Copy-Item $b.FullName $ServerFile -Force

  # Check if require() succeeds
  $res = Node-Check-Require $BackendDir
  if($res.ok){
    Ok "WORKING backup found: $($b.FullName)"
    "RESULT: OK" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    $found = $b.FullName
    break
  } else {
    Warn "Backup failed require(). Continuing..."
    "RESULT: FAIL" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    if($res.msg){
      # keep log readable, but include the core error
      ("ERROR: " + ($res.msg -replace "`r","")) | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }
    "" | Out-File -FilePath $LogFile -Append -Encoding UTF8
  }
}

if(!$found){
  Fail "No working server.cjs.BEFORE backup found. See log: $LogFile"
}

Ok "Restored working server.cjs from: $found"
Ok "Next: rerun your Phase 3.1 repair script now that server.cjs is require-able."
Info "Log saved: $LogFile"

