[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ApiImage,
  [Parameter(Mandatory=$true)][string]$WebImage,
  [switch]$NoPrompt,
  [string]$HubUser = "",
  [string]$HubToken = ""
)
function Fail([string]$m){ throw "STOP: $m" }
function Ok([string]$m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Fail "Docker CLI not found in PATH." }
try { $null = docker info --format '{{json .ServerVersion}}' 2>$null } catch { Fail "Docker daemon not responding. Start Docker Desktop." }
Ok "Docker is running"

$RefPattern = '^(?<registry>[^/]+)/(?<owner>[^/]+)/(?<name>[^:]+):(?<tag>[^:]+)$'
function Validate-Ref([string]$ref,[string]$label){
  if ($ref -match '<|>') { Fail "$label contains placeholders: $ref" }
  if (-not ($ref -match $RefPattern)) { Fail "$label is not a valid image reference: $ref" }
}
Validate-Ref $ApiImage "ApiImage"; Validate-Ref $WebImage "WebImage"
Ok "Image references look valid"

function Try-Pull([string]$ref){
  $out = docker pull $ref 2>&1
  [pscustomobject]@{ Code=$LASTEXITCODE; Output=$out -join "`n" }
}

Info "Pulling (anonymous) API: $ApiImage"
$r1 = Try-Pull $ApiImage
Info "Pulling (anonymous) WEB: $WebImage"
$r2 = Try-Pull $WebImage

$needLogin = (($r1.Code -ne 0 -and $r1.Output -match 'denied|unauthorized|authentication required') -or
              ($r2.Code -ne 0 -and $r2.Output -match 'denied|unauthorized|authentication required'))
if ($needLogin) {
  Warn "Images appear PRIVATE."
  if ($NoPrompt -and (-not $HubUser -or -not $HubToken)) {
    Fail "Private images require Docker Hub credentials but -NoPrompt was used."
  }
  if (-not $HubUser -or -not $HubToken) {
    $HubUser  = Read-Host "Docker Hub username (private images)"
    $HubToken = Read-Host "Docker Hub password or RW access token"
  }
  Info "Logging into Docker Hub as $HubUser"
  docker logout docker.io 2>$null | Out-Null
  docker login -u $HubUser -p $HubToken | Out-Host
  if ($LASTEXITCODE -ne 0) { Fail "Docker Hub login failed for $HubUser" }

  Info "Re-pulling API"; docker pull $ApiImage | Out-Host; if ($LASTEXITCODE -ne 0) { Fail "Pull failed: $ApiImage" }
  Info "Re-pulling WEB"; docker pull $WebImage | Out-Host; if ($LASTEXITCODE -ne 0) { Fail "Pull failed: $WebImage" }
} else {
  if ($r1.Code -ne 0) { Fail "Pull failed: $ApiImage`n$r1" }
  if ($r2.Code -ne 0) { Fail "Pull failed: $WebImage`n$r2" }
}
Ok "Preflight passed. Images exist & are accessible."
