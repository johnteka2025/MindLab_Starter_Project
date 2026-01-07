import React, { useEffect, useMemo, useState } from "react";

type Puzzle = {
  id: number;
  question: string;
  options: string[];
  correctIndex: number;
};

type Progress = {
  total: number;
  solved: number;
  solvedToday?: number;
  totalSolved?: number;
  solvedPuzzleIds?: Record<string, boolean>;
};

function getApiBase(): string {
  // Works whether you use .env.local or not; falls back to localhost backend
  // If you already have an api.ts, you can wire this into it later.
  const env = (import.meta as any).env;
  return (env?.VITE_API_BASE_URL as string) || "http://localhost:8085";
}

async function fetchJson<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, init);
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`${res.status} ${res.statusText} :: ${text}`);
  }
  return res.json();
}

export default function PuzzlesPlay() {
  const API = useMemo(() => getApiBase(), []);
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [progress, setProgress] = useState<Progress | null>(null);
  const [selected, setSelected] = useState<Record<number, number>>({});
  const [msg, setMsg] = useState<string>("");

  async function refreshAll() {
    setMsg("");
    const pz = await fetchJson<Puzzle[]>(`${API}/puzzles`);
    setPuzzles(pz);

    const pr = await fetchJson<any>(`${API}/progress`);
    // backend may return either progress object or {progress: {...}}; normalize:
    const normalized: Progress = pr?.progress ? pr.progress : pr;
    setProgress(normalized);
  }

  useEffect(() => {
    refreshAll().catch((e) => setMsg(String(e?.message || e)));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function solvePuzzle(puzzleId: number) {
    setMsg("");
    try {
      await fetchJson(`${API}/progress/solve`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ puzzleId }),
      });
      const pr = await fetchJson<any>(`${API}/progress`);
      const normalized: Progress = pr?.progress ? pr.progress : pr;
      setProgress(normalized);
    } catch (e: any) {
      setMsg(String(e?.message || e));
    }
  }

  async function resetProgress() {
    setMsg("");
    try {
      await fetchJson(`${API}/progress/reset`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: "{}",
      });
      await refreshAll();
    } catch (e: any) {
      setMsg(String(e?.message || e));
    }
  }

  return (
    <div style={{ padding: 16, fontFamily: "system-ui, Arial" }}>
      <h1>MindLab — Solve a Puzzle</h1>

      <div style={{ marginBottom: 12 }}>
        <button onClick={() => refreshAll()}>Refresh</button>{" "}
        <button onClick={() => resetProgress()}>Reset Progress</button>
      </div>

      {msg ? (
        <div style={{ whiteSpace: "pre-wrap", color: "crimson", marginBottom: 12 }}>
          {msg}
        </div>
      ) : null}

      <div style={{ marginBottom: 16 }}>
        <h2>Progress</h2>
        <div>
          {progress
            ? `${progress.solved} of ${progress.total} puzzles solved`
            : "Loading..."}
        </div>
      </div>

      <div>
        <h2>Puzzles</h2>
        {puzzles.length === 0 ? (
          <div>Loading...</div>
        ) : (
          puzzles.map((pz) => (
            <div
              key={pz.id}
              style={{
                border: "1px solid #ddd",
                padding: 12,
                marginBottom: 10,
                borderRadius: 6,
              }}
            >
              <div style={{ fontWeight: 700, marginBottom: 8 }}>
                #{pz.id}: {pz.question}
              </div>

              <div style={{ marginBottom: 10 }}>
                {pz.options.map((opt, idx) => (
                  <label key={idx} style={{ display: "block", cursor: "pointer" }}>
                    <input
                      type="radio"
                      name={`pz-${pz.id}`}
                      value={idx}
                      checked={selected[pz.id] === idx}
                      onChange={() => setSelected((s) => ({ ...s, [pz.id]: idx }))}
                    />{" "}
                    {opt}
                  </label>
                ))}
              </div>

              <button
                onClick={() => solvePuzzle(pz.id)}
                disabled={selected[pz.id] == null}
              >
                Mark as Solved
              </button>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
