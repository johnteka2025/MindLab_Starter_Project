const base = process.env.CONTRACT_BASE_URL || "http://localhost:8085";

async function jget(path) {
  const res = await fetch(`${base}${path}`);
  const json = await res.json();
  return { res, json };
}

describe("daily rollover behavior", () => {
  test("new UTC day produces new dailyChallengeId", async () => {
    const day1 = await jget("/daily");
    const day2 = await jget("/daily");

    expect(day1.res.status).toBe(200);
    expect(day2.res.status).toBe(200);
    expect(day1.json.dailyChallengeId).toBe(day2.json.dailyChallengeId);
  });
});