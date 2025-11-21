$ErrorActionPreference = "SilentlyContinue"

Write-Host "== STATUS ==" -ForegroundColor Cyan
docker ps

function ShowOrNA($v){ if ($null -ne $v -and $v -ne "") { $v } else { "n/a" } }

$dbHealth  = ""; try { $dbHealth  = docker inspect -f "{{.State.Health.Status}}" mindlab-db  } catch {}
$apiHealth = ""; try { $apiHealth = docker inspect -f "{{.State.Health.Status}}" mindlab-api } catch {}

Write-Host ("DB  health : {0}"  -f (ShowOrNA $dbHealth))
Write-Host ("API health : {0}"  -f (ShowOrNA $apiHealth))

function Probe($name, $url){
  try {
    $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 -Uri $url
    Write-Host ("{0} {1}" -f $name, $r.StatusCode)
  } catch {
    Write-Host ("{0} ERROR: {1}" -f $name, $_.Exception.Message) -ForegroundColor Yellow
  }
}
Probe "/            :"  "http://localhost/"
Probe "/api/health :"   "http://localhost/api/health"
