// tests/e2e/mindlab-game-flow.spec.ts

import { test, expect } from "@playwright/test";

const HOME_URL = "http://localhost:5177/app";
const DAILY_URL = "http://localhost:5177/app/daily";
const PROGRESS_URL = "http://localhost:5177/app/progress";

/**
 * Scenario 1:
 * User can visit Home, Daily, and Progress pages without errors.
 */
test("MindLab Game Flow UI › User can view Home, Daily, and Progress pages without errors", async ({
  page,
}) => {
  // Go to Home
  await page.goto(HOME_URL);
  await expect(
    page.getByRole("heading", { name: "MindLab Frontend" }),
  ).toBeVisible();

  // Go to Daily
  await page.goto(DAILY_URL);
  await expect(
    page.getByRole("heading", { name: /Daily Challenge/i }),
  ).toBeVisible();

  // Go to Progress
  await page.goto(PROGRESS_URL);
  await expect(
    page.getByRole("heading", { name: /Progress/i }),
  ).toBeVisible();
});

/**
 * Scenario 2:
 * User can go from Daily to Progress and see the overall progress summary.
 */
test("MindLab Game Flow UI › User can visit Daily then Progress and see overall progress summary", async ({
  page,
}) => {
  // Start on Daily page
  await page.goto(DAILY_URL);
  await expect(
    page.getByRole("heading", { name: /Daily Challenge/i }),
  ).toBeVisible();

  // Now go to Progress page
  await page.goto(PROGRESS_URL);
  await expect(
    page.getByRole("heading", { name: /Progress/i }),
  ).toBeVisible();

  // Check that the progress summary text is shown
  // (this matches the text used on the Progress page)
  await expect(page.getByText(/puzzles solved/i)).toBeVisible();
});
