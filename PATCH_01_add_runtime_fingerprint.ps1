# PATCH_01_add_runtime_fingerprint.ps1
$server = "C:\Projects\MindLab_Starter_Project\backend\src\server.cjs"
if (-not (Test-Path $server)) { throw "Missing: $server" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item -Force $server "$server.bak_fingerprint_$stamp"
Write-Host "Backup created: $server.bak_fingerprint_$stamp" -ForegroundColor Green

$txt = Get-Content -Raw -Encoding UTF8 $server

if ($txt -match "/__runtime") {
  Write-Host "Endpoint /__runtime already present. Skipping." -ForegroundColor Yellow
} else {
  $insert = @"
`n// Runtime fingerprint (debug)
app.get('/__runtime', (req, res) => {
  res.json({
    file: 'backend/src/server.cjs',
    pid: process.pid,
    node: process.version,
    time: new Date().toISOString()
  });
});
`n
"@

  # Insert near the top AFTER app is created: const app = express();
  $pattern = "(?im)^\s*(const|let|var)\s+app\s*=\s*express\(\)\s*;\s*$"
  if ($txt -notmatch $pattern) { throw "Could not find 'const app = express();' in server.cjs" }

  $txt = [regex]::Replace($txt, $pattern, { param($m) $m.Value + $insert }, 1)
  Set-Content -Encoding UTF8 -Path $server -Value $txt
  Write-Host "Inserted /__runtime endpoint into server.cjs" -ForegroundColor Green
}

cd C:\Projects\MindLab_Starter_Project\backend
node --check .\src\server.cjs
if ($LASTEXITCODE -ne 0) { throw "Syntax check FAILED after patch." }
Write-Host "Syntax check OK." -ForegroundColor Green
