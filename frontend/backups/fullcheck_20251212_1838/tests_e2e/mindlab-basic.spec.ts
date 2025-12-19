import { test, expect } from "@playwright/test";

// Smoke test that the production-style MindLab homepage loads and
// talks to the backend. This uses the backend port (8085) where the
// app is served at /app in your stack.

const HOME_URL =
  process.env.MINDLAB_HOME_URL ?? "http://localhost:8085/app";

test("MindLab Homepage Loads + Talks to Backend", async ({ page }) => {
  // 1) Go to the MindLab app URL on the backend
  const response = await page.goto(HOME_URL, { waitUntil: "networkidle" });

  // Must be a successful HTTP status (2xx/3xx)
  expect(response?.ok()).toBeTruthy();

  // 2) Basic DOM sanity: something rendered on the page
  await expect(page.locator("body")).toBeVisible();
});
