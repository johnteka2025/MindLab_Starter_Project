Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$target      = Join-Path $projectRoot "phase_2_1D_fix_puzzles_json.ps1"

if (-not (Test-Path $target)) { throw "Missing: $target" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bakDir = Join-Path $projectRoot "backups\manual_edits"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null
$bak = Join-Path $bakDir ("phase_2_1D_fix_puzzles_json.ps1_PARSEFIX_BACKUP_{0}" -f $stamp)
Copy-Item $target $bak -Force
Write-Host "[OK] Backup created: $bak" -ForegroundColor Green

$lines = Get-Content -Path $target

# Replace the problematic one-liner node proof call with PowerShell-safe lines:
#   $nodeProof = "...."
#   node -e $nodeProof $puzzlesPath
$out = New-Object System.Collections.Generic.List[string]

for ($i=0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if ($line -match '^\s*node\s+-e\s+"') {
        # Skip this line (the broken one) and insert safe version
        $out.Add('    $nodeProof = "const fs=require(''fs''); const s=fs.readFileSync(process.argv[1],''utf8''); JSON.parse(s); console.log(''OK: puzzles.json parses as JSON'');"')
        $out.Add('    node -e $nodeProof $puzzlesPath')
        continue
    }

    $out.Add($line)
}

Set-Content -Path $target -Value $out -Encoding UTF8
Write-Host "[OK] Patched node -e proof line to PowerShell-safe form." -ForegroundColor Green

# Parse check (must pass)
[ScriptBlock]::Create((Get-Content -Raw $target)) | Out-Null
Write-Host "[OK] Script parses clean after patch." -ForegroundColor Green
Write-Host "NEXT: run the main script again:" -ForegroundColor Yellow
Write-Host "powershell -NoProfile -ExecutionPolicy Bypass -File `"$target`"" -ForegroundColor Yellow
Read-Host "Press ENTER to continue"
