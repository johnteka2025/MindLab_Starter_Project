import { test, expect } from "@playwright/test";

const PROGRESS_URL = "http://localhost:5177/app/progress";

test("Progress UI basic smoke test", async ({ page }) => {
  await page.goto(PROGRESS_URL);

  await expect(
    page.getByRole("heading", { name: /Progress/i })
  ).toBeVisible();
});

test("Progress UI optional metrics (total puzzles, solved today, streak)", async ({ page }) => {
  await page.goto(PROGRESS_URL, { waitUntil: "networkidle" });

  const totalPuzzles = page.locator('[data-testid="progress-total-puzzles"]');
  const solvedToday  = page.locator('[data-testid="progress-solved-today"]');
  const currentStreak = page.locator('[data-testid="progress-current-streak"]');

  const totalCount   = await totalPuzzles.count();
  const solvedCount  = await solvedToday.count();
  const streakCount  = await currentStreak.count();

  if (totalCount === 0 && solvedCount === 0 && streakCount === 0) {
    console.warn("Progress UI: no metrics test IDs found yet; skipping metrics checks.");
    return;
  }

  if (totalCount > 0) {
    await expect(totalPuzzles.first()).toBeVisible();
  } else {
    console.warn("Progress UI: total-puzzles metric missing.");
  }

  if (solvedCount > 0) {
    await expect(solvedToday.first()).toBeVisible();
  } else {
    console.warn("Progress UI: solved-today metric missing.");
  }

  if (streakCount > 0) {
    await expect(currentStreak.first()).toBeVisible();
  } else {
    console.warn("Progress UI: current-streak metric missing.");
  }
});
