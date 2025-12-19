import { test, expect } from "@playwright/test";

test.describe("MindLab Daily UI (Optional → Now Enforced)", () => {
  test("Daily page shows puzzles list and at least one puzzle item", async ({ page }) => {
    await page.goto("http://localhost:5177/app/daily", { waitUntil: "domcontentloaded" });

    await expect(page.getByRole("heading", { name: "Daily Challenge" })).toBeVisible();

    const list = page.getByTestId("daily-puzzles-list");
    await expect(list).toBeVisible();

    const items = page.getByTestId("daily-puzzle-item");
    await expect(items.first()).toBeVisible();
  });
});
