Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$target = Join-Path $projectRoot "phase_2_1D_fix_puzzles_json.ps1"

if (-not (Test-Path $target)) { throw "Missing target: $target" }

# Backup
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bakDir = Join-Path $projectRoot "backups\manual_edits"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
$bak = Join-Path $bakDir "phase_2_1D_fix_puzzles_json.ps1_PATCHv2_$stamp"
Copy-Item $target $bak -Force
Write-Host "[OK] Backup created: $bak" -ForegroundColor Green

# Load script
$lines = Get-Content -Path $target
$out   = New-Object System.Collections.Generic.List[string]

foreach ($line in $lines) {

    # Remove ANY existing node -e JSON proof lines
    if ($line -match 'node\s+-e') { continue }

    $out.Add($line)

    # Insert safe JS-file-based proof immediately after puzzles.json write
    if ($line -match 'Write valid JSON') {
        $out.Add('')
        $out.Add('    $tmpJs = Join-Path $env:TEMP "json_parse_check.js"')
        $out.Add('    @''')
        $out.Add('const fs = require("fs");')
        $out.Add('const p = process.argv[2];')
        $out.Add('JSON.parse(fs.readFileSync(p,"utf8"));')
        $out.Add('console.log("OK: puzzles.json parses as JSON");')
        $out.Add('''@ | Set-Content -Path $tmpJs -Encoding UTF8')
        $out.Add('    node $tmpJs $puzzlesPath')
        $out.Add('    Remove-Item $tmpJs -Force')
    }
}

Set-Content -Path $target -Value $out -Encoding UTF8
Write-Host "[OK] Patch v2 applied (JS file method)." -ForegroundColor Green

# FINAL PARSE CHECK
[ScriptBlock]::Create((Get-Content -Raw $target)) | Out-Null
Write-Host "[OK] Target script parses clean." -ForegroundColor Green

Write-Host "NEXT: Run Phase 2.1D again:" -ForegroundColor Yellow
Write-Host "powershell -NoProfile -ExecutionPolicy Bypass -File `"$target`"" -ForegroundColor Yellow
Read-Host "Press ENTER to continue"
