Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$BASE="http://127.0.0.1:8085"

function Post($path,$body){
$json=$body | ConvertTo-Json -Depth 10
try{
$r=Invoke-WebRequest -Method Post ($BASE+$path) -UseBasicParsing -TimeoutSec 10 -ContentType "application/json" -Body $json
return @{status=$r.StatusCode;body=$r.Content}
}catch{
$status=$null
if($_.Exception.Response){$status=[int]$_.Exception.Response.StatusCode}
return @{status=$status;body=""}
}
}

function Get($path){
$r=Invoke-WebRequest ($BASE+$path) -UseBasicParsing -TimeoutSec 10
return @{status=$r.StatusCode;body=$r.Content}
}

$r0=Post "/__test__/reset" @{}
if($r0.status -ne 204){ throw "reset failed" }

$d=Get "/daily"
if($d.status -ne 200){ throw "daily route broken" }

$puzzleId=(ConvertFrom-Json $d.body).puzzles[0].id

$a1=Post "/daily/answer" @{ puzzleId=$puzzleId;answer="x"}
$a2=Post "/daily/answer" @{ puzzleId=$puzzleId;answer="x"}

if($a1.status -ne 200){ throw "first answer fail" }
if($a2.status -ne 409){ throw "duplicate answer fail" }

Write-Host "OK CONTRACT TEST PASSED" -ForegroundColor Green
