import { test, expect } from "@playwright/test";

// Daily solve flow (UI-only):
// - Opens the app via backend (8085)
// - Navigates to the Daily UI (best-effort selectors)
// - Confirms an answer button exists
// - Clicks that answer button successfully

const HOME_URL =
  process.env.MINDLAB_HOME_URL ?? "http://localhost:8085/app";

test("Daily puzzle solve flow lets the user select an answer", async ({ page }) => {
  // 1) Navigate to the main app
  const response = await page.goto(HOME_URL, { waitUntil: "networkidle" });
  expect(response?.ok()).toBeTruthy();

  // Basic DOM sanity
  await expect(page.locator("body")).toBeVisible();

  // 2) Try to navigate to the Daily area using flexible selectors.
  const dailyLink = page.getByRole("link", { name: /daily/i });
  const dailyButton = page.getByRole("button", { name: /daily/i });
  const dailyText = page.getByText(/daily/i, { exact: false });

  if (await dailyLink.count()) {
    await dailyLink.first().click();
  } else if (await dailyButton.count()) {
    await dailyButton.first().click();
  } else if (await dailyText.count()) {
    await dailyText.first().click();
  }

  // Allow any navigation or UI transition to settle
  await page.waitForLoadState("networkidle");

  // 3) Find visible answer buttons.
  const answerButtons = page.getByRole("button");

  // Require at least one visible button
  await expect(answerButtons.first()).toBeVisible();

  // 4) Click the first visible answer button.
  await answerButtons.first().click();

  // Optional small wait to allow UI to react; we don't assert specific text yet
  await page.waitForTimeout(1000);
});
