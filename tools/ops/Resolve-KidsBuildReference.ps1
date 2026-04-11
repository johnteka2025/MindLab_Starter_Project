param(
    [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project",
    [string]$CandidatesPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_buildreferences_candidates.csv",
    [string]$SelectedPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_buildreferences_selected.txt"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $csv = $Rows | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path, $csv, $utf8NoBom)
}

function Write-Utf8NoBom {
    param([string]$Path,[string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

Set-Location $RepoRoot

$patterns = @(
    '*build*',
    '*dist*',
    '*release*',
    '*out*',
    '*artifact*',
    '*publish*',
    '*package.json',
    '*.sln',
    '*.csproj'
)

$candidates = New-Object System.Collections.Generic.List[object]

$tracked = @(git -C $RepoRoot ls-files)
foreach ($rel in $tracked) {
    $full = Join-Path $RepoRoot $rel
    if (!(Test-Path $full)) { continue }

    $score = 0
    if ($rel -match '(^|/)(build|dist|release|out|artifacts?|publish)(/|$)') { $score += 100 }
    if ($rel -match 'package\.json$') { $score += 40 }
    if ($rel -match '\.(sln|csproj)$') { $score += 30 }
    if ($rel -match '(game|kids|mindlab)') { $score += 10 }

    if ($score -gt 0) {
        $candidates.Add([pscustomobject]@{
            Score         = $score
            RelativePath  = ($rel -replace '\\','/')
            FullPath      = $full
        })
    }
}

if ($candidates.Count -eq 0) {
    Write-Host "OUTCOME:NO_BUILDREFERENCE_CANDIDATES_STOP" -ForegroundColor Yellow
    return
}

$final = @($candidates | Sort-Object Score -Descending, RelativePath -Unique)
Write-CsvUtf8NoBom -Path $CandidatesPath -Rows $final

$selected = $final[0].RelativePath
Write-Utf8NoBom -Path $SelectedPath -Text $selected

Write-Host ("SELECTED_BUILD_REFERENCE:{0}" -f $selected) -ForegroundColor Green
Write-Host "OUTCOME:BUILDREFERENCE_RESOLVED" -ForegroundColor Green