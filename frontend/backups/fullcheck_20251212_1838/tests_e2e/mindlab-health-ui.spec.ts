import { test, expect } from "@playwright/test";

test.describe("MindLab Health / Home UI", () => {
  test("Home dashboard basic smoke test", async ({ page }) => {
    // Go to the main app dashboard
    await page.goto("http://localhost:5177/app");

    // The main heading with the app name should be visible
    await expect(
      page.getByRole("heading", { name: /mindlab frontend/i })
    ).toBeVisible();

    // Health section should be visible
    await expect(
      page.getByRole("heading", { name: /health/i })
    ).toBeVisible();

    // Puzzles and Progress sections should also be present
    await expect(
      page.getByRole("heading", { name: /puzzles/i })
    ).toBeVisible();

    await expect(
      page.getByRole("heading", { name: /progress/i })
    ).toBeVisible();

    // Regression guard: we MUST NOT see the old JSON/HTML parse error
    const badError = page.getByText(/unexpected token</i);
    await expect(badError).toHaveCount(0);
  });
});
