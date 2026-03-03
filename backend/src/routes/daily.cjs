'use strict';

// SHIM: routes/__test__.cjs expects require('./daily.cjs')
// Real implementation lives here:
const real = require('../daily-challenge/dailyChallengeRoutes.cjs');

// Ensure reset export exists (no-op fallback)
if (!real.resetDailyChallengeState) {
  real.resetDailyChallengeState = async function resetDailyChallengeState(){ return; };
}

module.exports = real;
