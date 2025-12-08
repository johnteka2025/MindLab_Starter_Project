import { test, expect } from "@playwright/test";

/**
 * Daily UI test:
 * - Uses DAILY_UI_URL env var if set, otherwise falls back to Vite dev.
 * - Only requires that the Daily Challenge heading is visible.
 *   This passes whether the backend is healthy or showing an error.
 */

const DEFAULT_DAILY_URL = "http://localhost:5177/app/daily";
const DAILY_UI_URL = process.env.DAILY_UI_URL || DEFAULT_DAILY_URL;

test("Daily challenge page loads and heading is visible", async ({ page }) => {
  // Navigate, but allow any HTTP status (200, 404, etc.)
  const response = await page.goto(DAILY_UI_URL, { waitUntil: "networkidle" });
  expect(response).not.toBeNull();

  // Basic sanity: we should see the Daily Challenge heading text
  await expect(
    page.getByRole("heading", { name: /daily challenge/i })
  ).toBeVisible();
});
