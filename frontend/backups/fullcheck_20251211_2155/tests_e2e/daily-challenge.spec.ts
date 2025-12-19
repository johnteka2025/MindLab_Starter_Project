import { test, expect } from "@playwright/test";

// NOTE: These tests are initially skipped until the Daily Challenge feature is implemented.
test.skip("Daily Challenge entry point appears on home page", async ({ page }) => {
  await page.goto("http://localhost:5177/", { waitUntil: "networkidle" });

  // EXPECTATION (once feature is built):
  // - There is a visible link or button labeled "Daily Challenge"
  const dailyLink = page.getByRole("link", { name: /daily challenge/i });
  await expect(dailyLink).toBeVisible();
});

test.skip("Daily Challenge page loads and shows puzzle content", async ({ page }) => {
  // Once implemented, this URL should be whatever route you choose for daily mode.
  await page.goto("http://localhost:5177/daily", { waitUntil: "networkidle" });

  // Basic expectations for the new page.
  await expect(page.getByRole("heading", { name: /daily challenge/i })).toBeVisible();

  // Example: check that there is at least one puzzle item visible.
  // Adjust selectors as you implement the real UI.
  const puzzleItems = page.locator("[data-test-id='daily-puzzle-item']");
  await expect(puzzleItems).toHaveCountGreaterThan(0);
});
