[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ApiImage,
  [Parameter(Mandatory=$true)][string]$WebImage,
  [Parameter(Mandatory=$true)][string]$ReleaseTag,
  [string]$RegistryUser,
  [string]$RegistryToken
)
function Fail([string]$m){ throw "STOP: $m" } function Ok([string]$m){ Write-Host "[OK]  $m" -ForegroundColor Green } function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
if ($RegistryUser -and $RegistryToken){ docker logout docker.io 2>$null | Out-Null; docker login -u $RegistryUser -p $RegistryToken | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Registry login failed (check user/token scopes)." } }
function Repo([string]$img){ if($img -match "^(?<r>.+?):[^:]+$"){ $Matches['r'] } else { $img } }
$apiRepo = Repo $ApiImage; $webRepo = Repo $WebImage; $apiNew=('{0}:{1}' -f $apiRepo,$ReleaseTag); $webNew=('{0}:{1}' -f $webRepo,$ReleaseTag)
docker pull $ApiImage | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Pull failed: $ApiImage" }
docker pull $WebImage | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Pull failed: $WebImage" }
docker tag $ApiImage $apiNew; if($LASTEXITCODE -ne 0){ Fail "Tag failed (API)" }
docker tag $WebImage $webNew; if($LASTEXITCODE -ne 0){ Fail "Tag failed (WEB)" }
docker push $apiNew | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Push failed: $apiNew" }
docker push $webNew | Out-Host; if($LASTEXITCODE -ne 0){ Fail "Push failed: $webNew" }
Ok ("Release complete: API -> {0}  |  WEB -> {1}" -f $apiNew,$webNew)
