import { test, expect } from "@playwright/test";

// Daily result UI test:
// - Opens app via backend (8085)
// - Navigates to Daily area
// - Clicks an answer button
// - Verifies some kind of result/next-step text appears

const HOME_URL =
  process.env.MINDLAB_HOME_URL ?? "http://localhost:8085/app";

test("Daily puzzle result UI shows feedback after answering", async ({ page }) => {
  // 1) Navigate to the main app
  const response = await page.goto(HOME_URL, { waitUntil: "networkidle" });
  expect(response?.ok()).toBeTruthy();

  await expect(page.locator("body")).toBeVisible();

  // 2) Navigate to the Daily area using flexible selectors
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

  await page.waitForLoadState("networkidle");

  // 3) Find answer buttons and click one
  const answerButtons = page.getByRole("button");
  await expect(answerButtons.first()).toBeVisible();
  await answerButtons.first().click();

  // Give UI a moment to update
  await page.waitForTimeout(1000);

  // 4) Look for any reasonable result/feedback text
  const patterns = [
    /correct/i,
    /incorrect/i,
    /result/i,
    /streak/i,
    /completed/i,
    /complete/i,
    /next/i,
    /continue/i,
  ];

  let found = false;
  for (const pattern of patterns) {
    const locator = page.getByText(pattern, { exact: false });
    if (await locator.count()) {
      await expect(locator.first()).toBeVisible();
      found = true;
      break;
    }
  }

  expect(found).toBeTruthy();
});
