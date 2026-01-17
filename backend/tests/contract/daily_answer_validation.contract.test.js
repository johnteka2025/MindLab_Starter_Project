const base = process.env.CONTRACT_BASE_URL || "http://localhost:8085";

async function jget(path) {
  const res = await fetch(`${base}${path}`);
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch {}
  return { res, json };
}

async function jpost(path, body) {
  const res = await fetch(`${base}${path}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch {}
  return { res, json };
}

describe("daily answer validation contract", () => {

  test("rejects answering same puzzle twice", async () => {
    const daily = await jget("/daily");
    const puzzleId = daily.json.puzzles[0].id;

    const first = await jpost("/daily/answer", { puzzleId });
    expect(first.res.status).toBe(200);

    const second = await jpost("/daily/answer", { puzzleId });
    expect(second.res.status).toBe(409);
  });

  test("rejects answers after challenge completed", async () => {
    const daily = await jget("/daily");

    for (const p of daily.json.puzzles) {
      await jpost("/daily/answer", { puzzleId: p.id });
    }

    const extra = await jpost("/daily/answer", { puzzleId: daily.json.puzzles[0].id });
    expect(extra.res.status).toBe(409);
  });

});