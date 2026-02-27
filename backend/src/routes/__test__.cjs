const express = require("express");
const router = express.Router();

/**
 * Deterministic reset used by contract tests.
 * MUST clear in-memory daily answered/completed state + persisted progress.
 */
async function doReset() {
  // Daily reset hook (must be exported by daily routes/module)
  const dailyRoutes = require("./daily.cjs");
  if (!dailyRoutes || typeof dailyRoutes.resetDailyChallengeState !== "function") {
    console.error("[__test__/reset] missing resetDailyChallengeState export");
    throw new Error("RESET_HOOK_MISSING");
  }
  await dailyRoutes.resetDailyChallengeState();

  // Progress persistence hook (best-effort)
  try {
    const pp = require("../progressPersistence.cjs");
    if (pp && typeof pp.resetProgressPersistence === "function") {
      await pp.resetProgressPersistence();
    }
  } catch (_) { /* ignore */ }
}

async function handler(req, res) {
  try {
    await doReset();
    return res.status(204).end();
  } catch (e) {
    console.error("[__test__/reset] failed:", e && e.message ? e.message : e);
    return res.status(500).json({ error: "RESET_FAILED" });
  }
}

router.post("/__test__/reset", handler);
router.post("/reset", handler);
router.post("/api/reset", handler);
router.post("/api/__test__/reset", handler);

module.exports = router;