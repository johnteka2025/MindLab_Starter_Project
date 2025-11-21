[CmdletBinding()]
param([int]$ApiPort=8085,[int]$WebPort=5177,[switch]$CutRelease,[switch]$NoPrompt)
function Fail([string]$m){ throw "STOP: $m" } function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan } function Ok([string]$m){ Write-Host "[OK]  $m" -ForegroundColor Green }
$Deploy  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Preflight = Join-Path $Deploy "preflight_dockerhub.ps1"
$Phase16   = Join-Path $Deploy "phase16_run_published.ps1"
$Phase17   = Join-Path $Deploy "phase17_api_tests.ps1"
$Phase18   = Join-Path $Deploy "phase18_release.ps1"
$Down      = Join-Path $Deploy "down_clean.ps1"
@($Preflight,$Phase16,$Phase17,$Phase18,$Down) | ForEach-Object { if(-not (Test-Path $_)){ throw "STOP: Required script missing: $_" } }

$User = Read-Host "Docker Hub username/namespace (e.g., johndoe)"
$ApiRepo = Read-Host "API repo name (e.g., mindlab-api)"
$WebRepo = Read-Host "WEB repo name (e.g., mindlab-web)"
$ApiTag  = Read-Host "API tag (e.g., 1.0.0 or latest)"
$WebTag  = Read-Host "WEB tag (e.g., 1.0.0 or latest)"
function Ref($u,$r,$t){ if(($u+$r+$t) -match '<|>'){ throw "STOP: Placeholders not allowed." }; "docker.io/$u/$r`:$t" }
$ApiImage = Ref $User $ApiRepo $ApiTag; $WebImage = Ref $User $WebRepo $WebTag
$pf=@{ ApiImage=$ApiImage; WebImage=$WebImage }; if($NoPrompt){ $pf.NoPrompt=$true }
& $Preflight @pf; if($LASTEXITCODE -ne 0){ throw "STOP: Preflight failed." }

$ph16=@{ ApiImage=$ApiImage; WebImage=$WebImage; ApiPort=$ApiPort; WebPort=$WebPort }
& $Phase16 @ph16 -Verbose; if($LASTEXITCODE -ne 0){ throw "STOP: Phase 16 failed." }

$base="http://localhost:$ApiPort"
& $Phase17 -BaseUrl $base; if($LASTEXITCODE -ne 0){ throw "STOP: Phase 17 failed." }

if($CutRelease){
  $NewTag=Read-Host "New release tag (e.g., 1.0.1 or stable)"
  & $Phase18 -ApiImage $ApiImage -WebImage $WebImage -ReleaseTag $NewTag
  if($LASTEXITCODE -ne 0){ throw "STOP: Phase 18 failed." }
}
Ok "ALL DONE"; Write-Host "API: $base"; Write-Host ("WEB: http://localhost:{0}" -f $WebPort)
