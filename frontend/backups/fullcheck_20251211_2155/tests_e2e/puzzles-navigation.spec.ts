import { test, expect } from "@playwright/test";

// We use the backend production URL that serves the built frontend.
const BASE_URL = "http://127.0.0.1:8085/app";

test("user can solve puzzles and go to next question", async ({ page }) => {
  // Open the app
  await page.goto(BASE_URL, { waitUntil: "networkidle" });

  // Basic sanity: main heading is visible
  await expect(
    page.getByRole("heading", { name: /MindLab Frontend/i })
  ).toBeVisible({ timeout: 15000 });

  // Puzzles section should be visible
  await expect(
    page.getByRole("heading", { name: /Puzzles/i })
  ).toBeVisible({ timeout: 15000 });

  // First puzzle should be "What is 2 + 2?"
  const firstQuestion = page.getByText("What is 2 + 2?");
  await expect(firstQuestion).toBeVisible({ timeout: 15000 });

  // Click the correct answer "4"
  await page.getByRole("button", { name: "4" }).click();

  // We should see positive feedback "Correct!"
  await expect(page.getByText(/Correct!/i)).toBeVisible({ timeout: 5000 });

  // Click "Next puzzle"
  await page.getByRole("button", { name: /Next puzzle/i }).click();

  // Second puzzle should be "What is the color of the sky?"
  const secondQuestion = page.getByText("What is the color of the sky?");
  await expect(secondQuestion).toBeVisible({ timeout: 15000 });

  // Intentionally click a wrong answer "Red"
  await page.getByRole("button", { name: "Red" }).click();

  // We should see negative feedback like "Not quite"
  await expect(page.getByText(/Not quite/i)).toBeVisible({ timeout: 5000 });
});
