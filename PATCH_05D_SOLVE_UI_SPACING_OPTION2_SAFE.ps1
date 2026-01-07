$ErrorActionPreference = "Stop"

$root  = "C:\Projects\MindLab_Starter_Project"
$solve = Join-Path $root "frontend\src\pages\SolvePuzzle.tsx"

if(!(Test-Path $solve)){ throw "STOP: Missing SolvePuzzle.tsx at: $solve" }

# Backup (non-negotiable)
$ts  = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$solve.bak_$ts"
Copy-Item $solve $bak -Force
Write-Host "OK: Backup created -> $bak"

$before = Get-Content $solve -Raw

function WrapSelectAfterHeader([string]$content, [string]$header){
  $headerIdx = $content.IndexOf($header)
  if($headerIdx -lt 0){
    throw "STOP: Header not found: $header"
  }

  # Find first <select after the header
  $selectStart = $content.IndexOf("<select", $headerIdx)
  if($selectStart -lt 0){
    throw "STOP: <select> not found after header: $header"
  }

  $selectEnd = $content.IndexOf("</select>", $selectStart)
  if($selectEnd -lt 0){
    throw "STOP: </select> not found after header: $header"
  }
  $selectEndInclusive = $selectEnd + "</select>".Length

  # Guard: refuse if it looks already wrapped nearby
  $lookbackStart = [Math]::Max(0, $selectStart - 200)
  $lookback = $content.Substring($lookbackStart, $selectStart - $lookbackStart)
  if($lookback -match "marginTop:\s*12"){
    throw "STOP: Looks already wrapped with marginTop:12 near header: $header (refusing to double-wrap)"
  }

  $selectBlock = $content.Substring($selectStart, $selectEndInclusive - $selectStart)

  $wrapped = @"
<div style={{ marginTop: 12 }}>
$selectBlock
</div>
"@

  # Replace exactly that one select block
  $newContent =
    $content.Substring(0, $selectStart) +
    $wrapped +
    $content.Substring($selectEndInclusive)

  return $newContent
}

# Guards (must exist)
if($before -notmatch "<h2>Difficulty</h2>"){ throw "STOP: Missing <h2>Difficulty</h2> marker" }
if($before -notmatch "<h2>Pick a puzzle</h2>"){ throw "STOP: Missing <h2>Pick a puzzle</h2> marker" }

# Wrap Difficulty select
$after1 = WrapSelectAfterHeader $before "<h2>Difficulty</h2>"

# Wrap Pick-a-puzzle select
$after2 = WrapSelectAfterHeader $after1 "<h2>Pick a puzzle</h2>"

# Final guard: ensure we inserted exactly 2 wrappers
$wrapCountBefore = ([regex]::Matches($before, "<div style=\{\{ marginTop: 12 \}\}>")).Count
$wrapCountAfter  = ([regex]::Matches($after2,  "<div style=\{\{ marginTop: 12 \}\}>")).Count
$delta = $wrapCountAfter - $wrapCountBefore
if($delta -ne 2){
  throw "STOP: Expected to add exactly 2 wrappers, but added $delta. Refusing to write."
}

# Write UTF-8 (NO BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($solve, $after2, $utf8NoBom)

Write-Host "OK: SolvePuzzle.tsx updated -> wrapped 2 <select> controls with marginTop:12 divs"
Write-Host "NEXT: Run sanity -> powershell -NoProfile -ExecutionPolicy Bypass -File `"$root\RUN_FULLSTACK_SANITY.ps1`""
