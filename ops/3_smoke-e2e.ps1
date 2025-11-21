[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK]    $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

$backendHealthUrl  = "http://localhost:8085/api/health"
$frontendRootUrl   = "http://localhost:5177/"

# --------------------------------------------------
# STEP 1 — Check backend /api/health
# --------------------------------------------------
Info "Checking backend health at $backendHealthUrl ..."

try {
    $backendResp = Invoke-WebRequest -Uri $backendHealthUrl -UseBasicParsing -TimeoutSec 10
}
catch {
    Err "Backend health request failed: $($_.Exception.Message)"
    exit 1
}

if ($backendResp.StatusCode -ne 200) {
    Err "Backend returned HTTP $($backendResp.StatusCode) instead of 200."
    exit 1
}

Ok "Backend responded with HTTP 200."

# try to parse JSON
try {
    $backendJson = $backendResp.Content | ConvertFrom-Json
}
catch {
    Err "Backend response was not valid JSON: '$($backendResp.Content)'"
    exit 1
}

if ($backendJson.ok -ne $true) {
    Err "Backend JSON does not have ok=true. Actual payload: $($backendResp.Content)"
    exit 1
}

Ok "Backend JSON looks good: $($backendResp.Content)"

# --------------------------------------------------
# STEP 2 — Check frontend root page
# --------------------------------------------------
Info "Checking frontend UI at $frontendRootUrl ..."

try {
    $frontendResp = Invoke-WebRequest -Uri $frontendRootUrl -UseBasicParsing -TimeoutSec 10
}
catch {
    Err "Frontend request failed: $($_.Exception.Message)"
    exit 1
}

if ($frontendResp.StatusCode -ne 200) {
    Err "Frontend returned HTTP $($frontendResp.StatusCode) instead of 200."
    exit 1
}

Ok "Frontend responded with HTTP 200."

# Look for key text from the React UI
$frontendHtml = $frontendResp.Content

if ($frontendHtml -notmatch "Frontend") {
    Warn "Frontend HTML does not contain the text 'Frontend'."
} else {
    Ok "Frontend HTML contains the heading 'Frontend'."
}

if ($frontendHtml -notmatch "Backend is healthy") {
    Warn "Frontend HTML does not yet show 'Backend is healthy' (maybe state not loaded?)."
} else {
    Ok "Frontend HTML shows health message containing 'Backend is healthy'."
}

# --------------------------------------------------
# SUMMARY
# --------------------------------------------------
Ok "End-to-end smoke test PASSED (backend + frontend look healthy)."
exit 0
