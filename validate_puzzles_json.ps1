# validate_puzzles_json.ps1
# Stronger sanity check for backend puzzle JSON content

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$puzzlesPath = "C:\Projects\MindLab_Starter_Project\backend\data\puzzles.json"

Write-Host "== Validating puzzles.json (stronger rules) =="

if (-not (Test-Path $puzzlesPath)) {
    Write-Host "ERROR: puzzles.json not found at: $puzzlesPath" -ForegroundColor Red
    exit 1
}

try {
    $json = Get-Content $puzzlesPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: puzzles.json is not valid JSON." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

if (-not ($json -is [System.Collections.IEnumerable])) {
    Write-Host "ERROR: puzzles.json root should be an array." -ForegroundColor Red
    exit 1
}

$allowedDifficulties = @("easy", "medium", "hard")
$index = 0

foreach ($p in $json) {
    $index++

    if (-not $p.id -or -not $p.type -or -not $p.question -or -not $p.answer) {
        Write-Host "ERROR: Puzzle #$index is missing required fields (id/type/question/answer)." -ForegroundColor Red
        exit 1
    }

    if ($p.difficulty) {
        if ($allowedDifficulties -notcontains $p.difficulty) {
            Write-Host "ERROR: Puzzle #$index has invalid difficulty '$($p.difficulty)'. Allowed: $($allowedDifficulties -join ', ')." -ForegroundColor Red
            exit 1
        }
    }

    if ($p.hints -and -not ($p.hints -is [System.Collections.IEnumerable])) {
        Write-Host "ERROR: Puzzle #$index has 'hints' but it is not an array." -ForegroundColor Red
        exit 1
    }
}

Write-Host "puzzles.json is valid and contains $index puzzle(s)." -ForegroundColor Green
exit 0
