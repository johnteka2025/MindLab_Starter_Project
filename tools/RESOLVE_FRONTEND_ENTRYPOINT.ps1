Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root       = "C:\Projects\MindLab_Starter_Project"
$DocsDeploy = "C:\Projects\MindLab_Starter_Project\docs\deployment"

$mainCandidates = @(
    "C:\Projects\MindLab_Starter_Project\frontend\src\main.js",
    "C:\Projects\MindLab_Starter_Project\frontend\src\main.jsx",
    "C:\Projects\MindLab_Starter_Project\frontend\src\main.ts",
    "C:\Projects\MindLab_Starter_Project\frontend\src\main.tsx"
)

$appCandidates = @(
    "C:\Projects\MindLab_Starter_Project\frontend\src\App.js",
    "C:\Projects\MindLab_Starter_Project\frontend\src\App.jsx",
    "C:\Projects\MindLab_Starter_Project\frontend\src\App.ts",
    "C:\Projects\MindLab_Starter_Project\frontend\src\App.tsx"
)

$mainFound = @($mainCandidates | Where-Object { Test-Path $_ })
$appFound  = @($appCandidates  | Where-Object { Test-Path $_ })

if ($mainFound.Count -gt 1) {
    throw "Multiple main entrypoints found. Stop here."
}

if ($mainFound.Count -eq 1) {
    $selected = $mainFound[0]
}
elseif ($appFound.Count -eq 1) {
    $selected = $appFound[0]
}
elseif ($appFound.Count -gt 1) {
    throw "Multiple App files found without a single main entrypoint. Stop here."
}
else {
    throw "No supported frontend entrypoint found. Stop here."
}

New-Item -ItemType Directory -Force $DocsDeploy | Out-Null
$report = Join-Path $DocsDeploy "phase13_entrypoint_report.txt"
$lines = @(
    "SELECTED_ENTRYPOINT=$selected",
    "",
    "MAIN_FOUND:"
) + $mainFound + @(
    "",
    "APP_FOUND:"
) + $appFound

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($report, ($lines -join [Environment]::NewLine), $utf8NoBom)

Write-Output $selected