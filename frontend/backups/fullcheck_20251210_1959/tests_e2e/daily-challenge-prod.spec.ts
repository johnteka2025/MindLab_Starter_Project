import { test, expect } from "@playwright/test";

// NOTE: Initially skipped until the Daily Challenge feature is live in PROD.
const PROD_BASE = "https://mindlab-swpk.onrender.com";

test.skip("PROD: Daily Challenge entry point appears on home page", async ({ page }) => {
  await page.goto(PROD_BASE, { waitUntil: "networkidle" });

  const dailyLink = page.getByRole("link", { name: /daily challenge/i });
  await expect(dailyLink).toBeVisible();
});

test.skip("PROD: Daily Challenge page loads and shows puzzle content", async ({ page }) => {
  await page.goto(PROD_BASE + "/daily", { waitUntil: "networkidle" });

  await expect(page.getByRole("heading", { name: /daily challenge/i })).toBeVisible();

  const puzzleItems = page.locator("[data-test-id='daily-puzzle-item']");
  await expect(puzzleItems).toHaveCountGreaterThan(0);
});
