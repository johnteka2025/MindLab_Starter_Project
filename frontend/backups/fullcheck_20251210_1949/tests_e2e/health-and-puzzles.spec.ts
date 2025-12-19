// C:\Projects\MindLab_Starter_Project\frontend\tests\e2e\health-and-puzzles.spec.ts

import { test, expect } from "@playwright/test";

test("health status and puzzles flow work", async ({ page }) => {
  // Open the frontend
  await page.goto("http://127.0.0.1:8085/app", { waitUntil: "networkidle" });

  // Health section
  await expect(
    page.getByRole("heading", { name: "MindLab Frontend" })
  ).toBeVisible({ timeout: 15000 });
  await expect(page.getByText(/Status:\s*ok/i)).toBeVisible({ timeout: 15000 });
  await expect(
    page.getByText("Backend is healthy (ok: true).")
  ).toBeVisible({ timeout: 15000 });

  // Puzzles section visible
  await expect(
    page.getByRole("heading", { name: "Puzzles" })
  ).toBeVisible({ timeout: 15000 });

  // Wait for at least one option button
  const optionButtons = page.getByRole("button");
  await expect(optionButtons.first()).toBeVisible({ timeout: 15000 });

  // Remember current question
  const questionLocator = page.locator("main").locator("text=/\\?/").first();
  const firstQuestion = await questionLocator.textContent();

  // Click first option
  await optionButtons.first().click();

  // Feedback appears
  await expect(
    page.locator("text=/Correct!|Not quite/")
  ).toBeVisible({ timeout: 5000 });

  // Next puzzle
  const nextButton = page.getByRole("button", { name: "Next puzzle" });
  await expect(nextButton).toBeVisible();
  await nextButton.click();

  const secondQuestion = await questionLocator.textContent();

  if (firstQuestion && secondQuestion) {
    expect(secondQuestion).not.toEqual(firstQuestion);
  }
});
