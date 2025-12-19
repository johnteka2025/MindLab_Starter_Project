import { test, expect } from "@playwright/test";

// Production-style smoke test:
// - Confirms the MindLab app homepage is reachable
// - Confirms key backend endpoints are healthy

const HOME_URL =
  process.env.MINDLAB_HOME_URL ?? "http://localhost:8085/app";

const BACKEND_BASE_URL =
  process.env.MINDLAB_BACKEND_URL ?? "http://localhost:8085";

test("PROD: MindLab app loads and backend endpoints are healthy", async ({ page, request }) => {
  // 1) Go to the MindLab app homepage
  const pageResponse = await page.goto(HOME_URL, { waitUntil: "networkidle" });

  // Homepage must return a successful HTTP status (2xx/3xx)
  expect(pageResponse?.ok()).toBeTruthy();

  // Basic DOM sanity: something rendered on the page
  await expect(page.locator("body")).toBeVisible();

  // 2) Backend endpoints sanity (health + puzzles + progress)
  const health = await request.get(`${BACKEND_BASE_URL}/health`);
  expect(health.ok()).toBeTruthy();

  const puzzles = await request.get(`${BACKEND_BASE_URL}/puzzles`);
  expect(puzzles.ok()).toBeTruthy();

  const progress = await request.get(`${BACKEND_BASE_URL}/progress`);
  expect(progress.ok()).toBeTruthy();
});
