param(
    [switch]$LogToFile
)

$ProjectRoot = "C:\Projects\MindLab_Starter_Project"

Set-Location $ProjectRoot

# Render PROD URLs
$backendUrl  = "https://mindlab-swpk.onrender.com"
$frontendUrl = "https://mindlab-swpk.onrender.com/app"

$params = @{
    BackendUrl  = $backendUrl
    FrontendUrl = $frontendUrl
}

if ($LogToFile) {
    $params.LogToFile = $true
    $params.LogPath   = ".\prod_sanity_prod.log"
}

& "$ProjectRoot\prod_sanity.ps1" @params
