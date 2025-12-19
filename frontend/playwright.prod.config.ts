import { defineConfig } from "@playwright/test";

// PROD-only config:
// - Runs ONLY *-prod.spec.*
// - Ignores backups
const HOME_URL = process.env.MINDLAB_HOME_URL ?? "https://mindlab-swpk.onrender.com/app";

export default defineConfig({
  testDir: "./tests/e2e",
  testMatch: ["**/*-prod.spec.*"],
  testIgnore: ["**/backups/**"],
  timeout: 30_000,
  retries: 0,
  use: {
    baseURL: HOME_URL,
    trace: "on-first-retry",
  },
  reporter: [["html", { open: "never" }]],
});