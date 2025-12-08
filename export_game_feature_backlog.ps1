$ErrorActionPreference = "Stop"

function Ensure-AtProjectRoot {
    param(
        [string]$ExpectedRoot = "C:\Projects\MindLab_Starter_Project"
    )
    $current = (Get-Location).ProviderPath
    if ($current -ne $ExpectedRoot) {
        Write-Host "[INFO] Changing location to $ExpectedRoot" -ForegroundColor Cyan
        Set-Location $ExpectedRoot
    }
    Write-Host "[INFO] Current location: $(Get-Location)" -ForegroundColor Green
}

Ensure-AtProjectRoot

$dateStamp  = Get-Date -Format "yyyy-MM-dd"
$timeStamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# NOTE: now generating a plain text file that Word can open directly
$backlogName = "MindLab_Game_Feature_Backlog_{0}.txt" -f $dateStamp
$backlogPath = Join-Path (Get-Location) $backlogName

Write-Host "=== MindLab Game Feature Backlog Export ===" -ForegroundColor Cyan
Write-Host "[INFO] Writing backlog to: $backlogPath" -ForegroundColor Cyan

$content = @()

$content += "MindLab Game Feature Backlog"
$content += "Generated: $timeStamp"
$content += ""
$content += "========================================"
$content += "1. Completed Foundation"
$content += "========================================"
$content += "- Backend health and /daily API sanity scripts"
$content += "- Daily sanity (status, instance, answer flow)"
$content += "- Daily routine checks"
$content += "- Playwright end-to-end tests:"
$content += "  - Homepage plus backend"
$content += "  - Health and puzzles flow"
$content += "  - Progress API stats"
$content += "  - Puzzles navigation"
$content += "  - Daily UI smoke test"
$content += "  - Daily solve-flow (answer button)"
$content += "  - Daily result UI feedback"
$content += "- Daily Phase runner script"
$content += ""
$content += "========================================"
$content += "2. Next Features – Daily Experience"
$content += "========================================"
$content += "- Clear Daily completion card showing correct/incorrect and explanation."
$content += "- Daily streak display for consecutive days played."
$content += "- Simple reward text or icon when streak milestones are hit."
$content += "- Better visual layout for Daily that feels good for all ages."
$content += ""
$content += "========================================"
$content += "3. Next Features – Puzzle Variety"
$content += "========================================"
$content += "- New puzzle type: word and definition matching."
$content += "- New puzzle type: memory or sequence game."
$content += "- Difficulty tuning per puzzle (1–5) with clear icons."
$content += ""
$content += "========================================"
$content += "4. Next Features – Age Adaptation"
$content += "========================================"
$content += "- Age group selection: child, teen, adult."
$content += "- Adjust puzzle difficulty and wording based on age group."
$content += "- Optional gentle mode with hints for younger players."
$content += ""
$content += "========================================"
$content += "5. Next Features – Progress and Meta"
$content += "========================================"
$content += "- Weekly summary screen: puzzles solved, streak, accuracy."
$content += "- Simple achievement badges such as 7-day streak and first 10 puzzles solved."
$content += "- Export basic stats for a future parent or teacher view."
$content += ""
$content += "========================================"
$content += "6. Tech and QA Enhancements (Later Phases)"
$content += "========================================"
$content += "- Extra Playwright tests for new puzzle types."
$content += "- Optional visual regression or screenshot comparisons."
$content += "- CI integration to run the Daily Phase on each change."
$content += ""

$content | Set-Content -Path $backlogPath -Encoding UTF8

Write-Host "[OK] Backlog written to:" -ForegroundColor Green
Write-Host "  $backlogPath" -ForegroundColor Green
