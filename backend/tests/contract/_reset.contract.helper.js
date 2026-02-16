"use strict";

const base = process.env.CONTRACT_BASE_URL || "http://localhost:8085";

async function resetServerState() {
  const res = await fetch(`${base}/__test__/reset`, { method: "POST" });
  if (res.status !== 204) {
    const text = await res.text().catch(() => "");
    throw new Error(`RESET_FAILED status=${res.status} body=${text}`);
  }
}

module.exports = { resetServerState };
