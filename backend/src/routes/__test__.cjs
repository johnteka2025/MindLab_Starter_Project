"use strict";



const dailyRoutes = require("../daily-challenge/dailyChallengeRoutes.cjs");
const progressPersistence = require("../progressPersistence.cjs");
let router;
try {
  // Express-style router if express exists
  const express = require("express");
  router = express.Router();
} catch {
  router = null;
}

function isTestMode() {
  const v = String(process.env.MINDLAB_TEST_MODE || "").toLowerCase();
  return v === "1" || v === "true";
}

async function doReset() {
  // Aggressive reset for contract determinism
  try {
    const fs = require("fs");
    const path = require("path");

    const dataDir = path.join(__dirname, "..", "data");

    // Known persistence files (delete or empty)
    const files = [
      path.join(dataDir, "progress.json"),
      path.join(dataDir, "daily.json"),
      path.join(dataDir, "daily_state.json"),
      path.join(dataDir, "answers.json")
    ];

    for (const f of files) {
      try {
        if (fs.existsSync(f)) fs.writeFileSync(f, "{}", "utf8");
      } catch {}
    }

    // Also clear any *.json files in dataDir (best-effort)
    try {
      if (fs.existsSync(dataDir)) {
        for (const name of fs.readdirSync(dataDir)) {
          if (name.toLowerCase().endsWith(".json")) {
            const f = path.join(dataDir, name);
            try { fs.writeFileSync(f, "{}", "utf8"); } catch {}
          }
        }
      }
    } catch {}
    // NOTE: DO NOT clear require.cache here; it breaks live-instance reset.
} catch {}

      // Clear daily answered state to prevent 409 on first contract submit
    /* ASSERT_DAILY_RESET_HOOK */
try {
if (!dailyRoutes || typeof dailyRoutes.resetDailyChallengeState !== "function") {
    console.error("[__test__/reset] missing resetDailyChallengeState export");
    throw new Error("RESET_HOOK_MISSING");
  }
  await dailyRoutes.resetDailyChallengeState();

  if (progressPersistence && typeof progressPersistence.resetProgressPersistence === 'function') {
    await progressPersistence.resetProgressPersistence();
  }
} catch (e) {
  console.error("[__test__/reset] failed:", e && e.message ? e.message : e);
  throw e;
}
/* ASSERT_DAILY_RESET_HOOK */return true;
  }

// Express handler
if (router) {
  router.post("/__test__/reset", async (req, res) => {
    if (!isTestMode()) return res.status(404).end();
    try { await doReset(); return 
// CLEAR_DAILY_ANSWERED_STATE (contract gate)
try{
  const daily = require('../daily-challenge/dailyChallengeRoutes.cjs');
  if (daily && typeof daily.__clearDailyAnsweredState === 'function') {
    daily.__clearDailyAnsweredState();
  }
} catch (_) { /* ignore */ }
  // CLEAR_DAILY_ANSWERED_AND_PROGRESS
  try {
    const daily = require("../daily-challenge/dailyChallengeRoutes.cjs");
    if (daily && typeof daily.__clearDailyAnsweredState === "function") {
      daily.__clearDailyAnsweredState();
    }
  } catch (_) { /* ignore */ }

  try {
    const fs = require("fs");
    const path = require("path");
    const p = path.join(__dirname, "..", "data", "progress.json");
    if (fs.existsSync(p)) fs.unlinkSync(p);
  } catch (_) { /* ignore */ }
res.status(204).end(); }
    catch { return res.status(500).json({ error: "reset_failed" }); }
  });

  module.exports = router;
} else {
  // Non-express fallback: export a function so you can mount it manually
  module.exports = function mountTestRoutes(app) {
    // If your framework supports it, implement equivalent POST /__test__/reset here.
    return app;
  };
}






