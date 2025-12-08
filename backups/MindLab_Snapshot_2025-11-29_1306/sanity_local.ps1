param(
    [switch]$LogToFile
)

# Root of the project
$ProjectRoot = "C:\Projects\MindLab_Starter_Project"

Set-Location $ProjectRoot

# Local URLs
$backendUrl  = "http://localhost:8085"
$frontendUrl = "http://localhost:5177"

# Build parameter hashtable for prod_sanity.ps1
$params = @{
    BackendUrl  = $backendUrl
    FrontendUrl = $frontendUrl
}

if ($LogToFile) {
    $params.LogToFile = $true
    $params.LogPath   = ".\prod_sanity_local.log"
}

# Call the main sanity script with splatted named parameters
& "$ProjectRoot\prod_sanity.ps1" @params
