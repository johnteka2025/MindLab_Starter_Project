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
