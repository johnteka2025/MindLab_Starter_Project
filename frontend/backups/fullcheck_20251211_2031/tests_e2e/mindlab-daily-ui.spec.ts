import { test, expect } from "@playwright/test";

const DAILY_URL = "http://localhost:5177/app/daily";

test("Daily UI basic smoke test", async ({ page }) => {
  await page.goto(DAILY_URL);

  await expect(
    page.getByRole("heading", { name: /Daily/i })
  ).toBeVisible();
});

test("Daily UI gameplay â€“ open first puzzle and submit wrong answer when supported", async ({ page }) => {
  await page.goto(DAILY_URL, { waitUntil: "networkidle" });

  // Optional: puzzles list on the Daily page
  const puzzlesList = page.locator('[data-testid="puzzles-list"]');
  const listCount = await puzzlesList.count();

  if (listCount === 0) {
    console.warn("Daily UI: no puzzles list found yet; skipping gameplay checks.");
    return;
  }

  const firstPuzzle = puzzlesList.first();
  await firstPuzzle.click();

  // Optional: puzzle question element
  const question = page.locator('[data-testid="puzzle-question"]');
  const questionCount = await question.count();

  if (questionCount === 0) {
    console.warn("Daily UI: no puzzle-question test id; skipping answer flow checks.");
    return;
  }

  await expect(question.first()).toBeVisible();

  // Optional: answer input + submit button
  const answerInput = page.locator('[data-testid="puzzle-answer-input"]').first();
  const submitButton = page.locator('[data-testid="puzzle-submit-button"]').first();

  const hasAnswerInput = await answerInput.count();
  const hasSubmitButton = await submitButton.count();

  if (hasAnswerInput === 0 || hasSubmitButton === 0) {
    console.warn("Daily UI: missing answer input or submit button; skipping answer submission checks.");
    return;
  }

  // Try entering an obviously incorrect answer
  await answerInput.fill("WRONG-ANSWER");
  await submitButton.click();

  // Optional: feedback element after submission
  const feedback = page.locator('[data-testid="answer-feedback"]');
  const feedbackCount = await feedback.count();

  if (feedbackCount === 0) {
    console.warn("Daily UI: no answer-feedback element after submission.");
    return;
  }

  await expect(feedback.first()).toBeVisible();
});
