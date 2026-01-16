const base = process.env.CONTRACT_BASE_URL || "http://localhost:8085";

async function jget(path) {
  const res = await fetch(`${base}${path}`);
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch {}
  return { res, text, json };
}

async function jpost(path, body) {
  const res = await fetch(`${base}${path}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body ?? {}),
  });
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch {}
  return { res, text, json };
}

describe("daily challenge api contract", () => {
  test("GET /daily returns instance with puzzles", async () => {
    const { res, json } = await jget("/daily");
    expect(res.status).toBe(200);
    expect(json).toBeTruthy();
    expect(typeof json.dailyChallengeId).toBe("string");
    expect(Array.isArray(json.puzzles)).toBe(true);
    if (json.puzzles.length > 0) {
      expect(json.puzzles[0]).toHaveProperty("id");
      expect(typeof json.puzzles[0].question).toBe("string");
    }
  });

  test("GET /daily/status returns status + progress + streak", async () => {
    const { res, json } = await jget("/daily/status");
    expect(res.status).toBe(200);
    expect(json).toBeTruthy();
    expect(["not_started", "in_progress", "completed"]).toContain(json.status);
    expect(typeof json.progress).toBe("number");
    expect(typeof json.streak).toBe("number");
    expect(typeof json.dailyChallengeId).toBe("string");
  });

  test("POST /daily/answer accepts required payload (status + shape only)", async () => {
    const daily = await jget("/daily");
    expect(daily.res.status).toBe(200);

    const dailyId = daily.json.dailyChallengeId;
    const first = (daily.json.puzzles || [])[0];
    expect(first).toBeTruthy();

    // Contract only: endpoint accepts payload. Correctness depends on answer content.
    const body = {
      dailyChallengeId: String(dailyId),
      puzzleId: String(first.id),
      answer: "test",
    };

    const { res, json, text } = await jpost("/daily/answer", body);
    expect([200, 204]).toContain(res.status);

    if (res.status === 200) {
      expect(json).toBeTruthy();
      expect(typeof json.ok).toBe("boolean");
    } else {
      expect(text === "" || text == null).toBe(true);
    }
  });

  test("POST /daily/answer rejects missing body (400/415 acceptable)", async () => {
    const res = await fetch(`${base}/daily/answer`, { method: "POST" });
    expect([400, 415]).toContain(res.status);
  });
});