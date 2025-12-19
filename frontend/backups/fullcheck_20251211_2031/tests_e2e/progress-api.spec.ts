import { test, expect } from "@playwright/test";

// Use explicit IPv4 to avoid ::1/IPv6 issues
const BACKEND_URL = "http://127.0.0.1:8085";

test("Progress API returns valid stats (LOCAL)", async ({ request }) => {
  // 1. Call /progress on local backend
  const response = await request.get(`${BACKEND_URL}/progress`);

  // Allow any 2xx or 3xx
  expect(response.status()).toBeLessThan(400);

  // 2. Basic shape checks
  const data = await response.json();
  expect(typeof data).toBe("object");

  const anyData = data as any;

  const total =
    anyData.total ?? anyData.totalPuzzles ?? anyData.total_count;

  const correct =
    anyData.correct ?? anyData.solved ?? anyData.correct_count;

  const percent =
    anyData.percent ?? anyData.percentage ?? anyData.success_rate;

  if (typeof total === "number") {
    expect(total).toBeGreaterThan(0);
  }

  if (typeof correct === "number" && typeof total === "number") {
    expect(correct).toBeGreaterThanOrEqual(0);
    expect(correct).toBeLessThanOrEqual(total);
  }

  if (typeof percent === "number") {
    expect(percent).toBeGreaterThanOrEqual(0);
    expect(percent).toBeLessThanOrEqual(100);
  }
});
