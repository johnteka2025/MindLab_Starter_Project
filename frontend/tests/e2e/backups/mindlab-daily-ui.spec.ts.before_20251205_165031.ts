import { test, expect } from "@playwright/test";

const DAILY_URL = process.env.DAILY_UI_URL ?? "http://localhost:5177/app/daily";

test("Daily challenge page loads", async ({ page }) => {
  const response = await page.goto(DAILY_URL, { waitUntil: "networkidle" });

  if (response) {
    const status = response.status();
    expect(status).toBeLessThan(400);
  }

  await expect(
    page.getByRole("heading", { name: /Daily Challenge/i })
  ).toBeVisible();
});

test("Daily challenge page shows puzzles list (optional but recommended)", async ({ page }) => {
  await page.goto(DAILY_URL, { waitUntil: "networkidle" });

  const list = page.locator("[data-testid='puzzles-list']");

  if (await list.count() > 0) {
    await expect(list.first()).toBeVisible();
  } else {
    console.warn("WARN: puzzles-list not found (may be feature-flagged).");
  }
});

test("Daily challenge page has a submit button (optional)", async ({ page }) => {
  await page.goto(DAILY_URL, { waitUntil: "networkidle" });

  const submitBtn = page.getByRole("button", { name: /Submit/i });

  if (await submitBtn.count() > 0) {
    await expect(submitBtn.first()).toBeVisible();
  } else {
    console.warn("WARN: Submit button not found (may depend on puzzle state).");
  }
});
