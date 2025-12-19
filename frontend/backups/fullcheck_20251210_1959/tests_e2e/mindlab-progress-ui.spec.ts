import { test, expect } from "@playwright/test";

test.describe("MindLab Progress UI", () => {
  test("Progress page basic smoke test", async ({ page }) => {
    // Go directly to the progress page
    await page.goto("http://localhost:5177/app/progress");

    // There should be a heading containing "Progress"
    await expect(
      page.getByRole("heading", { name: /progress/i })
    ).toBeVisible();

    // Either loading, error, or stats should be visible
    const loading = page.getByText(/loading progress/i);
    const error = page.getByText(/error loading progress/i);
    const solved = page.getByText(/puzzles solved/i);

    // At least one of them should appear
    await expect(
      loading.or(error).or(solved)
    ).toBeVisible();
  });
});
