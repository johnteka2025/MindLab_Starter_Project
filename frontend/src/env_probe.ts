// src/env_probe.ts
// PROOF: what Vite injected into the browser bundle (not Node process.env)
console.log("[ENV_PROBE] import.meta.env.VITE_API_BASE_URL =", import.meta.env.VITE_API_BASE_URL);
console.log("[ENV_PROBE] keys =", Object.keys(import.meta.env || {}));
