"use strict";

const path = require("path");

const DEFAULT_RUNTIME_ENV = Object.freeze({
  PORT: "3100",
  MINDLAB_PERSISTENCE_ENABLED: "0",
  MINDLAB_PERSISTENCE_DATA_ROOT: path.resolve(__dirname, "data"),
  FRONTEND_API_BASE_URL: "http://127.0.0.1:3100"
});

function parsePort(value) {
  const raw = String(value ?? DEFAULT_RUNTIME_ENV.PORT).trim();
  const port = Number.parseInt(raw, 10);

  if (!Number.isInteger(port) || String(port) !== raw || port < 0 || port > 65535) {
    throw new Error(`INVALID_PORT :: ${raw}`);
  }

  return port;
}

function parseBooleanFlag(value) {
  const raw = String(value ?? "0").trim().toLowerCase();

  if (["1", "true", "yes", "on"].includes(raw)) {
    return true;
  }

  if (["0", "false", "no", "off", ""].includes(raw)) {
    return false;
  }

  throw new Error(`INVALID_BOOLEAN_FLAG :: ${value}`);
}

function normalizeDataRoot(value) {
  const raw = String(value || DEFAULT_RUNTIME_ENV.MINDLAB_PERSISTENCE_DATA_ROOT).trim();

  if (!raw) {
    throw new Error("MISSING_PERSISTENCE_DATA_ROOT");
  }

  return path.resolve(raw);
}

function normalizeFrontendApiBaseUrl(value) {
  const raw = String(value || DEFAULT_RUNTIME_ENV.FRONTEND_API_BASE_URL).trim();

  if (!raw) {
    throw new Error("MISSING_FRONTEND_API_BASE_URL");
  }

  let parsed;
  try {
    parsed = new URL(raw);
  } catch {
    throw new Error(`INVALID_FRONTEND_API_BASE_URL :: ${raw}`);
  }

  if (!["http:", "https:"].includes(parsed.protocol)) {
    throw new Error(`INVALID_FRONTEND_API_BASE_PROTOCOL :: ${parsed.protocol}`);
  }

  return raw.replace(/\/+$/, "");
}

function loadProductionRuntimeEnv(source = process.env, options = {}) {
  const defaults = {
    ...DEFAULT_RUNTIME_ENV,
    ...(options.defaults || {})
  };

  const config = Object.freeze({
    port: parsePort(source.PORT ?? defaults.PORT),
    persistenceEnabled: parseBooleanFlag(source.MINDLAB_PERSISTENCE_ENABLED ?? defaults.MINDLAB_PERSISTENCE_ENABLED),
    persistenceDataRoot: normalizeDataRoot(source.MINDLAB_PERSISTENCE_DATA_ROOT ?? defaults.MINDLAB_PERSISTENCE_DATA_ROOT),
    frontendApiBaseUrl: normalizeFrontendApiBaseUrl(source.FRONTEND_API_BASE_URL ?? defaults.FRONTEND_API_BASE_URL)
  });

  validateProductionRuntimeEnv(config, options);

  return config;
}

function validateProductionRuntimeEnv(config, options = {}) {
  if (!config || typeof config !== "object" || Array.isArray(config)) {
    throw new Error("INVALID_RUNTIME_CONFIG_OBJECT");
  }

  parsePort(config.port);
  normalizeDataRoot(config.persistenceDataRoot);
  normalizeFrontendApiBaseUrl(config.frontendApiBaseUrl);

  if (options.requirePersistence === true && config.persistenceEnabled !== true) {
    throw new Error("PERSISTENCE_REQUIRED_BUT_DISABLED");
  }

  return true;
}

module.exports = {
  DEFAULT_RUNTIME_ENV,
  loadProductionRuntimeEnv,
  normalizeDataRoot,
  normalizeFrontendApiBaseUrl,
  parseBooleanFlag,
  parsePort,
  validateProductionRuntimeEnv
};