param(
    [string]$ImageName = "mindlab-fullapp",
    [string]$Tag = "latest",
    [string]$ContainerName = "mindlab-fullapp",
    [string]$BaseUrl = "http://127.0.0.1:8085",
    [int]$Port = 8085
)

Write-Host "=== MindLab DOCKER SMOKE TEST ===" -ForegroundColor Cyan
Write-Host "Image: $ImageName`:$Tag"
Write-Host "Container: $ContainerName"
Write-Host "Base URL: $BaseUrl"
Write-Host ""

# -------------------------------
# 1) Build Docker image
# -------------------------------
Write-Host "[1/6] Building Docker image..." -ForegroundColor Green

$buildCmd = "docker build -f C:\Projects\MindLab_Starter_Project\Dockerfile.fullapp -t $ImageName`:$Tag C:\Projects\MindLab_Starter_Project"
Write-Host "Running: $buildCmd"
Invoke-Expression $buildCmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed with exit code $LASTEXITCODE. Aborting."
    exit $LASTEXITCODE
}

# -------------------------------
# 2) Ensure no old container is running
# -------------------------------
Write-Host "[2/6] Ensuring no old container '$ContainerName' is running..." -ForegroundColor Green

$existing = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $ContainerName }

if ($existing) {
    Write-Host "Old container found. Stopping and removing..." -ForegroundColor Yellow
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
}

# -------------------------------
# 3) Run container
# -------------------------------
Write-Host "[3/6] Starting container..." -ForegroundColor Green

$runCmd = "docker run -d -p $Port`:$Port --name $ContainerName $ImageName`:$Tag"
Write-Host "Running: $runCmd"
$containerId = Invoke-Expression $runCmd

if (-not $containerId) {
    Write-Error "Failed to start Docker container."
    exit 1
}

Write-Host "Container started with ID: $containerId" -ForegroundColor Yellow

# -------------------------------
# 4) Wait for /health to be ready
# -------------------------------
Write-Host "[4/6] Waiting for backend health at $BaseUrl/health ..." -ForegroundColor Green

$maxTries = 30
$ok = $false

for ($i = 1; $i -le $maxTries; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri "$BaseUrl/health" -UseBasicParsing -TimeoutSec 5
        if ($resp.StatusCode -eq 200) {
            Write-Host ("Backend healthy on try {0} (HTTP 200)" -f $i) -ForegroundColor Green
            $ok = $true
            break
        } else {
            Write-Host ("Try {0}: /health -> HTTP {1}" -f $i, $resp.StatusCode)
        }
    }
    catch {
        Write-Host ("Try {0}: /health not ready yet..." -f $i)
    }
    Start-Sleep -Seconds 2
}

if (-not $ok) {
    Write-Error "Backend in container never became healthy. Stopping container and aborting."
    docker logs $ContainerName
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null
    exit 1
}

# -------------------------------
# 5) Run Playwright tests
# -------------------------------
Write-Host "[5/6] Running Playwright tests against container..." -ForegroundColor Green

Set-Location "C:\Projects\MindLab_Starter_Project\frontend"

npm install | Out-Null

# Run Playwright in this PowerShell process so we can read $LASTEXITCODE
$npxCmd = "npx playwright test --trace=on"
Write-Host "Running: $npxCmd"
Invoke-Expression $npxCmd
$playwrightExit = $LASTEXITCODE

# -------------------------------
# 6) Stop container and summarize
# -------------------------------
Write-Host "[6/6] Stopping and removing container..." -ForegroundColor Green
docker stop $ContainerName | Out-Null
docker rm $ContainerName | Out-Null

Write-Host ""
Write-Host "=== DOCKER SMOKE TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "Playwright exit code: $playwrightExit"

if ($playwrightExit -eq 0) {
    Write-Host "DOCKER SMOKE TEST PASSED ✅" -ForegroundColor Green
} else {
    Write-Host "DOCKER SMOKE TEST FAILED ❌" -ForegroundColor Red
}

exit $playwrightExit
