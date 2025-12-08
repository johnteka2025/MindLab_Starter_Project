import { test, expect } from "@playwright/test";

const DAILY_URL = process.env.DAILY_UI_URL ?? "http://localhost:5177/app/daily";

test.describe("Daily Challenge UI", () => {
  test("Daily page loads and main heading is visible", async ({ page }) => {
    // Navigate and wait for network to go idle
    const response = await page.goto(DAILY_URL, { waitUntil: "networkidle" });

    // Basic HTTP sanity: we should not hit 4xx/5xx
    if (response) {
      const status = response.status();
      expect(status).toBeLessThan(400);
    }

    // Main heading
    await expect(
      page.getByRole("heading", { name: /Daily Challenge/i })
    ).toBeVisible();

    // OPTIONAL: puzzles list (feature-flag friendly)
    const puzzlesList = page.locator('[data-testid="puzzles-list"]');
    if (await puzzlesList.count()) {
      await expect(puzzlesList.first()).toBeVisible();
    }

    // OPTIONAL: submit button (feature-flag friendly)
    const submitButtons = page.getByRole("button", { name: /submit/i });
    if (await submitButtons.count()) {
      await expect(submitButtons.first()).toBeEnabled();
    }
  });
});
