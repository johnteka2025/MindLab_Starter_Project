# write_daily_ui_optional_spec.ps1
# Generate Playwright spec for Optional Daily UI behaviors (syntax-safe, optional checks)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot   = "C:\Projects\MindLab_Starter_Project"
$frontendTests = Join-Path $projectRoot "frontend\tests\e2e"

if (-not (Test-Path $frontendTests)) {
    Write-Host "ERROR: E2E test folder not found: $frontendTests" -ForegroundColor Red
    exit 1
}

$specPath = Join-Path $frontendTests "mindlab-daily-ui-optional.spec.ts"

$specContent = @'
import { test, expect } from "@playwright/test";

const DAILY_URL = "http://localhost:5177/app/daily";

test("Optional Daily UI: puzzles list smoke check", async ({ page }) => {
  await page.goto(DAILY_URL, { waitUntil: "networkidle" });

  // Optional feature: puzzles list on the Daily page.
  // If it does not exist yet, log and exit without failing the test.
  const puzzlesList = page.locator('[data-testid="puzzles-list"]');
  const count = await puzzlesList.count();

  if (count === 0) {
    console.warn("Optional Daily UI: no puzzles list found yet (feature may not be implemented).");
    return;
  }

  await expect(puzzlesList.first()).toBeVisible();
});
'@

Write-Host "Writing Optional Daily UI spec to: $specPath"
$specContent | Out-File -FilePath $specPath -Encoding UTF8 -Force

Write-Host "Optional Daily UI spec written successfully." -ForegroundColor Green
exit 0
