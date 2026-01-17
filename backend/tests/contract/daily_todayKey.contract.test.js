/**
 * Contract: daily endpoints must be stable across UTC boundaries.
 * We do not import getTodayKey directly because it is not exported in CJS.
 */
const base = process.env.CONTRACT_BASE_URL || "http://localhost:8085";

async function jget(path) {
  const res = await fetch(`${base}${path}`);
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch {}
  return { res, text, json };
}

describe("daily getTodayKey contract", () => {
  test("GET /daily returns a stable dailyChallengeId string", async () => {
    const { res, json } = await jget("/daily");
    expect(res.status).toBe(200);
    expect(json).toBeTruthy();
    expect(typeof json.dailyChallengeId).toBe("string");
    expect(json.dailyChallengeId.length).toBeGreaterThan(5);
  });

  test("GET /daily and /daily/status refer to same dailyChallengeId", async () => {
    const daily = await jget("/daily");
    expect(daily.res.status).toBe(200);

    const status = await jget("/daily/status");
    expect(status.res.status).toBe(200);

    expect(status.json).toBeTruthy();
    expect(typeof status.json.dailyChallengeId).toBe("string");
    expect(status.json.dailyChallengeId).toBe(daily.json.dailyChallengeId);
  });
});