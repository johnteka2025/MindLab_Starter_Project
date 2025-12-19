import React, { useEffect, useMemo, useState } from "react";

type Puzzle = {
  id: number | string;
  question: string;
  options?: string[];
  correctIndex?: number;
};

const API_BASE = "http://localhost:8085";

export default function DailyChallengeDetailPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const [solveLoading, setSolveLoading] = useState(false);
  const [solveError, setSolveError] = useState<string | null>(null);
  const [solveOk, setSolveOk] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const res = await fetch(`${API_BASE}/puzzles`, { method: "GET" });
        if (!res.ok) throw new Error(`GET /puzzles failed: ${res.status}`);
        const json = (await res.json()) as Puzzle[];

        if (!cancelled) {
          const arr = Array.isArray(json) ? json : [];
          setPuzzles(arr);
          setSelectedId(arr.length > 0 ? String(arr[0].id) : null);
        }
      } catch (e: any) {
        if (!cancelled) setError(e?.message ?? "Failed to load puzzles.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const selectedPuzzle = useMemo(() => {
    if (!selectedId) return null;
    return puzzles.find((p) => String(p.id) === selectedId) ?? null;
  }, [puzzles, selectedId]);

  async function markSolved() {
    if (!selectedPuzzle) return;

    setSolveLoading(true);
    setSolveError(null);
    setSolveOk(null);

    try {
      const res = await fetch(`${API_BASE}/progress/solve`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ puzzleId: selectedPuzzle.id }),
      });

      if (!res.ok) throw new Error(`POST /progress/solve failed: ${res.status}`);
      const json = await res.json();

      setSolveOk(`Solved recorded for puzzleId=${selectedPuzzle.id}`);
      // Keep UI simple: we do not mutate puzzles; progress page is the source of truth.
    } catch (e: any) {
      setSolveError(e?.message ?? "Failed to record solve.");
    } finally {
      setSolveLoading(false);
    }
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {loading && <p data-testid="daily-loading">Loading…</p>}

      {!loading && error && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          Failed to load puzzles. ({error})
        </p>
      )}

      {!loading && !error && (
        <>
          <h2>Puzzles</h2>

          <ul
            data-testid="daily-puzzles-list"
            style={{
              border: "1px solid #ddd",
              borderRadius: 8,
              padding: 12,
              listStylePosition: "inside",
              margin: 0,
              maxWidth: 720,
            }}
          >
            {puzzles.length === 0 ? (
              <li data-testid="daily-puzzles-empty">No puzzles available.</li>
            ) : (
              puzzles.map((p) => {
                const isSelected = String(p.id) === selectedId;
                return (
                  <li key={String(p.id)} style={{ marginBottom: 6 }}>
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedId(String(p.id));
                        setSolveOk(null);
                        setSolveError(null);
                      }}
                      data-testid="daily-puzzle-item"
                      style={{
                        background: "transparent",
                        border: "none",
                        padding: 0,
                        cursor: "pointer",
                        textAlign: "left",
                        fontWeight: isSelected ? "bold" : "normal",
                      }}
                    >
                      {p.question}
                    </button>
                  </li>
                );
              })
            )}
          </ul>

          {selectedPuzzle && (
            <div style={{ marginTop: 16, maxWidth: 720 }}>
              <h3>Selected</h3>
              <p data-testid="daily-selected-question">{selectedPuzzle.question}</p>

              <button
                data-testid="daily-mark-solved"
                onClick={markSolved}
                disabled={solveLoading}
              >
                {solveLoading ? "Recording…" : "Mark Solved"}
              </button>

              {solveOk && (
                <p data-testid="daily-solve-ok" style={{ marginTop: 10 }}>
                  {solveOk}
                </p>
              )}
              {solveError && (
                <p data-testid="daily-solve-error" style={{ marginTop: 10, color: "crimson" }}>
                  {solveError}
                </p>
              )}

              <p style={{ marginTop: 12 }}>
                Next: open <a href="/app/progress">Progress</a> to see updated totals.
              </p>
            </div>
          )}
        </>
      )}
    </div>
  );
}
