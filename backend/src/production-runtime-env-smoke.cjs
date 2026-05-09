"use strict";

const assert = require("assert");
const os = require("os");
const path = require("path");
const {
  DEFAULT_RUNTIME_ENV,
  loadProductionRuntimeEnv,
  normalizeFrontendApiBaseUrl,
  parseBooleanFlag,
  parsePort,
  validateProductionRuntimeEnv
} = require("./production-runtime-env.cjs");

function runRuntimeEnvSmoke() {
  assert.strictEqual(parsePort("3100"), 3100);
  assert.strictEqual(parsePort("0"), 0);
  assert.strictEqual(parseBooleanFlag("1"), true);
  assert.strictEqual(parseBooleanFlag("true"), true);
  assert.strictEqual(parseBooleanFlag("0"), false);
  assert.strictEqual(parseBooleanFlag("false"), false);
  assert.strictEqual(normalizeFrontendApiBaseUrl("http://127.0.0.1:3100/"), "http://127.0.0.1:3100");

  const dataRoot = path.join(os.tmpdir(), "mindlab-runtime-env-smoke-data");
  const config = loadProductionRuntimeEnv({
    PORT: "3100",
    MINDLAB_PERSISTENCE_ENABLED: "1",
    MINDLAB_PERSISTENCE_DATA_ROOT: dataRoot,
    FRONTEND_API_BASE_URL: "http://127.0.0.1:3100"
  }, {
    requirePersistence: true
  });

  assert.strictEqual(config.port, 3100);
  assert.strictEqual(config.persistenceEnabled, true);
  assert.strictEqual(config.persistenceDataRoot, path.resolve(dataRoot));
  assert.strictEqual(config.frontendApiBaseUrl, "http://127.0.0.1:3100");
  assert.strictEqual(validateProductionRuntimeEnv(config, { requirePersistence: true }), true);

  const defaults = loadProductionRuntimeEnv({}, {
    defaults: DEFAULT_RUNTIME_ENV
  });

  assert.strictEqual(defaults.port, 3100);
  assert.strictEqual(defaults.persistenceEnabled, false);

  console.log("PASS: PRODUCTION_RUNTIME_ENV_SMOKE_PASS");
}

try {
  runRuntimeEnvSmoke();
} catch (error) {
  console.error("FAIL: PRODUCTION_RUNTIME_ENV_SMOKE_FAILED");
  console.error(error);
  process.exitCode = 1;
}

module.exports = {
  runRuntimeEnvSmoke
};