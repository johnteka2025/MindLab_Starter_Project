import { test, expect } from "@playwright/test";

// Daily UI entrypoint: prefer env var, fall back to dev URL.
const DAILY_URL =
  process.env.DAILY_UI_URL ||
  "http://localhost:5177/app/daily";

test("Daily challenge page loads and basic UI or error state is visible", async ({ page }) => {
  // 1) Load the Daily Challenge page
  const response = await page.goto(DAILY_URL, { waitUntil: "networkidle" });
  expect(response?.ok(), "Daily URL should return a successful HTTP status").toBeTruthy();

  // 2) Main heading should always be there
  await expect(
    page.getByRole("heading", { name: "Daily Challenge" })
  ).toBeVisible();

  // 3) Try to detect a puzzle label and the error message in parallel
  const puzzleLabel = page.getByText("Daily Puzzle 1", { exact: false }).first();
  const errorLabel = page.getByText(/Error loading daily challenge/i);

  const puzzleVisible = await puzzleLabel.isVisible().catch(() => false);
  const errorVisible  = await errorLabel.isVisible().catch(() => false);

  if (puzzleVisible) {
    // === Happy path: puzzles loaded ===
    await expect(puzzleLabel).toBeVisible();

    // Answer input visible
    await expect(
      page.getByRole("textbox", { name: /your answer/i })
    ).toBeVisible();

    // Submit button visible (match any "submit" wording)
    await expect(
      page.getByRole("button", { name: /submit/i })
    ).toBeVisible();
  } else {
    // === Fallback path: no puzzles; we at least expect the error message ===
    await expect(
      page.getByText(/Error loading daily challenge/i)
    ).toBeVisible();
  }
});
