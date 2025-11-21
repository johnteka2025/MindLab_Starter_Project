[CmdletBinding()]
param([string]$BaseUrl="http://localhost:8085")

$target = if ($BaseUrl -match "localhost|127\.0\.0\.1") { $BaseUrl -replace "localhost","host.docker.internal" } else { $BaseUrl }

$runId = (Get-Date).ToString("yyyyMMdd_HHmmss")
$artdir = Join-Path $PSScriptRoot ("..\artifacts\k6_{0}" -f $runId)
New-Item -ItemType Directory -Force -Path $artdir | Out-Null
$log = Join-Path $artdir "k6.console.log"

try { docker version *>$null } catch { throw "Docker not available for k6." }

$js = @"
import http from 'k6/http';
import { check, sleep } from 'k6';
export const options = { vus: 20, duration: '30s',
  thresholds: { http_req_failed: ['rate<0.02'], http_req_duration: ['p(95)<400'] } };
export default function () {
  const res = http.get('${target}/api/health', { timeout: '5s' });
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(0.25);
}
"@
$jsPath = Join-Path $artdir "script.js"; $js | Out-File -Encoding UTF8 $jsPath

$cmd = "docker run --rm -v `"$artdir`:/work`" -w /work grafana/k6 run script.js"
powershell -NoProfile -Command "$cmd" 2>&1 | Tee-Object -FilePath $log | Out-String | Out-Null
$exit = $LASTEXITCODE
if ($exit -ne 0) { throw "k6 exit $exit (see $log)" }
Write-Host "[OK]   k6 completed (see $log)" -ForegroundColor Green
