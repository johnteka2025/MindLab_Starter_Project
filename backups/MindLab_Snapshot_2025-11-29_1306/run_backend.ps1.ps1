param(
  [int]$ApiPort = 8085,
  [int]$DbHostPort = 5433,
  [string]$PgImage = "postgres:15",
  [string]$ContainerName = "mindlab-db",
  [string]$DbName = "mindlab"
)
$ErrorActionPreference = "Stop"
function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }
function Fail($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

# Pre-reqs
try { docker info 1>$null 2>$null } catch { Fail "Docker is not running. Start Docker Desktop." }
try { node -v 1>$null; npm -v 1>$null } catch { Fail "Node.js/npm missing." }

$root = (Get-Location).Path
$back = Join-Path $root 'backend'
$schemaLocal = Join-Path $back 'db\schema.sql'
if(!(Test-Path $back)){ Fail "Backend folder not found: $back" }

# DB container
Say "Ensuring postgres '$ContainerName' on host :$DbHostPort ..."
$exists = docker ps -a --filter "name=$ContainerName" -q
if(-not $exists){
  Say "Creating container..."
  docker run --name $ContainerName -p "$DbHostPort:5432" -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=$DbName -d $PgImage | Out-Null
}else{
  Say "Starting existing container..."
  docker start $ContainerName | Out-Null
}

# Wait for ready
Say "Waiting for Postgres to be ready ..."
for($i=0; $i -lt 30; $i++){
  $ready = docker exec -i $ContainerName pg_isready -U postgres 2>$null
  if($ready -match "accepting connections"){ Ok "Postgres ready"; break }
  Start-Sleep -Seconds 2
  if($i -eq 29){ Fail "Database not ready." }
}

# Apply schema if present (copy then run)
if(Test-Path $schemaLocal){
  Say "Applying schema from: $schemaLocal"
  docker cp $schemaLocal "$($ContainerName):/tmp/schema.sql"
  docker exec -i $ContainerName psql -U postgres -d $DbName -f /tmp/schema.sql | Out-Null
  Ok "Schema applied."
}else{
  Warn "Schema file not found: $schemaLocal (skipping)"
}

# Backend deps
Push-Location $back
if(!(Test-Path "node_modules")){ Say "Installing backend deps ..."; npm ci }
Pop-Location

# Start backend
Say "Starting backend on :$ApiPort ..."
$env:API_PORT = "$ApiPort"
$proc = Start-Process -FilePath "npm" -ArgumentList "run","dev" -WorkingDirectory $back -PassThru
$proc.Id | Out-File -FilePath (Join-Path ((Get-Location).Path) 'tools\backend.pid') -Encoding ascii -Force

# Health probe
Say "Checking backend health ..."
for($i=0; $i -lt 20; $i++){
  try{
    $h = Invoke-RestMethod "http://127.0.0.1:$ApiPort/health" -TimeoutSec 3
    if($h.ok -and $h.db){ Ok "Backend healthy at http://127.0.0.1:$ApiPort"; exit 0 }
  }catch{}
  Start-Sleep -Seconds 1
}
Warn "Backend not healthy yet—check the backend terminal window."
