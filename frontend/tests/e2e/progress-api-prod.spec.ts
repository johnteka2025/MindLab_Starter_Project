import { test, expect } from "@playwright/test";

// PROD backend base URL (Render)
const BACKEND_URL = "https://mindlab-swpk.onrender.com";

test("PROD: Progress API returns valid stats", async ({ request }) => {
  // 1. Call the PROD /progress endpoint
  const response = await request.get(`${BACKEND_URL}/progress`);

  // 2. Basic status code check – accept anything under 400
  expect(response.status(), "HTTP status should be < 400").toBeLessThan(400);

  // 3. Light JSON sanity (do NOT assume exact schema)
  const data = await response.json();

  // Ensure we got some JSON object with at least one key
  expect(typeof data, "response JSON should be an object").toBe("object");
  expect(Object.keys(data).length, "JSON should have at least one property").toBeGreaterThan(0);
});
